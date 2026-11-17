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

  group('Voice streaming handshake', () {
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

      await _ignoringErrors(() => recorder
          .client()
          .updateWebhook('wh_1', const UpdateWebhookInput(active: false)));

      expect(recorder.last.method, 'PUT');
      expect(recorder.last.url.path, '/api/v1/webhooks/wh_1');
      expect(_bodyOf(recorder.last), {'is_active': false});
    });

    test('testWebhook posts the webhook id to /webhooks/test', () async {
      final recorder = _Recorder((_) => _json({
            'success': true,
            'status_code': 200,
            'latency_ms': 120,
          }));

      await _ignoringErrors(() => recorder.client().testWebhook('wh_1'));

      expect(recorder.last.method, 'POST');
      expect(recorder.last.url.path, '/api/v1/webhooks/test');
      expect(_bodyOf(recorder.last), {'webhook_id': 'wh_1'});
    });

    test('regenerateWebhookSecret posts to /regenerate-secret', () async {
      final recorder = _Recorder((_) => _json({'secret': 'whsec_invented'}));

      await _ignoringErrors(
          () => recorder.client().regenerateWebhookSecret('wh_1'));

      expect(recorder.last.method, 'POST');
      expect(recorder.last.url.path, '/api/v1/webhooks/wh_1/regenerate-secret');
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
}
