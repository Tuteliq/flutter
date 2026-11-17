import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tuteliq/tuteliq.dart';

const _apiKey = 'test-api-key-12345';

/// Records every request and answers each one with [respond].
class _Recorder {
  _Recorder(this.respond);

  final http.Response Function(http.Request request) respond;
  final List<http.Request> requests = [];

  http.Request get last => requests.last;

  Tuteliq client() => Tuteliq(
        apiKey: _apiKey,
        maxRetries: 1,
        httpClient: MockClient((request) async {
          requests.add(request);
          return respond(request);
        }),
      );
}

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

http.Response _rejected(http.Request _) => _json({
      'error': {'code': 'FILE_INVALID_TYPE', 'message': 'Unsupported file type'},
    }, 400);

Map<String, dynamic> _bodyOf(http.Request request) =>
    jsonDecode(request.body) as Map<String, dynamic>;

/// The content type the multipart file part was sent with.
String? _filePartContentType(http.Request request) {
  final body = latin1.decode(request.bodyBytes);
  final match = RegExp(r'content-type: ([^\r\n]+)\r\ncontent-disposition: form-data; name="file"')
      .firstMatch(body);
  return match?.group(1);
}

Future<void> _ignoringErrors(Future<Object?> Function() call) async {
  try {
    await call();
  } catch (_) {
    // Only the outgoing request matters to the caller of this helper.
  }
}

void main() {
  group('File uploads carry their real content type', () {
    test('image upload is sent as image/png, not application/octet-stream', () async {
      final recorder = _Recorder(_rejected);
      await _ignoringErrors(() => recorder.client().analyzeImage(
            file: [0x89, 0x50, 0x4E, 0x47],
            filename: 'photo.png',
          ));
      expect(recorder.last.url.path, '/api/v1/safety/image');
      expect(_filePartContentType(recorder.last), 'image/png');
    });

    test('voice upload is sent as audio/mpeg', () async {
      final recorder = _Recorder(_rejected);
      await _ignoringErrors(() => recorder.client().analyzeVoice(
            file: [1, 2, 3],
            filename: 'note.mp3',
          ));
      expect(recorder.last.url.path, '/api/v1/safety/voice');
      expect(_filePartContentType(recorder.last), 'audio/mpeg');
    });

    test('video upload is sent as video/mp4', () async {
      final recorder = _Recorder(_rejected);
      await _ignoringErrors(() => recorder.client().analyzeVideo(
            file: [1, 2, 3],
            filename: 'clip.mp4',
          ));
      expect(recorder.last.url.path, '/api/v1/safety/video');
      expect(_filePartContentType(recorder.last), 'video/mp4');
    });

    test('document upload is sent as application/pdf', () async {
      final recorder = _Recorder(_rejected);
      await _ignoringErrors(() => recorder.client().analyzeDocument(
            file: utf8.encode('%PDF-1.7'),
            filename: 'report.pdf',
          ));
      expect(recorder.last.url.path, '/api/v1/safety/document');
      expect(_filePartContentType(recorder.last), 'application/pdf');
    });
  });

  group('Upload content type inference', () {
    test('an explicit content type wins over the filename', () async {
      final recorder = _Recorder(_rejected);
      await _ignoringErrors(() => recorder.client().analyzeImage(
            file: [1, 2, 3],
            filename: 'upload.bin',
            contentType: 'image/webp',
          ));
      expect(_filePartContentType(recorder.last), 'image/webp');
    });

    test('a JPEG without an extension is recognised from its bytes', () async {
      final recorder = _Recorder(_rejected);
      await _ignoringErrors(() => recorder.client().analyzeImage(
            file: [0xFF, 0xD8, 0xFF, 0xE0],
            filename: 'camera-capture',
          ));
      expect(_filePartContentType(recorder.last), 'image/jpeg');
    });

    test('synthetic image detection sends the image type', () async {
      final recorder = _Recorder(_rejected);
      await _ignoringErrors(() => recorder.client().detectSyntheticImage(
            file: [1, 2, 3],
            filename: 'face.JPG',
          ));
      expect(recorder.last.url.path, '/api/v1/safety/synthetic-content/image');
      expect(_filePartContentType(recorder.last), 'image/jpeg');
    });
  });

  group('Voice streaming handshake', () {
    test('the stream URL follows a custom base URL', () {
      expect(
        voiceStreamUri('http://localhost:3000').toString(),
        'ws://localhost:3000/api/v1/safety/voice/stream',
      );
    });

    test('connects to the API route and authenticates with subprotocols', () async {
      Uri? connectedTo;
      Iterable<String>? offeredProtocols;
      final session = VoiceStreamSession(
        _apiKey,
        null,
        null,
        connector: (uri, protocols) {
          connectedTo = uri;
          offeredProtocols = protocols;
          throw StateError('stop after the handshake arguments are known');
        },
      );

      await expectLater(session.connect(), throwsStateError);

      expect(
        connectedTo.toString(),
        'wss://api.tuteliq.ai/api/v1/safety/voice/stream',
      );
      expect(offeredProtocols, ['tuteliq', 'tuteliq.apikey.$_apiKey']);
    });
  });

  group('Webhooks follow the API contract', () {
    test('listWebhooks reads is_active', () async {
      final recorder = _Recorder((_) => _json({
            'webhooks': [
              {
                'id': 'wh_1',
                'name': 'Alerts',
                'url': 'https://example.com/hook',
                'events': ['incident.critical'],
                'is_active': true,
                'failure_count': 0,
                'last_triggered_at': null,
                'last_error': null,
                'created_at': '2026-01-01T00:00:00.000Z',
                'updated_at': '2026-01-02T00:00:00.000Z',
              },
            ],
          }));

      final result = await recorder.client().listWebhooks();

      expect(recorder.last.method, 'GET');
      expect(recorder.last.url.path, '/api/v1/webhooks');
      expect(result.webhooks.single.active, isTrue);
    });

    test('updateWebhook uses PUT on the webhook', () async {
      final recorder = _Recorder((_) => _json({
            'id': 'wh_1',
            'name': 'Alerts',
            'url': 'https://example.com/hook',
            'events': ['incident.critical'],
            'is_active': false,
            'updated_at': '2026-01-02T00:00:00.000Z',
          }));

      final result = await recorder
          .client()
          .updateWebhook('wh_1', const UpdateWebhookInput(active: false));

      expect(recorder.last.method, 'PUT');
      expect(recorder.last.url.path, '/api/v1/webhooks/wh_1');
      expect(_bodyOf(recorder.last), {'is_active': false});
      expect(result.webhook.active, isFalse);
    });

    test('createWebhook sends the required name and reads the secret', () async {
      final recorder = _Recorder((_) => _json({
            'id': 'wh_2',
            'name': 'Alerts',
            'url': 'https://example.com/hook',
            'secret': 'whsec_invented',
            'events': ['grooming.detected'],
            'is_active': true,
            'created_at': '2026-01-01T00:00:00.000Z',
          }, 201));

      final result = await recorder.client().createWebhook(
            const CreateWebhookInput(
              name: 'Alerts',
              url: 'https://example.com/hook',
              events: [WebhookEventType.groomingDetected],
            ),
          );

      expect(recorder.last.method, 'POST');
      expect(recorder.last.url.path, '/api/v1/webhooks');
      expect(_bodyOf(recorder.last), {
        'name': 'Alerts',
        'url': 'https://example.com/hook',
        'events': ['grooming.detected'],
      });
      expect(result.webhook.secret, 'whsec_invented');
      expect(result.webhook.active, isTrue);
    });

    test('createWebhook is not retried after a server error', () async {
      final recorder = _Recorder((_) => _json({
            'error': {'message': 'Unavailable'},
          }, 503));
      final client = Tuteliq(
        apiKey: _apiKey,
        maxRetries: 3,
        retryDelay: Duration.zero,
        httpClient: MockClient((request) async {
          recorder.requests.add(request);
          return recorder.respond(request);
        }),
      );

      await _ignoringErrors(() => client.createWebhook(const CreateWebhookInput(
            name: 'Alerts',
            url: 'https://example.com/hook',
            events: [WebhookEventType.incidentCritical],
          )));

      expect(recorder.requests, hasLength(1));
    });

    test('testWebhook posts the webhook id to /webhooks/test', () async {
      final recorder = _Recorder((_) => _json({
            'success': true,
            'status_code': 200,
            'latency_ms': 120,
          }));

      final result = await recorder.client().testWebhook('wh_1');

      expect(recorder.last.method, 'POST');
      expect(recorder.last.url.path, '/api/v1/webhooks/test');
      expect(_bodyOf(recorder.last), {'webhook_id': 'wh_1'});
      expect(result.success, isTrue);
      expect(result.statusCode, 200);
      expect(result.latencyMs, 120);
    });

    test('regenerateWebhookSecret posts to /regenerate-secret', () async {
      final recorder = _Recorder((_) => _json({'secret': 'whsec_invented'}));

      final result = await recorder.client().regenerateWebhookSecret('wh_1');

      expect(recorder.last.method, 'POST');
      expect(recorder.last.url.path, '/api/v1/webhooks/wh_1/regenerate-secret');
      expect(result.secret, 'whsec_invented');
    });
  });

  group('analyze() keeps the most severe recommended action', () {
    Map<String, dynamic> bullying(String action) => {
          'is_bullying': true,
          'severity': 'high',
          'bullying_type': ['harassment'],
          'confidence': 0.9,
          'rationale': 'Invented rationale.',
          'risk_score': 0.8,
          'recommended_action': action,
        };

    Map<String, dynamic> unsafe(String action) => {
          'unsafe': false,
          'categories': <String>[],
          'severity': 'low',
          'confidence': 0.9,
          'rationale': 'Invented rationale.',
          'risk_score': 0.1,
          'recommended_action': action,
        };

    Future<String> analyzeWith(String bullyingAction, String unsafeAction) async {
      final recorder = _Recorder((request) => request.url.path.endsWith('/bullying')
          ? _json(bullying(bullyingAction))
          : _json(unsafe(unsafeAction)));
      final result = await recorder.client().analyze('Invented message');
      return result.recommendedAction;
    }

    test('block is not reported as monitor', () async {
      expect(await analyzeWith('block', 'monitor'), 'block');
    });

    test('flag_for_review is not reported as none', () async {
      expect(await analyzeWith('none', 'flag_for_review'), 'flag_for_review');
    });

    test('immediate_intervention outranks block', () async {
      expect(await analyzeWith('block', 'immediate_intervention'),
          'immediate_intervention');
    });

    test('none when both sub-results say none', () async {
      expect(await analyzeWith('none', 'none'), 'none');
    });

    test('an unrecognised action is never reported as none', () {
      expect(
        RecommendedAction.mostSevere(['none', 'some_future_action']),
        RecommendedAction.flagForReview,
      );
    });
  });

  group('Enums accept every value the API sends', () {
    const apiLanguages = [
      'en', 'es', 'pt', 'uk', 'sv', 'no', 'da', 'fi', 'de', 'fr', 'nl', //
      'pl', 'it', 'tr', 'ro', 'el', 'cs', 'hu', 'bg', 'hr', 'sk', 'lt', //
      'lv', 'et', 'sl', 'mt', 'ga', 'zh', 'ja', 'ko', 'ar', 'ru',
    ];

    test('every supported language parses to itself', () {
      for (final code in apiLanguages) {
        expect(Language.fromString(code).value, code);
      }
    });

    test('an unrecognised language does not throw', () {
      expect(() => Language.fromString('xx'), returnsNormally);
    });

    test('current and legacy tiers parse to themselves', () {
      for (final tier in [
        'starter', 'indie', 'pro', 'business', //
        'build', 'assure', 'enterprise',
      ]) {
        expect(Tier.fromString(tier).value, tier);
      }
    });

    test('an unrecognised tier does not throw', () {
      expect(() => Tier.fromString('future-plan'), returnsNormally);
    });

    test('an unrecognised language status does not throw', () {
      expect(() => LanguageStatus.fromString('preview'), returnsNormally);
    });
  });

  group('Verification sessions', () {
    test('createVerificationSession sends only the accepted fields', () async {
      final recorder = _Recorder((_) => _json({
            'session_id': 'vs_1',
            'mobile_url': 'https://verify.example.com/age/?session=vs_1',
            'expires_at': 1767225600000,
            'mode': 'identity',
            'verification_mode': 'full',
            'chip_policy': 'required',
            'auto_capture': false,
            'recommended_image_width': 1600,
          }, 201));

      final session = await recorder.client().createVerificationSession(
            const CreateVerificationSessionInput(
              mode: VerificationMode.identity,
              documentType: VerificationDocumentType.nationalId,
              chipPolicy: ChipPolicy.required,
              autoCapture: false,
            ),
          );

      expect(recorder.last.method, 'POST');
      expect(recorder.last.url.path, '/api/v1/verify/session');
      expect(_bodyOf(recorder.last), {
        'mode': 'identity',
        'document_type': 'national_id',
        'chip_policy': 'required',
        'auto_capture': false,
      });
      expect(session.sessionId, 'vs_1');
      expect(session.mobileUrl, 'https://verify.example.com/age/?session=vs_1');
      expect(session.expiresAt, 1767225600000);
      expect(session.chipPolicy, ChipPolicy.required);
      expect(session.autoCapture, isFalse);
      expect(session.recommendedImageWidth, 1600);
    });

    test('getVerificationSession reads the result and face match', () async {
      final recorder = _Recorder((_) => _json({
            'session_id': 'vs_1',
            'status': 'completed',
            'verification_mode': 'full',
            'document_evidence': 'photo',
            'step_progress': null,
            'chip_policy': 'optional',
            'capture': null,
            'created_at': 1767225000000,
            'expires_at': 1767225600000,
            'result': {
              'status': 'verified',
              'age': 34,
              'is_minor': false,
              'face_match': {
                'matched': true,
                'confidence': 0.71,
                'match_score': 0.93,
              },
              'liveness': {'valid': true},
              'failure_reasons': <String>[],
            },
          }));

      final result =
          await recorder.client().getVerificationSession('vs_1');

      expect(recorder.last.method, 'GET');
      expect(recorder.last.url.path, '/api/v1/verify/session/vs_1');
      expect(result.status, VerificationSessionStatus.completed);
      expect(result.result!.isMinor, isFalse);
      expect(result.result!.faceMatch!.matched, isTrue);
      expect(result.result!.faceMatch!.matchScore, 0.93);
      expect(result.result!.livenessValid, isTrue);
    });

    test('an unknown session status does not throw', () {
      final result = VerificationSessionResult.fromJson({
        'session_id': 'vs_1',
        'status': 'some_new_status',
      });
      expect(result.status, VerificationSessionStatus.unknown);
      expect(result.rawStatus, 'some_new_status');
    });

    test('cancelVerificationSession sends DELETE', () async {
      final recorder = _Recorder((_) => _json({'ok': true}));

      await recorder.client().cancelVerificationSession('vs_1');

      expect(recorder.last.method, 'DELETE');
      expect(recorder.last.url.path, '/api/v1/verify/session/vs_1');
    });

    test('verifyImageMatch sends base64 images', () async {
      final recorder = _Recorder((_) => _json({
            'schema_version': '1',
            'checks_run': ['face_match'],
            'face_match': {'matched': false, 'match_score': 0.1},
            'credits_used': 2,
            'processing_ms': 40,
          }));

      final result = await recorder.client().verifyImageMatch(
            image: [1, 2, 3],
            referenceImage: [4, 5, 6],
            checks: [ImageMatchCheck.faceMatch],
          );

      expect(recorder.last.url.path, '/api/v1/verify-image-match');
      expect(_bodyOf(recorder.last), {
        'image': base64Encode([1, 2, 3]),
        'reference_image': base64Encode([4, 5, 6]),
        'checks': ['face_match'],
      });
      expect(result.faceMatch!.matched, isFalse);
    });
  });

  group('Incidents', () {
    test('listIncidents sends filters as query parameters', () async {
      final recorder = _Recorder((_) => _json({
            'incidents': [
              {
                'id': 'inc_1',
                'risk_category': 'grooming',
                'risk_level': 'high',
                'status': 'new',
                'source': 'text',
                'created_at': '2026-01-01T00:00:00.000Z',
              },
            ],
            'next_cursor': 'cursor_2',
            'total_returned': 1,
          }));

      final result = await recorder.client().listIncidents(
            const ListIncidentsInput(
              category: 'grooming',
              severity: 'high',
              limit: 10,
              includeSummary: true,
            ),
          );

      expect(recorder.last.method, 'GET');
      expect(recorder.last.url.path, '/api/v1/incidents');
      expect(recorder.last.url.queryParameters, {
        'category': 'grooming',
        'severity': 'high',
        'limit': '10',
        'include_summary': 'true',
      });
      expect(result.incidents.single.riskCategory, 'grooming');
      expect(result.nextCursor, 'cursor_2');
    });

    test('overview, trends and detail use their routes', () async {
      final recorder = _Recorder((request) {
        switch (request.url.path) {
          case '/api/v1/incidents/overview':
            return _json({
              'total_incidents': 3,
              'counts_by_category': {'bullying': 3},
              'top_platforms': [
                {'platform': 'chat', 'count': 3},
              ],
            });
          case '/api/v1/incidents/trends':
            return _json({
              'bucket_size': 'week',
              'series': [
                {
                  'bucket_start': '2026-01-05T00:00:00.000Z',
                  'total': 2,
                  'by_severity': {'high': 2},
                },
              ],
            });
          default:
            return _json({
              'id': 'inc_1',
              'risk_category': 'bullying',
              'risk_level': 'moderate',
              'status': 'reviewed',
            });
        }
      });
      final client = recorder.client();

      final overview = await client.getIncidentsOverview();
      final trends = await client.getIncidentTrends(bucket: 'week');
      final incident = await client.getIncident('inc_1');

      expect(overview.totalIncidents, 3);
      expect(overview.countsByCategory, {'bullying': 3});
      expect(overview.topPlatforms, {'chat': 3});
      expect(recorder.requests[1].url.queryParameters, {'bucket': 'week'});
      expect(trends.series.single.total, 2);
      expect(recorder.last.url.path, '/api/v1/incidents/inc_1');
      expect(incident.riskLevel, 'moderate');
    });

    test('reviewIncident posts the decision', () async {
      final recorder = _Recorder((_) => _json({
            'incident_id': 'inc_1',
            'original': {'risk_category': 'bullying', 'risk_level': 'high'},
            'revised': {'risk_category': 'bullying', 'risk_level': 'low'},
            'audit_receipt': null,
          }));

      final result = await recorder.client().reviewIncident(
            'inc_1',
            const ReviewIncidentInput(
              action: 'downgrade',
              reasonCode: 'insufficient_severity',
              moderatorExternalId: 'moderator_7',
              newRiskLevel: 'low',
            ),
          );

      expect(recorder.last.url.path, '/api/v1/incidents/inc_1/review');
      expect(_bodyOf(recorder.last), {
        'action': 'downgrade',
        'reason_code': 'insufficient_severity',
        'moderator_external_id': 'moderator_7',
        'new_risk_level': 'low',
      });
      expect(result.revised!['risk_level'], 'low');
    });

    test('batchReviewIncidents posts the ids with the decision', () async {
      final recorder = _Recorder((_) => _json({
            'total': 2,
            'succeeded': 1,
            'failed': 1,
            'results': [
              {'incident_id': 'inc_1', 'ok': true},
              {'incident_id': 'inc_2', 'ok': false, 'error': 'Not found'},
            ],
          }));

      final result = await recorder.client().batchReviewIncidents(
        ['inc_1', 'inc_2'],
        const ReviewIncidentInput(
          action: 'dismiss',
          reasonCode: 'false_positive',
          moderatorExternalId: 'moderator_7',
        ),
      );

      expect(recorder.last.url.path, '/api/v1/incidents/batch-review');
      expect(_bodyOf(recorder.last)['incident_ids'], ['inc_1', 'inc_2']);
      expect(result.failed, 1);
      expect(result.results.last.ok, isFalse);
    });

    test('reclassify without a new category is refused locally', () async {
      final recorder = _Recorder((_) => _json({}));
      await expectLater(
        () => recorder.client().reviewIncident(
              'inc_1',
              const ReviewIncidentInput(
                action: 'reclassify',
                reasonCode: 'incorrect_category',
                moderatorExternalId: 'moderator_7',
              ),
            ),
        throwsArgumentError,
      );
      expect(recorder.requests, isEmpty);
    });
  });

  group('Other endpoints', () {
    test('detectDistressSignals and detectTfgbv use their routes', () async {
      final recorder = _Recorder((request) => _json({
            'endpoint': request.url.pathSegments.last,
            'detected': false,
            'severity': 0,
            'confidence': 0.9,
            'risk_score': 0.05,
            'level': 'none',
            'categories': <Object>[],
            'recommended_action': 'none',
            'rationale': 'Invented rationale.',
            'language': 'en',
            'language_status': 'stable',
          }));
      final client = recorder.client();

      await client.detectDistressSignals(
          const DetectionInput(content: 'Invented message'));
      expect(recorder.last.url.path, '/api/v1/safety/distress-signals');

      await client.detectTfgbv(const DetectionInput(content: 'Invented message'));
      expect(recorder.last.url.path, '/api/v1/safety/tfgbv');
    });

    test('detectNickname sends the name and context', () async {
      final recorder = _Recorder((_) => _json({
            'signal': 'none',
            'categories': <String>[],
            'parts': [
              {'text': 'Star', 'reading': 'ordinary', 'category': null},
            ],
            'rationale': 'Invented rationale.',
            'recommendation': 'allow',
            'recommendation_detail': 'Invented detail.',
            'confidence': 0.95,
            'language': 'en',
            'strictness': 'balanced',
            'reading_complete': true,
            'credits_used': 1,
          }));

      final result = await recorder.client().detectNickname(
            const DetectNicknameInput(
              name: 'StarPlayer',
              conversationType: 'gaming_chat',
            ),
          );

      expect(recorder.last.url.path, '/api/v1/safety/nickname');
      expect(_bodyOf(recorder.last), {
        'name': 'StarPlayer',
        'context': {'conversation_type': 'gaming_chat'},
      });
      expect(result.recommendation, 'allow');
    });

    test('detectSyntheticText sends the text and options', () async {
      final recorder = _Recorder((_) => _json({
            'endpoint': 'synthetic-content',
            'detected': false,
            'classification': 'unknown',
            'confidence': 0.5,
            'risk_score': 0.1,
            'level': 'none',
            'categories': <Object>[],
            'recommended_action': 'none',
            'rationale': 'Invented rationale.',
          }));

      final result = await recorder.client().detectSyntheticText(
            'Invented message',
            supportThreshold: 'high',
          );

      expect(recorder.last.url.path, '/api/v1/safety/synthetic-content');
      final body = _bodyOf(recorder.last);
      expect(body['text'], 'Invented message');
      expect(body['options'], {'support_threshold': 'high'});
      expect(result.classification, 'unknown');
    });

    test('usage summary and quota read the API field names', () async {
      final recorder = _Recorder((request) => request.url.path.endsWith('/quota')
          ? _json({
              'tier': 'build',
              'limits': {
                'requestsPerMinute': 1000,
                'requestsPerMonth': 10000,
                'requestsPerDay': -1,
              },
              'current': {'requestsThisMinute': 3, 'requestsToday': 40},
              'remaining': {'requestsThisMinute': 997, 'requestsToday': -1},
              'resetsInSeconds': 12,
            })
          : _json({
              'apiKeyId': 'key_1',
              'tier': 'build',
              'date': '2026-01-01',
              'usage': {
                'totalRequests': 40,
                'successRequests': 39,
                'errorRequests': 1,
              },
              'quota': {
                'requestsPerMinute': 1000,
                'requestsPerMonth': 10000,
                'requestsPerDay': -1,
                'remainingToday': -1,
              },
            }));
      final client = recorder.client();

      final summary = await client.getUsageSummary(date: '2026-01-01');
      expect(recorder.last.url.path, '/api/v1/usage/summary');
      expect(recorder.last.url.queryParameters, {'date': '2026-01-01'});
      expect(summary.totalRequests, 40);
      expect(summary.remainingToday, -1);

      final quota = await client.getQuota();
      expect(recorder.last.url.path, '/api/v1/usage/quota');
      expect(quota.remainingThisMinute, 997);
      expect(quota.resetsInSeconds, 12);
    });
  });
}
