<p align="center">
  <img src="./assets/logo.png" alt="Tuteliq" width="200" />
</p>

<h1 align="center">Tuteliq Flutter SDK</h1>

<p align="center">
  <strong>Official Flutter/Dart SDK for the Tuteliq API</strong><br>
  AI-powered child safety analysis
</p>

<p align="center">
  <a href="https://pub.dev/packages/tuteliq"><img src="https://img.shields.io/pub/v/tuteliq.svg" alt="pub version"></a>
  <a href="https://github.com/Tuteliq/flutter/actions"><img src="https://img.shields.io/github/actions/workflow/status/Tuteliq/flutter/ci.yml" alt="build status"></a>
  <a href="https://github.com/Tuteliq/flutter/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Tuteliq/flutter.svg" alt="license"></a>
</p>

<p align="center">
  <a href="https://api.tuteliq.ai/docs">API Docs</a> •
  <a href="https://tuteliq.app">Dashboard</a> •
  <a href="https://discord.gg/7kbTeRYRXD">Discord</a>
</p>

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  tuteliq: ^1.0.0
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
import 'package:tuteliq/tuteliq.dart';

void main() async {
  final client = Tuteliq(apiKey: 'your-api-key');

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
import 'package:tuteliq/tuteliq.dart';

// Simple
final client = Tuteliq(apiKey: 'your-api-key');

// With options
final client = Tuteliq(
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

### Voice Streaming

Real-time voice analysis over WebSocket:

```dart
final session = client.voiceStream(
  config: VoiceStreamConfig(
    intervalSeconds: 10,
    analysisTypes: ['bullying', 'unsafe'],
  ),
  handlers: VoiceStreamHandlers(
    onReady: (e) => print('Session ready: ${e.sessionId}'),
    onTranscription: (e) => print('Text: ${e.text}'),
    onAlert: (e) => print('Alert: ${e.category} (${e.severity})'),
    onSessionSummary: (e) => print('Summary: risk ${e.overallRisk}'),
  ),
);

await session.connect();

// Send audio data
session.sendAudio(audioBytes);

// End session and get summary
final summary = await session.end();

// Cleanup
session.close();
```

### Credits Used

All analysis result types include a `creditsUsed` field that indicates how many API credits were consumed:

```dart
final result = await client.detectBullying('text to analyze');
print('Credits used: ${result.creditsUsed}');
```

| Method | Credits |
|--------|---------|
| `detectBullying()` | 1 |
| `detectUnsafe()` | 1 |
| `detectGrooming()` | 1 per 10 messages |
| `analyzeEmotions()` | 1 per 10 messages |
| `getActionPlan()` | 2 |
| `generateReport()` | 3 |
| `analyzeVoice()` | 5 |
| `analyzeImage()` | 3 |

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
import 'package:tuteliq/tuteliq.dart';

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
} on TuteliqException catch (e) {
  print('Error: ${e.message}');
}
```

---

## Flutter Example

```dart
import 'package:flutter/material.dart';
import 'package:tuteliq/tuteliq.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _client = Tuteliq(apiKey: 'your-api-key');
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
    } on TuteliqException catch (e) {
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

Enable `PII_REDACTION_ENABLED=true` on your Tuteliq API to automatically strip emails, phone numbers, URLs, social handles, IPs, and other PII from detection summaries and webhook payloads. The original text is still analyzed in full — only stored outputs are scrubbed.

---

## Support

- **API Docs**: [api.tuteliq.ai/docs](https://api.tuteliq.ai/docs)
- **Discord**: [discord.gg/7kbTeRYRXD](https://discord.gg/7kbTeRYRXD)
- **Email**: support@tuteliq.ai
- **Issues**: [GitHub Issues](https://github.com/Tuteliq/flutter/issues)

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## The Mission: Why This Matters

Before you decide to contribute or sponsor, read these numbers. They are not projections. They are not estimates from a pitch deck. They are verified statistics from the University of Edinburgh, UNICEF, NCMEC, and Interpol.

- **302 million** children are victims of online sexual exploitation and abuse every year. That is **10 children every second**. *(Childlight / University of Edinburgh, 2024)*
- **1 in 8** children globally have been victims of non-consensual sexual imagery in the past year. *(Childlight, 2024)*
- **370 million** girls and women alive today experienced rape or sexual assault in childhood. An estimated **240–310 million** boys and men experienced the same. *(UNICEF, 2024)*
- **29.2 million** incidents of suspected child sexual exploitation were reported to NCMEC's CyberTipline in 2024 alone — containing **62.9 million files** (images, videos). *(NCMEC, 2025)*
- **546,000** reports of online enticement (adults grooming children) in 2024 — a **192% increase** from the year before. *(NCMEC, 2025)*
- **1,325% increase** in AI-generated child sexual abuse material reports between 2023 and 2024. The technology that should protect children is being weaponized against them. *(NCMEC, 2025)*
- **100 sextortion reports per day** to NCMEC. Since 2021, at least **36 teenage boys** have taken their own lives because they were victimized by sextortion. *(NCMEC, 2025)*
- **84%** of reports resolve outside the United States. This is not an American problem. This is a **global emergency**. *(NCMEC, 2025)*

End-to-end encryption is making platforms blind. In 2024, platforms reported **7 million fewer incidents** than the year before — not because abuse stopped, but because they can no longer see it. The tools that catch known images are failing. The systems that rely on human moderators are overwhelmed. The technology to detect behavior — grooming patterns, escalation, manipulation — in real-time text conversations **exists right now**. It is running at [api.tuteliq.ai](https://api.tuteliq.ai).

The question is not whether this technology is possible. The question is whether we build the company to put it everywhere it needs to be.

**Every second we wait, another child is harmed.**

We have the technology. We need the support.

If this mission matters to you, consider [sponsoring our open-source work](https://github.com/sponsors/Tuteliq) so we can keep building the tools that protect children — and keep them free and accessible for everyone.

---

<p align="center">
  <sub>Built with care for child safety by the <a href="https://tuteliq.ai">Tuteliq</a> team</sub>
</p>
