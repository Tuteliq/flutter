## 2.2.1

Changes since 1.3.0, summarized from commit history:

### Added
- Fraud detection, extended safety detection, multi-endpoint analysis (`analyseMulti`), and video analysis support
- GDPR account management methods (Article 17 erasure, Article 20 portability)
- Voice and image analysis, webhooks, pricing, and usage endpoints

### Changed
- Usage headers updated to `X-Monthly-*` format

## 1.3.0

### Added
- Voice streaming support via WebSocket (`voiceStream()`)
- `creditsUsed` field on all result types

## 1.0.0

- Initial release
- Full support for all Tuteliq API endpoints
- Bullying detection
- Grooming detection
- Unsafe content detection
- Quick analysis (combined detection)
- Emotion analysis
- Action plan generation
- Incident report generation
- External ID and metadata tracking
- Automatic retry with exponential backoff
- Comprehensive error handling
