import 'enums.dart';

// =============================================================================
// Context
// =============================================================================

/// Optional context for analysis.
class AnalysisContext {
  const AnalysisContext({
    this.language,
    this.ageGroup,
    this.relationship,
    this.platform,
  });

  final String? language;
  final String? ageGroup;
  final String? relationship;
  final String? platform;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (language != null) map['language'] = language;
    if (ageGroup != null) map['age_group'] = ageGroup;
    if (relationship != null) map['relationship'] = relationship;
    if (platform != null) map['platform'] = platform;
    return map;
  }
}

// =============================================================================
// Messages
// =============================================================================

/// Message for grooming detection.
class GroomingMessage {
  const GroomingMessage({
    required this.role,
    required this.content,
  });

  final MessageRole role;
  final String content;

  Map<String, dynamic> toJson() => {
        'sender_role': role.value,
        'text': content,
      };
}

/// Message for emotion analysis.
class EmotionMessage {
  const EmotionMessage({
    required this.sender,
    required this.content,
  });

  final String sender;
  final String content;

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': content,
      };
}

/// Message for incident reports.
class ReportMessage {
  const ReportMessage({
    required this.sender,
    required this.content,
  });

  final String sender;
  final String content;

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': content,
      };
}

// =============================================================================
// Input Types
// =============================================================================

/// Input for bullying detection.
class DetectBullyingInput {
  const DetectBullyingInput({
    required this.content,
    this.context,
    this.externalId,
    this.metadata,
  });

  final String content;
  final AnalysisContext? context;
  final String? externalId;
  final Map<String, dynamic>? metadata;
}

/// Input for grooming detection.
class DetectGroomingInput {
  const DetectGroomingInput({
    required this.messages,
    this.childAge,
    this.context,
    this.externalId,
    this.metadata,
  });

  final List<GroomingMessage> messages;
  final int? childAge;
  final AnalysisContext? context;
  final String? externalId;
  final Map<String, dynamic>? metadata;
}

/// Input for unsafe content detection.
class DetectUnsafeInput {
  const DetectUnsafeInput({
    required this.content,
    this.context,
    this.externalId,
    this.metadata,
  });

  final String content;
  final AnalysisContext? context;
  final String? externalId;
  final Map<String, dynamic>? metadata;
}

/// Input for quick analysis.
class AnalyzeInput {
  const AnalyzeInput({
    required this.content,
    this.context,
    this.include,
    this.externalId,
    this.metadata,
  });

  final String content;
  final AnalysisContext? context;
  final List<String>? include;
  final String? externalId;
  final Map<String, dynamic>? metadata;
}

/// Input for emotion analysis.
class AnalyzeEmotionsInput {
  const AnalyzeEmotionsInput({
    this.content,
    this.messages,
    this.context,
    this.externalId,
    this.metadata,
  });

  final String? content;
  final List<EmotionMessage>? messages;
  final AnalysisContext? context;
  final String? externalId;
  final Map<String, dynamic>? metadata;
}

/// Input for action plan generation.
class GetActionPlanInput {
  const GetActionPlanInput({
    required this.situation,
    this.childAge,
    this.audience,
    this.severity,
    this.externalId,
    this.metadata,
  });

  final String situation;
  final int? childAge;
  final Audience? audience;
  final Severity? severity;
  final String? externalId;
  final Map<String, dynamic>? metadata;
}

/// Input for incident report generation.
class GenerateReportInput {
  const GenerateReportInput({
    required this.messages,
    this.childAge,
    this.incidentType,
    this.externalId,
    this.metadata,
  });

  final List<ReportMessage> messages;
  final int? childAge;
  final String? incidentType;
  final String? externalId;
  final Map<String, dynamic>? metadata;
}

// =============================================================================
// Result Types
// =============================================================================

/// Result of bullying detection.
class BullyingResult {
  const BullyingResult({
    required this.isBullying,
    required this.severity,
    required this.bullyingType,
    required this.confidence,
    required this.rationale,
    required this.riskScore,
    required this.recommendedAction,
    this.externalId,
    this.metadata,
    this.creditsUsed,
  });

  factory BullyingResult.fromJson(Map<String, dynamic> json) {
    return BullyingResult(
      isBullying: json['is_bullying'] as bool,
      severity: Severity.fromString(json['severity'] as String),
      bullyingType: List<String>.from(json['bullying_type'] as List),
      confidence: (json['confidence'] as num).toDouble(),
      rationale: json['rationale'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      recommendedAction: json['recommended_action'] as String,
      externalId: json['external_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
    );
  }

  final bool isBullying;
  final Severity severity;
  final List<String> bullyingType;
  final double confidence;
  final String rationale;
  final double riskScore;
  final String recommendedAction;
  final String? externalId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

/// Result of grooming detection.
class GroomingResult {
  const GroomingResult({
    required this.groomingRisk,
    required this.flags,
    required this.confidence,
    required this.rationale,
    required this.riskScore,
    required this.recommendedAction,
    this.externalId,
    this.metadata,
    this.creditsUsed,
  });

  factory GroomingResult.fromJson(Map<String, dynamic> json) {
    return GroomingResult(
      groomingRisk: GroomingRisk.fromString(json['grooming_risk'] as String),
      flags: List<String>.from(json['flags'] as List),
      confidence: (json['confidence'] as num).toDouble(),
      rationale: json['rationale'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      recommendedAction: json['recommended_action'] as String,
      externalId: json['external_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
    );
  }

  final GroomingRisk groomingRisk;
  final List<String> flags;
  final double confidence;
  final String rationale;
  final double riskScore;
  final String recommendedAction;
  final String? externalId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

/// Result of unsafe content detection.
class UnsafeResult {
  const UnsafeResult({
    required this.unsafe,
    required this.categories,
    required this.severity,
    required this.confidence,
    required this.rationale,
    required this.riskScore,
    required this.recommendedAction,
    this.externalId,
    this.metadata,
    this.creditsUsed,
  });

  factory UnsafeResult.fromJson(Map<String, dynamic> json) {
    return UnsafeResult(
      unsafe: json['unsafe'] as bool,
      categories: List<String>.from(json['categories'] as List),
      severity: Severity.fromString(json['severity'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      rationale: json['rationale'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      recommendedAction: json['recommended_action'] as String,
      externalId: json['external_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
    );
  }

  final bool unsafe;
  final List<String> categories;
  final Severity severity;
  final double confidence;
  final String rationale;
  final double riskScore;
  final String recommendedAction;
  final String? externalId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

/// Result of quick analysis.
class AnalyzeResult {
  const AnalyzeResult({
    required this.riskLevel,
    required this.riskScore,
    required this.summary,
    required this.recommendedAction,
    this.bullying,
    this.unsafe,
    this.externalId,
    this.metadata,
    this.creditsUsed,
  });

  final RiskLevel riskLevel;
  final double riskScore;
  final String summary;
  final String recommendedAction;
  final BullyingResult? bullying;
  final UnsafeResult? unsafe;
  final String? externalId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

/// Result of emotion analysis.
class EmotionsResult {
  const EmotionsResult({
    required this.dominantEmotions,
    required this.trend,
    required this.intensity,
    required this.concerningPatterns,
    required this.recommendedFollowup,
    this.externalId,
    this.metadata,
    this.creditsUsed,
  });

  factory EmotionsResult.fromJson(Map<String, dynamic> json) {
    return EmotionsResult(
      dominantEmotions: List<String>.from(json['dominant_emotions'] as List),
      trend: EmotionTrend.fromString(json['trend'] as String),
      intensity: (json['intensity'] as num).toDouble(),
      concerningPatterns: List<String>.from(json['concerning_patterns'] as List),
      recommendedFollowup: json['recommended_followup'] as String,
      externalId: json['external_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
    );
  }

  final List<String> dominantEmotions;
  final EmotionTrend trend;
  final double intensity;
  final List<String> concerningPatterns;
  final String recommendedFollowup;
  final String? externalId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

/// Result of action plan generation.
class ActionPlanResult {
  const ActionPlanResult({
    required this.steps,
    required this.tone,
    required this.resources,
    required this.urgency,
    this.externalId,
    this.metadata,
    this.creditsUsed,
  });

  factory ActionPlanResult.fromJson(Map<String, dynamic> json) {
    return ActionPlanResult(
      steps: List<String>.from(json['steps'] as List),
      tone: json['tone'] as String,
      resources: List<String>.from(json['resources'] as List),
      urgency: json['urgency'] as String,
      externalId: json['external_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
    );
  }

  final List<String> steps;
  final String tone;
  final List<String> resources;
  final String urgency;
  final String? externalId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

/// Result of incident report generation.
class ReportResult {
  const ReportResult({
    required this.summary,
    required this.riskLevel,
    required this.timeline,
    required this.keyEvidence,
    required this.recommendedNextSteps,
    this.externalId,
    this.metadata,
    this.creditsUsed,
  });

  factory ReportResult.fromJson(Map<String, dynamic> json) {
    return ReportResult(
      summary: json['summary'] as String,
      riskLevel: RiskLevel.fromString(json['risk_level'] as String),
      timeline: List<String>.from(json['timeline'] as List),
      keyEvidence: List<String>.from(json['key_evidence'] as List),
      recommendedNextSteps: List<String>.from(json['recommended_next_steps'] as List),
      externalId: json['external_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
    );
  }

  final String summary;
  final RiskLevel riskLevel;
  final List<String> timeline;
  final List<String> keyEvidence;
  final List<String> recommendedNextSteps;
  final String? externalId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

// =============================================================================
// Account Management (GDPR)
// =============================================================================

/// Result of account data deletion (GDPR Article 17).
class AccountDeletionResult {
  const AccountDeletionResult({
    required this.message,
    required this.deletedCount,
  });

  factory AccountDeletionResult.fromJson(Map<String, dynamic> json) {
    return AccountDeletionResult(
      message: json['message'] as String,
      deletedCount: json['deleted_count'] as int,
    );
  }

  final String message;
  final int deletedCount;
}

/// Result of account data export (GDPR Article 20).
class AccountExportResult {
  const AccountExportResult({
    required this.userId,
    required this.exportedAt,
    required this.data,
  });

  factory AccountExportResult.fromJson(Map<String, dynamic> json) {
    return AccountExportResult(
      userId: json['userId'] as String,
      exportedAt: json['exportedAt'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  final String userId;
  final String exportedAt;
  final Map<String, dynamic> data;
}

// =============================================================================
// Consent Management (GDPR Article 7)
// =============================================================================

/// Types of consent.
enum ConsentType {
  dataProcessing('data_processing'),
  analytics('analytics'),
  marketing('marketing'),
  thirdPartySharing('third_party_sharing'),
  childSafetyMonitoring('child_safety_monitoring');

  const ConsentType(this.value);
  final String value;
}

/// Consent status values.
enum ConsentStatusValue {
  granted('granted'),
  withdrawn('withdrawn');

  const ConsentStatusValue(this.value);
  final String value;
}

/// Input for recording consent.
class RecordConsentInput {
  const RecordConsentInput({
    required this.consentType,
    required this.version,
  });

  final ConsentType consentType;
  final String version;
}

/// A consent record.
class ConsentRecord {
  const ConsentRecord({
    required this.id,
    required this.userId,
    required this.consentType,
    required this.status,
    required this.version,
    required this.createdAt,
  });

  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      consentType: json['consent_type'] as String,
      status: json['status'] as String,
      version: json['version'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  final String id;
  final String userId;
  final String consentType;
  final String status;
  final String version;
  final String createdAt;
}

/// Result from consent record/withdraw operations.
class ConsentActionResult {
  const ConsentActionResult({
    required this.message,
    required this.consent,
  });

  factory ConsentActionResult.fromJson(Map<String, dynamic> json) {
    return ConsentActionResult(
      message: json['message'] as String,
      consent: ConsentRecord.fromJson(json['consent'] as Map<String, dynamic>),
    );
  }

  final String message;
  final ConsentRecord consent;
}

/// Result from consent status query.
class ConsentStatusResult {
  const ConsentStatusResult({required this.consents});

  factory ConsentStatusResult.fromJson(Map<String, dynamic> json) {
    return ConsentStatusResult(
      consents: (json['consents'] as List)
          .map((c) => ConsentRecord.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<ConsentRecord> consents;
}

// =============================================================================
// Right to Rectification (GDPR Article 16)
// =============================================================================

/// Input for data rectification.
class RectifyDataInput {
  const RectifyDataInput({
    required this.collection,
    required this.documentId,
    required this.fields,
  });

  final String collection;
  final String documentId;
  final Map<String, dynamic> fields;
}

/// Result from data rectification.
class RectifyDataResult {
  const RectifyDataResult({
    required this.message,
    required this.updatedFields,
  });

  factory RectifyDataResult.fromJson(Map<String, dynamic> json) {
    return RectifyDataResult(
      message: json['message'] as String,
      updatedFields: List<String>.from(json['updated_fields'] as List),
    );
  }

  final String message;
  final List<String> updatedFields;
}

// =============================================================================
// Audit Logs (GDPR Article 15)
// =============================================================================

/// Types of auditable actions.
enum AuditAction {
  dataAccess('data_access'),
  dataExport('data_export'),
  dataDeletion('data_deletion'),
  dataRectification('data_rectification'),
  consentGranted('consent_granted'),
  consentWithdrawn('consent_withdrawn'),
  breachNotification('breach_notification');

  const AuditAction(this.value);
  final String value;
}

/// An audit log entry.
class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.userId,
    required this.action,
    required this.createdAt,
    this.details,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      action: json['action'] as String,
      createdAt: json['created_at'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String userId;
  final String action;
  final String createdAt;
  final Map<String, dynamic>? details;
}

/// Result from audit logs query.
class AuditLogsResult {
  const AuditLogsResult({required this.auditLogs});

  factory AuditLogsResult.fromJson(Map<String, dynamic> json) {
    return AuditLogsResult(
      auditLogs: (json['audit_logs'] as List)
          .map((l) => AuditLogEntry.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<AuditLogEntry> auditLogs;
}

/// API usage information.
class Usage {
  const Usage({
    required this.limit,
    required this.used,
    required this.remaining,
  });

  final int limit;
  final int used;
  final int remaining;
}

// =============================================================================
// Breach Management (GDPR Article 33/34)
// =============================================================================

/// Breach severity levels.
enum BreachSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const BreachSeverity(this.value);
  final String value;
}

/// Breach status values.
enum BreachStatusValue {
  detected('detected'),
  investigating('investigating'),
  contained('contained'),
  reported('reported'),
  resolved('resolved');

  const BreachStatusValue(this.value);
  final String value;
}

/// Breach notification status values.
enum BreachNotificationStatusValue {
  pending('pending'),
  usersNotified('users_notified'),
  dpaNotified('dpa_notified'),
  completed('completed');

  const BreachNotificationStatusValue(this.value);
  final String value;
}

/// Input for logging a data breach.
class LogBreachInput {
  const LogBreachInput({
    required this.title,
    required this.description,
    required this.severity,
    required this.affectedUserIds,
    required this.dataCategories,
    required this.reportedBy,
  });

  final String title;
  final String description;
  final BreachSeverity severity;
  final List<String> affectedUserIds;
  final List<String> dataCategories;
  final String reportedBy;
}

/// Input for updating a breach.
class UpdateBreachInput {
  const UpdateBreachInput({
    required this.status,
    this.notificationStatus,
    this.notes,
  });

  final BreachStatusValue status;
  final BreachNotificationStatusValue? notificationStatus;
  final String? notes;
}

/// A breach record.
class BreachRecord {
  const BreachRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.notificationStatus,
    required this.affectedUserIds,
    required this.dataCategories,
    required this.reportedBy,
    required this.notificationDeadline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BreachRecord.fromJson(Map<String, dynamic> json) {
    return BreachRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      notificationStatus: json['notification_status'] as String,
      affectedUserIds: List<String>.from(json['affected_user_ids'] as List),
      dataCategories: List<String>.from(json['data_categories'] as List),
      reportedBy: json['reported_by'] as String,
      notificationDeadline: json['notification_deadline'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  final String id;
  final String title;
  final String description;
  final String severity;
  final String status;
  final String notificationStatus;
  final List<String> affectedUserIds;
  final List<String> dataCategories;
  final String reportedBy;
  final String notificationDeadline;
  final String createdAt;
  final String updatedAt;
}

/// Result from logging a breach.
class LogBreachResult {
  const LogBreachResult({required this.message, required this.breach});

  factory LogBreachResult.fromJson(Map<String, dynamic> json) {
    return LogBreachResult(
      message: json['message'] as String,
      breach: BreachRecord.fromJson(json['breach'] as Map<String, dynamic>),
    );
  }

  final String message;
  final BreachRecord breach;
}

/// Result from listing breaches.
class BreachListResult {
  const BreachListResult({required this.breaches});

  factory BreachListResult.fromJson(Map<String, dynamic> json) {
    return BreachListResult(
      breaches: (json['breaches'] as List)
          .map((b) => BreachRecord.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<BreachRecord> breaches;
}

/// Result from getting/updating a breach.
class BreachResult {
  const BreachResult({required this.breach});

  factory BreachResult.fromJson(Map<String, dynamic> json) {
    return BreachResult(
      breach: BreachRecord.fromJson(json['breach'] as Map<String, dynamic>),
    );
  }

  final BreachRecord breach;
}

// =============================================================================
// Voice Analysis
// =============================================================================

/// A segment of a voice transcription.
class TranscriptionSegment {
  const TranscriptionSegment({
    required this.start,
    required this.end,
    required this.text,
  });

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
    );
  }

  final double start;
  final double end;
  final String text;
}

/// Transcription result from voice analysis.
class TranscriptionResult {
  const TranscriptionResult({
    required this.text,
    this.language,
    this.duration,
    this.segments,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      text: json['text'] as String,
      language: json['language'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      segments: (json['segments'] as List?)
          ?.map((s) => TranscriptionSegment.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  final String text;
  final String? language;
  final double? duration;
  final List<TranscriptionSegment>? segments;
}

/// Result of voice safety analysis.
class VoiceAnalysisResult {
  const VoiceAnalysisResult({
    this.fileId,
    this.transcription,
    this.analysis,
    this.overallRiskScore,
    this.overallSeverity,
    this.externalId,
    this.customerId,
    this.metadata,
    this.creditsUsed,
  });

  factory VoiceAnalysisResult.fromJson(Map<String, dynamic> json) {
    return VoiceAnalysisResult(
      fileId: json['file_id'] as String?,
      transcription: json['transcription'] != null
          ? TranscriptionResult.fromJson(
              json['transcription'] as Map<String, dynamic>)
          : null,
      analysis: json['analysis'] as Map<String, dynamic>?,
      overallRiskScore: (json['overall_risk_score'] as num?)?.toDouble(),
      overallSeverity: json['overall_severity'] as String?,
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
    );
  }

  final String? fileId;
  final TranscriptionResult? transcription;
  final Map<String, dynamic>? analysis;
  final double? overallRiskScore;
  final String? overallSeverity;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

// =============================================================================
// Image Analysis
// =============================================================================

/// Vision analysis result for an image.
class VisionResult {
  const VisionResult({
    this.extractedText,
    this.visualCategories,
    this.visualSeverity,
    this.visualConfidence,
    this.visualDescription,
    this.containsText,
    this.containsFaces,
  });

  factory VisionResult.fromJson(Map<String, dynamic> json) {
    return VisionResult(
      extractedText: json['extracted_text'] as String?,
      visualCategories: (json['visual_categories'] as List?)?.cast<String>(),
      visualSeverity: json['visual_severity'] as String?,
      visualConfidence: (json['visual_confidence'] as num?)?.toDouble(),
      visualDescription: json['visual_description'] as String?,
      containsText: json['contains_text'] as bool?,
      containsFaces: json['contains_faces'] as bool?,
    );
  }

  final String? extractedText;
  final List<String>? visualCategories;
  final String? visualSeverity;
  final double? visualConfidence;
  final String? visualDescription;
  final bool? containsText;
  final bool? containsFaces;
}

/// Result of image safety analysis.
class ImageAnalysisResult {
  const ImageAnalysisResult({
    this.fileId,
    this.vision,
    this.textAnalysis,
    this.overallRiskScore,
    this.overallSeverity,
    this.externalId,
    this.customerId,
    this.metadata,
    this.creditsUsed,
  });

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ImageAnalysisResult(
      fileId: json['file_id'] as String?,
      vision: json['vision'] != null
          ? VisionResult.fromJson(json['vision'] as Map<String, dynamic>)
          : null,
      textAnalysis: json['text_analysis'] as Map<String, dynamic>?,
      overallRiskScore: (json['overall_risk_score'] as num?)?.toDouble(),
      overallSeverity: json['overall_severity'] as String?,
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
    );
  }

  final String? fileId;
  final VisionResult? vision;
  final Map<String, dynamic>? textAnalysis;
  final double? overallRiskScore;
  final String? overallSeverity;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
}

// =============================================================================
// Webhooks
// =============================================================================

/// A webhook configuration.
class Webhook {
  const Webhook({
    required this.id,
    required this.url,
    required this.events,
    required this.active,
    this.secret,
    this.createdAt,
    this.updatedAt,
  });

  factory Webhook.fromJson(Map<String, dynamic> json) {
    return Webhook(
      id: json['id'] as String,
      url: json['url'] as String,
      events: List<String>.from(json['events'] as List),
      active: json['active'] as bool,
      secret: json['secret'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final String id;
  final String url;
  final List<String> events;
  final bool active;
  final String? secret;
  final String? createdAt;
  final String? updatedAt;
}

/// Result from listing webhooks.
class WebhookListResult {
  const WebhookListResult({required this.webhooks});

  factory WebhookListResult.fromJson(Map<String, dynamic> json) {
    return WebhookListResult(
      webhooks: (json['webhooks'] as List)
          .map((w) => Webhook.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<Webhook> webhooks;
}

/// Input for creating a webhook.
class CreateWebhookInput {
  const CreateWebhookInput({
    required this.url,
    required this.events,
    this.active = true,
  });

  final String url;
  final List<String> events;
  final bool active;
}

/// Result from creating a webhook.
class CreateWebhookResult {
  const CreateWebhookResult({required this.message, required this.webhook});

  factory CreateWebhookResult.fromJson(Map<String, dynamic> json) {
    return CreateWebhookResult(
      message: json['message'] as String,
      webhook: Webhook.fromJson(json['webhook'] as Map<String, dynamic>),
    );
  }

  final String message;
  final Webhook webhook;
}

/// Input for updating a webhook.
class UpdateWebhookInput {
  const UpdateWebhookInput({this.url, this.events, this.active});

  final String? url;
  final List<String>? events;
  final bool? active;
}

/// Result from updating a webhook.
class UpdateWebhookResult {
  const UpdateWebhookResult({required this.message, required this.webhook});

  factory UpdateWebhookResult.fromJson(Map<String, dynamic> json) {
    return UpdateWebhookResult(
      message: json['message'] as String,
      webhook: Webhook.fromJson(json['webhook'] as Map<String, dynamic>),
    );
  }

  final String message;
  final Webhook webhook;
}

/// Result from deleting a webhook.
class DeleteWebhookResult {
  const DeleteWebhookResult({required this.message});

  factory DeleteWebhookResult.fromJson(Map<String, dynamic> json) {
    return DeleteWebhookResult(message: json['message'] as String);
  }

  final String message;
}

/// Result from testing a webhook.
class TestWebhookResult {
  const TestWebhookResult({required this.message, this.statusCode});

  factory TestWebhookResult.fromJson(Map<String, dynamic> json) {
    return TestWebhookResult(
      message: json['message'] as String,
      statusCode: json['status_code'] as int?,
    );
  }

  final String message;
  final int? statusCode;
}

/// Result from regenerating a webhook secret.
class RegenerateSecretResult {
  const RegenerateSecretResult({required this.message, required this.secret});

  factory RegenerateSecretResult.fromJson(Map<String, dynamic> json) {
    return RegenerateSecretResult(
      message: json['message'] as String,
      secret: json['secret'] as String,
    );
  }

  final String message;
  final String secret;
}

// =============================================================================
// Pricing
// =============================================================================

/// A pricing plan summary.
class PricingPlan {
  const PricingPlan({
    required this.name,
    required this.price,
    required this.messages,
    required this.features,
  });

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    return PricingPlan(
      name: json['name'] as String,
      price: json['price'] as String,
      messages: json['messages'] as String,
      features: List<String>.from(json['features'] as List),
    );
  }

  final String name;
  final String price;
  final String messages;
  final List<String> features;
}

/// Result from getting pricing overview.
class PricingResult {
  const PricingResult({required this.plans});

  factory PricingResult.fromJson(Map<String, dynamic> json) {
    return PricingResult(
      plans: (json['plans'] as List)
          .map((p) => PricingPlan.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<PricingPlan> plans;
}

/// A detailed pricing plan.
class PricingDetailPlan {
  const PricingDetailPlan({
    required this.name,
    required this.tier,
    required this.price,
    required this.limits,
    required this.features,
    required this.endpoints,
  });

  factory PricingDetailPlan.fromJson(Map<String, dynamic> json) {
    return PricingDetailPlan(
      name: json['name'] as String,
      tier: json['tier'] as String,
      price: json['price'] as Map<String, dynamic>,
      limits: json['limits'] as Map<String, dynamic>,
      features: json['features'] as Map<String, dynamic>,
      endpoints: List<String>.from(json['endpoints'] as List),
    );
  }

  final String name;
  final String tier;
  final Map<String, dynamic> price;
  final Map<String, dynamic> limits;
  final Map<String, dynamic> features;
  final List<String> endpoints;
}

/// Result from getting pricing details.
class PricingDetailsResult {
  const PricingDetailsResult({required this.plans});

  factory PricingDetailsResult.fromJson(Map<String, dynamic> json) {
    return PricingDetailsResult(
      plans: (json['plans'] as List)
          .map((p) => PricingDetailPlan.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<PricingDetailPlan> plans;
}

// =============================================================================
// Usage
// =============================================================================

/// A single day of usage data.
class UsageDay {
  const UsageDay({
    required this.date,
    required this.totalRequests,
    required this.successRequests,
    required this.errorRequests,
  });

  factory UsageDay.fromJson(Map<String, dynamic> json) {
    return UsageDay(
      date: json['date'] as String,
      totalRequests: json['total_requests'] as int,
      successRequests: json['success_requests'] as int,
      errorRequests: json['error_requests'] as int,
    );
  }

  final String date;
  final int totalRequests;
  final int successRequests;
  final int errorRequests;
}

/// Result from getting usage history.
class UsageHistoryResult {
  const UsageHistoryResult({required this.apiKeyId, required this.days});

  factory UsageHistoryResult.fromJson(Map<String, dynamic> json) {
    return UsageHistoryResult(
      apiKeyId: json['api_key_id'] as String,
      days: (json['days'] as List)
          .map((d) => UsageDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  final String apiKeyId;
  final List<UsageDay> days;
}

/// Result from getting usage broken down by tool.
class UsageByToolResult {
  const UsageByToolResult({
    required this.date,
    required this.tools,
    required this.endpoints,
  });

  factory UsageByToolResult.fromJson(Map<String, dynamic> json) {
    return UsageByToolResult(
      date: json['date'] as String,
      tools: Map<String, int>.from(json['tools'] as Map),
      endpoints: Map<String, int>.from(json['endpoints'] as Map),
    );
  }

  final String date;
  final Map<String, int> tools;
  final Map<String, int> endpoints;
}

/// Result from getting monthly usage summary.
class UsageMonthlyResult {
  const UsageMonthlyResult({
    required this.tier,
    required this.tierDisplayName,
    required this.billing,
    required this.usage,
    required this.rateLimit,
    this.recommendations,
    required this.links,
  });

  factory UsageMonthlyResult.fromJson(Map<String, dynamic> json) {
    return UsageMonthlyResult(
      tier: json['tier'] as String,
      tierDisplayName: json['tier_display_name'] as String,
      billing: json['billing'] as Map<String, dynamic>,
      usage: json['usage'] as Map<String, dynamic>,
      rateLimit: json['rate_limit'] as Map<String, dynamic>,
      recommendations: json['recommendations'] as Map<String, dynamic>?,
      links: json['links'] as Map<String, dynamic>,
    );
  }

  final String tier;
  final String tierDisplayName;
  final Map<String, dynamic> billing;
  final Map<String, dynamic> usage;
  final Map<String, dynamic> rateLimit;
  final Map<String, dynamic>? recommendations;
  final Map<String, dynamic> links;
}
