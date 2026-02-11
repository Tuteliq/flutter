<p align="center">
  <img src="./assets/logo.png" alt="SafeNest" width="200" />
</p>

<h1 align="center">SafeNest Flutter SDK</h1>

<p align="center">
  <strong>Official Flutter/Dart SDK for the SafeNest API</strong><br>
  AI-powered child safety analysis
</p>

<p align="center">
  <a href="https://pub.dev/packages/safenest"><img src="https://img.shields.io/pub/v/safenest.svg" alt="pub version"></a>
  <a href="https://github.com/SafeNestSDK/flutter/actions"><img src="https://img.shields.io/github/actions/workflow/status/SafeNestSDK/flutter/ci.yml" alt="build status"></a>
  <a href="https://github.com/SafeNestSDK/flutter/blob/main/LICENSE"><img src="https://img.shields.io/github/license/SafeNestSDK/flutter.svg" alt="license"></a>
</p>

<p align="center">
  <a href="https://api.safenest.dev/docs">API Docs</a> •
  <a href="https://safenest.app">Dashboard</a> •
  <a href="https://discord.gg/7kbTeRYRXD">Discord</a>
</p>

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  safenest: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Requirements

- Dart 3.0+
- Flutter 3.10+

---

## Quick Start

```dart
import 'package:safenest/safenest.dart';

void main() async {
  final client = SafeNest(apiKey: 'your-api-key');

  // Quick safety analysis
  final result = await client.analyze('Message to check');

  if (result.riskLevel != RiskLevel.safe) {
    print('Risk: ${result.riskLevel.value}');
    print('Summary: ${result.summary}');
  }

  client.close();
}
```

---

## API Reference

### Initialization

```dart
import 'package:safenest/safenest.dart';

// Simple
final client = SafeNest(apiKey: 'your-api-key');

// With options
final client = SafeNest(
  apiKey: 'your-api-key',
  timeout: const Duration(seconds: 30),  // Request timeout
  maxRetries: 3,                          // Retry attempts
  retryDelay: const Duration(seconds: 1), // Initial retry delay
);
```

### Bullying Detection

```dart
final result = await client.detectBullying('Nobody likes you, just leave');

if (result.isBullying) {
  print('Severity: ${result.severity.value}');       // medium
  print('Types: ${result.bullyingType}');            // [exclusion, verbal_abuse]
  print('Confidence: ${result.confidence}');         // 0.92
  print('Rationale: ${result.rationale}');
}
```

### Grooming Detection

```dart
final result = await client.detectGrooming(
  DetectGroomingInput(
    messages: [
      const GroomingMessage(role: MessageRole.adult, content: 'This is our secret'),
      const GroomingMessage(role: MessageRole.child, content: 'Ok I wont tell'),
    ],
    childAge: 12,
  ),
);

if (result.groomingRisk == GroomingRisk.high) {
  print('Flags: ${result.flags}');  // [secrecy, isolation]
}
```

### Unsafe Content Detection

```dart
final result = await client.detectUnsafe('I dont want to be here anymore');

if (result.unsafe) {
  print('Categories: ${result.categories}');  // [self_harm, crisis]
  print('Severity: ${result.severity.value}'); // critical
}
```

### Quick Analysis

Runs bullying and unsafe detection:

```dart
final result = await client.analyze('Message to check');

print('Risk Level: ${result.riskLevel.value}');  // safe/low/medium/high/critical
print('Risk Score: ${result.riskScore}');        // 0.0 - 1.0
print('Summary: ${result.summary}');
print('Action: ${result.recommendedAction}');
```

### Emotion Analysis

```dart
final result = await client.analyzeEmotions('Im so stressed about everything');

print('Emotions: ${result.dominantEmotions}');  // [anxiety, sadness]
print('Trend: ${result.trend.value}');          // worsening
print('Followup: ${result.recommendedFollowup}');
```

### Action Plan

```dart
final plan = await client.getActionPlan(
  const GetActionPlanInput(
    situation: 'Someone is spreading rumors about me',
    childAge: 12,
    audience: Audience.child,
    severity: Severity.medium,
  ),
);

print('Steps: ${plan.steps}');
print('Tone: ${plan.tone}');
```

### Incident Report

```dart
final report = await client.generateReport(
  const GenerateReportInput(
    messages: [
      ReportMessage(sender: 'user1', content: 'Threatening message'),
      ReportMessage(sender: 'child', content: 'Please stop'),
    ],
    childAge: 14,
  ),
);

print('Summary: ${report.summary}');
print('Risk: ${report.riskLevel.value}');
print('Next Steps: ${report.recommendedNextSteps}');
```

---

## Tracking Fields

All methods support `externalId` and `metadata` for correlating requests:

```dart
final result = await client.detectBullying(
  'Test message',
  externalId: 'msg_12345',
  metadata: {'user_id': 'usr_abc', 'session': 'sess_xyz'},
);

// Echoed back in response
print(result.externalId);  // msg_12345
print(result.metadata);    // {user_id: usr_abc, ...}
```

---

## Usage Tracking

```dart
final result = await client.detectBullying('test');

// Access usage stats after any request
if (client.usage != null) {
  print('Limit: ${client.usage!.limit}');
  print('Used: ${client.usage!.used}');
  print('Remaining: ${client.usage!.remaining}');
}

// Request metadata
print('Request ID: ${client.lastRequestId}');
```

---

## Error Handling

```dart
import 'package:safenest/safenest.dart';

try {
  final result = await client.detectBullying('test');
} on AuthenticationException catch (e) {
  print('Auth error: ${e.message}');
} on RateLimitException catch (e) {
  print('Rate limited: ${e.message}');
} on ValidationException catch (e) {
  print('Invalid input: ${e.message}, details: ${e.details}');
} on ServerException catch (e) {
  print('Server error ${e.statusCode}: ${e.message}');
} on TimeoutException catch (e) {
  print('Timeout: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on SafeNestException catch (e) {
  print('Error: ${e.message}');
}
```

---

## Flutter Example

```dart
import 'package:flutter/material.dart';
import 'package:safenest/safenest.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _client = SafeNest(apiKey: 'your-api-key');
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() => _loading = true);

    try {
      final result = await _client.analyze(_controller.text);

      if (result.riskLevel == RiskLevel.critical ||
          result.riskLevel == RiskLevel.high) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message blocked: ${result.summary}')),
          );
        }
        return;
      }

      // Safe to send message
      _controller.clear();
    } on SafeNestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _client.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Type a message...'),
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _sendMessage,
              child: Text(_loading ? 'Checking...' : 'Send'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Best Practices

### Message Batching

The **bullying** and **unsafe content** methods analyze a single `text` field per request. If your app receives messages one at a time, concatenate a **sliding window of recent messages** into one string before calling the API. Single words or short fragments lack context for accurate detection and can be exploited to bypass safety filters.

```dart
// Bad — each message analyzed in isolation, easily evaded
for (final msg in messages) {
  await client.detectBullying(text: msg);
}

// Good — recent messages analyzed together
final window = recentMessages
    .reversed.take(10).toList().reversed
    .join(' ');
await client.detectBullying(text: window);
```

The **grooming** method already accepts a `messages` list and analyzes the full conversation in context.

### PII Redaction

Enable `PII_REDACTION_ENABLED=true` on your SafeNest API to automatically strip emails, phone numbers, URLs, social handles, IPs, and other PII from detection summaries and webhook payloads. The original text is still analyzed in full — only stored outputs are scrubbed.

---

## Support

- **API Docs**: [api.safenest.dev/docs](https://api.safenest.dev/docs)
- **Discord**: [discord.gg/7kbTeRYRXD](https://discord.gg/7kbTeRYRXD)
- **Email**: support@safenest.dev
- **Issues**: [GitHub Issues](https://github.com/SafeNestSDK/flutter/issues)

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with care for child safety by the <a href="https://safenest.dev">SafeNest</a> team</sub>
</p>
