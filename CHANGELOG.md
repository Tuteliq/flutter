## 2.4.0

Brings the SDK in line with the current Tuteliq API. Version 2.3.0 was tagged but never released; its document analysis is included here.

### Fixed
- Image, voice, video and document uploads are sent with the file's content type (from the filename extension, the file's first bytes, or the new `contentType` parameter). They were sent as `application/octet-stream`, which the API refuses.
- Voice streaming connects to `/api/v1/safety/voice/stream` and authenticates during the WebSocket handshake, so it works on every platform including the web. The initial config is sent once the session is ready, and the close code and reason reach `onClose`.
- `analyze()` reports the most severe recommended action of its checks (`none`, `monitor`, `flag_for_review`, `block`, `immediate_intervention`). A `block` or `flag_for_review` verdict was reported as a weaker action. An unrecognised action counts as `flag_for_review`, never `none`.
- Webhooks follow the API contract: `listWebhooks()` no longer crashes, `createWebhook()` sends the required `name`, `updateWebhook()` uses `PUT` and sends `is_active`, `testWebhook()` and `regenerateWebhookSecret()` call the right routes, and every webhook result parses the API's response.
- `Language`, `LanguageStatus`, `Detection` and `Tier` no longer throw on a value the SDK does not know; it parses to `unknown`.
- `createWebhook()` and `createVerificationSession()` are not retried, so a timeout never creates a duplicate.

### Added
- Hosted verification sessions: `createVerificationSession()`, `getVerificationSession()`, `cancelVerificationSession()`, with `VerificationMode`, `VerificationDocumentType`, `ChipPolicy` and `VerificationSessionStatus`.
- `verifyImageMatch()` for face matching, age estimation and forensic checks on one image.
- Incidents: `listIncidents()`, `getIncident()`, `getIncidentsOverview()`, `getIncidentTrends()`, `reviewIncident()`, `batchReviewIncidents()`.
- Document analysis: `analyzeDocument()` for PDFs and images, with `splitBySender` for messaging screenshots.
- `detectDistressSignals()`, `detectTfgbv()` and `detectNickname()`.
- Synthetic content detection: `detectSyntheticText()`, `detectSyntheticImage()`, `detectSyntheticAudio()`, `detectSyntheticVideo()`.
- `getUsageSummary()` and `getQuota()`.
- All 32 supported languages in `Language`; the Build and Assure plans in `Tier`; `RecommendedAction`; `WebhookEventType`.
- `httpClient` option on `Tuteliq` for custom HTTP clients and tests.

### Changed
- Webhook results: `CreateWebhookResult.webhook` and `UpdateWebhookResult.webhook` are read from the API's response, and their `message` is now optional. `TestWebhookResult` has `success`, `statusCode`, `latencyMs` and `error`; `DeleteWebhookResult` has `success`; `RegenerateSecretResult` has `secret` only.
- `CreateWebhookInput` requires `name`; its `active` field is deprecated and not sent, since new webhooks are always active.
- `VoiceStreamConfig.context` accepts any JSON values, so `child_age` can be a number.

### Removed
- The README no longer documents `verifyAge()` and `verifyIdentity()`, which the SDK never had. Use verification sessions.

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
