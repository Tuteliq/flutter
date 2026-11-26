import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tuteliq/tuteliq.dart';

/// Runs [body] with a client whose HTTP calls are answered by [response].
/// Every request body the client sends is added to [sent].
Future<void> withStubbedClient(
  Map<String, dynamic> response,
  List<Map<String, dynamic>> sent,
  Future<void> Function(Tuteliq client) body,
) {
  final stub = MockClient((request) async {
    sent.add(jsonDecode(request.body) as Map<String, dynamic>);
    return http.Response(
      jsonEncode(response),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  return http.runWithClient(() async {
    final client = Tuteliq(apiKey: 'test-api-key-12345', maxRetries: 1);
    try {
      await body(client);
    } finally {
      client.close();
    }
  }, () => stub);
}

void main() {
  group('Client Initialization', () {
    test('creates client with valid API key', () {
      final client = Tuteliq(apiKey: 'test-api-key-12345');
      expect(client, isNotNull);
      client.close();
    });

    test('throws on empty API key', () {
      expect(
        () => Tuteliq(apiKey: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on short API key', () {
      expect(
        () => Tuteliq(apiKey: 'short'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts custom options', () {
      final client = Tuteliq(
        apiKey: 'test-api-key-12345',
        timeout: const Duration(seconds: 60),
        maxRetries: 5,
        retryDelay: const Duration(seconds: 2),
      );
      expect(client, isNotNull);
      client.close();
    });
  });

  group('Enum Values', () {
    test('Severity enum has correct values', () {
      expect(Severity.low.value, 'low');
      expect(Severity.medium.value, 'medium');
      expect(Severity.high.value, 'high');
      expect(Severity.critical.value, 'critical');
    });

    test('Severity.fromString works', () {
      expect(Severity.fromString('low'), Severity.low);
      expect(Severity.fromString('critical'), Severity.critical);
      expect(Severity.fromString('unknown'), Severity.low);
    });

    test('GroomingRisk enum has correct values', () {
      expect(GroomingRisk.none.value, 'none');
      expect(GroomingRisk.low.value, 'low');
      expect(GroomingRisk.high.value, 'high');
      expect(GroomingRisk.critical.value, 'critical');
    });

    test('RiskLevel enum has correct values', () {
      expect(RiskLevel.safe.value, 'safe');
      expect(RiskLevel.low.value, 'low');
      expect(RiskLevel.medium.value, 'medium');
      expect(RiskLevel.high.value, 'high');
      expect(RiskLevel.critical.value, 'critical');
    });

    test('EmotionTrend enum has correct values', () {
      expect(EmotionTrend.improving.value, 'improving');
      expect(EmotionTrend.stable.value, 'stable');
      expect(EmotionTrend.worsening.value, 'worsening');
    });

    test('Audience enum has correct values', () {
      expect(Audience.child.value, 'child');
      expect(Audience.parent.value, 'parent');
      expect(Audience.educator.value, 'educator');
      expect(Audience.platform.value, 'platform');
    });

    test('MessageRole enum has correct values', () {
      expect(MessageRole.adult.value, 'adult');
      expect(MessageRole.child.value, 'child');
      expect(MessageRole.unknown.value, 'unknown');
    });
  });

  group('Model Creation', () {
    test('AnalysisContext creation works', () {
      const context = AnalysisContext(
        language: 'en',
        ageGroup: '11-13',
        relationship: 'classmates',
        platform: 'chat',
      );
      expect(context.language, 'en');
      expect(context.ageGroup, '11-13');
    });

    test('AnalysisContext.toJson excludes null values', () {
      const context = AnalysisContext(language: 'en');
      final json = context.toJson();
      expect(json, {'language': 'en'});
      expect(json.containsKey('age_group'), false);
    });

    test('GroomingMessage creation works', () {
      const msg = GroomingMessage(
        role: MessageRole.adult,
        content: 'Hello',
      );
      expect(msg.role, MessageRole.adult);
      expect(msg.content, 'Hello');
    });

    test('DetectGroomingInput creation works', () {
      const input = DetectGroomingInput(
        messages: [
          GroomingMessage(role: MessageRole.adult, content: 'Hello'),
          GroomingMessage(role: MessageRole.child, content: 'Hi'),
        ],
        childAge: 12,
      );
      expect(input.messages.length, 2);
      expect(input.childAge, 12);
    });

    test('EmotionMessage creation works', () {
      const msg = EmotionMessage(sender: 'user', content: 'I feel happy');
      expect(msg.sender, 'user');
      expect(msg.content, 'I feel happy');
    });

    test('GetActionPlanInput creation works', () {
      const input = GetActionPlanInput(
        situation: 'Someone is spreading rumors',
        childAge: 12,
        audience: Audience.child,
        severity: Severity.medium,
      );
      expect(input.situation, 'Someone is spreading rumors');
      expect(input.childAge, 12);
      expect(input.audience, Audience.child);
      expect(input.severity, Severity.medium);
    });

    test('ReportMessage creation works', () {
      const msg = ReportMessage(sender: 'user1', content: 'Bad message');
      expect(msg.sender, 'user1');
      expect(msg.content, 'Bad message');
    });

    test('GenerateReportInput creation works', () {
      const input = GenerateReportInput(
        messages: [
          ReportMessage(sender: 'user1', content: 'Bad'),
          ReportMessage(sender: 'child', content: 'Stop'),
        ],
        childAge: 14,
        incidentType: 'bullying',
      );
      expect(input.messages.length, 2);
      expect(input.childAge, 14);
      expect(input.incidentType, 'bullying');
    });
  });

  group('Action Plan', () {
    const tailored = <String, dynamic>{
      'steps': ['Invented step'],
      'tone': 'calm',
      'resources': <String>[],
      'urgency': 'low',
    };

    test('sends country when set', () async {
      final sent = <Map<String, dynamic>>[];
      await withStubbedClient(tailored, sent, (client) async {
        await client.getActionPlan(
          const GetActionPlanInput(situation: 'Invented situation', country: 'SE'),
        );
      });
      expect(sent.single['country'], 'SE');
    });

    test('omits country when not set', () async {
      final sent = <Map<String, dynamic>>[];
      await withStubbedClient(tailored, sent, (client) async {
        await client.getActionPlan(
          const GetActionPlanInput(situation: 'Invented situation'),
        );
      });
      expect(sent.single.containsKey('country'), isFalse);
    });

    test('decodes general_guidance', () {
      final general = ActionPlanResult.fromJson({...tailored, 'general_guidance': true});
      expect(general.generalGuidance, isTrue);

      final plan = ActionPlanResult.fromJson(tailored);
      expect(plan.generalGuidance, isNull);
    });
  });

  group('Error Classes', () {
    test('TuteliqException has message', () {
      const error = TuteliqException('Test error');
      expect(error.message, 'Test error');
      expect(error.toString(), 'TuteliqException: Test error');
    });

    test('AuthenticationException works', () {
      const error = AuthenticationException('Invalid key');
      expect(error.message, 'Invalid key');
      expect(error.toString(), 'AuthenticationException: Invalid key');
    });

    test('ServerException has status code', () {
      const error = ServerException('Server error', 500);
      expect(error.message, 'Server error');
      expect(error.statusCode, 500);
      expect(error.toString(), 'ServerException (500): Server error');
    });
  });
}
