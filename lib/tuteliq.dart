/// Official Flutter/Dart SDK for Tuteliq - AI-powered child safety API.
///
/// This library provides a type-safe client for the Tuteliq API,
/// enabling content moderation, bullying detection, grooming prevention,
/// and more.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:tuteliq/tuteliq.dart';
///
/// void main() async {
///   final client = Tuteliq(apiKey: 'your-api-key');
///
///   final result = await client.analyze('Message to check');
///   if (result.riskLevel != RiskLevel.safe) {
///     print('Risk: ${result.riskLevel}');
///     print('Summary: ${result.summary}');
///   }
///
///   client.close();
/// }
/// ```
library tuteliq;

export 'src/client.dart';
export 'src/enums.dart';
export 'src/errors.dart';
export 'src/models.dart';
export 'src/voice_stream.dart';
