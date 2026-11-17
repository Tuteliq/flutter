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

/// Input for fraud/safety detection endpoints.
class DetectionInput {
  const DetectionInput({
    required this.content,
    this.context,
    this.includeEvidence = false,
    this.externalId,
    this.customerId,
    this.metadata,
  });

  final String content;
  final AnalysisContext? context;
  final bool includeEvidence;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
}

/// Input for multi-endpoint analysis.
class AnalyseMultiInput {
  const AnalyseMultiInput({
    required this.content,
    required this.detections,
    this.context,
    this.includeEvidence = false,
    this.externalId,
    this.customerId,
    this.metadata,
  });

  final String content;
  final List<Detection> detections;
  final AnalysisContext? context;
  final bool includeEvidence;
  final String? externalId;
  final String? customerId;
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
    this.language,
    this.languageStatus,
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
      language: json['language'] as String?,
      languageStatus: json['language_status'] as String?,
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
  final String? language;
  final String? languageStatus;
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
    this.messageAnalysis,
    this.externalId,
    this.metadata,
    this.creditsUsed,
    this.language,
    this.languageStatus,
  });

  factory GroomingResult.fromJson(Map<String, dynamic> json) {
    return GroomingResult(
      groomingRisk: GroomingRisk.fromString(json['grooming_risk'] as String),
      flags: List<String>.from(json['flags'] as List),
      confidence: (json['confidence'] as num).toDouble(),
      rationale: json['rationale'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      recommendedAction: json['recommended_action'] as String,
      messageAnalysis: (json['message_analysis'] as List?)
          ?.map((e) => MessageAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      externalId: json['external_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      creditsUsed: json['credits_used'] as int?,
      language: json['language'] as String?,
      languageStatus: json['language_status'] as String?,
    );
  }

  final GroomingRisk groomingRisk;
  final List<String> flags;
  final double confidence;
  final String rationale;
  final double riskScore;
  final String recommendedAction;
  final List<MessageAnalysis>? messageAnalysis;
  final String? externalId;
  final Map<String, dynamic>? metadata;
  final int? creditsUsed;
  final String? language;
  final String? languageStatus;
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
    this.language,
    this.languageStatus,
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
      language: json['language'] as String?,
      languageStatus: json['language_status'] as String?,
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
  final String? language;
  final String? languageStatus;
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
// Detection Results (Fraud & Safety Extended)
// =============================================================================

/// Per-message analysis from conversation-aware detection.
class MessageAnalysis {
  const MessageAnalysis({
    required this.messageIndex,
    required this.riskScore,
    required this.flags,
    required this.summary,
  });

  factory MessageAnalysis.fromJson(Map<String, dynamic> json) {
    return MessageAnalysis(
      messageIndex: json['message_index'] as int,
      riskScore: (json['risk_score'] as num).toDouble(),
      flags: List<String>.from(json['flags'] as List),
      summary: json['summary'] as String,
    );
  }

  final int messageIndex;
  final double riskScore;
  final List<String> flags;
  final String summary;
}

/// A detection category with confidence score.
class DetectionCategory {
  const DetectionCategory({
    required this.tag,
    required this.label,
    required this.confidence,
  });

  factory DetectionCategory.fromJson(Map<String, dynamic> json) {
    return DetectionCategory(
      tag: json['tag'] as String,
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  final String tag;
  final String label;
  final double confidence;
}

/// Evidence item from detection analysis.
class DetectionEvidence {
  const DetectionEvidence({
    required this.text,
    required this.tactic,
    required this.weight,
  });

  factory DetectionEvidence.fromJson(Map<String, dynamic> json) {
    return DetectionEvidence(
      text: json['text'] as String,
      tactic: json['tactic'] as String,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  final String text;
  final String tactic;
  final double weight;
}

/// Age calibration information.
class AgeCalibration {
  const AgeCalibration({
    required this.applied,
    this.ageGroup,
    this.multiplier,
  });

  factory AgeCalibration.fromJson(Map<String, dynamic> json) {
    return AgeCalibration(
      applied: json['applied'] as bool,
      ageGroup: json['age_group'] as String?,
      multiplier: (json['multiplier'] as num?)?.toDouble(),
    );
  }

  final bool applied;
  final String? ageGroup;
  final double? multiplier;
}

/// Result from a detection endpoint (fraud or safety extended).
class DetectionResult {
  const DetectionResult({
    required this.endpoint,
    required this.detected,
    required this.severity,
    required this.confidence,
    required this.riskScore,
    required this.level,
    required this.categories,
    required this.recommendedAction,
    required this.rationale,
    required this.language,
    required this.languageStatus,
    this.evidence,
    this.ageCalibration,
    this.messageAnalysis,
    this.creditsUsed,
    this.processingTimeMs,
    this.externalId,
    this.customerId,
    this.metadata,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      endpoint: json['endpoint'] as String,
      detected: json['detected'] as bool,
      severity: (json['severity'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      riskScore: (json['risk_score'] as num).toDouble(),
      level: json['level'] as String,
      categories: (json['categories'] as List)
          .map((e) => DetectionCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedAction: json['recommended_action'] as String,
      rationale: json['rationale'] as String,
      language: json['language'] as String,
      languageStatus: json['language_status'] as String,
      evidence: (json['evidence'] as List?)
          ?.map((e) => DetectionEvidence.fromJson(e as Map<String, dynamic>))
          .toList(),
      ageCalibration: json['age_calibration'] != null
          ? AgeCalibration.fromJson(json['age_calibration'] as Map<String, dynamic>)
          : null,
      messageAnalysis: (json['message_analysis'] as List?)
          ?.map((e) => MessageAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      creditsUsed: json['credits_used'] as int?,
      processingTimeMs: (json['processing_time_ms'] as num?)?.toDouble(),
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String endpoint;
  final bool detected;
  final double severity;
  final double confidence;
  final double riskScore;
  final String level;
  final List<DetectionCategory> categories;
  final String recommendedAction;
  final String rationale;
  final String language;
  final String languageStatus;
  final List<DetectionEvidence>? evidence;
  final AgeCalibration? ageCalibration;
  final List<MessageAnalysis>? messageAnalysis;
  final int? creditsUsed;
  final double? processingTimeMs;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
}

// =============================================================================
// Multi-Endpoint Analysis
// =============================================================================

/// Summary of multi-endpoint analysis.
class AnalyseMultiSummary {
  const AnalyseMultiSummary({
    required this.totalEndpoints,
    required this.detectedCount,
    required this.highestRisk,
    required this.overallRiskLevel,
  });

  factory AnalyseMultiSummary.fromJson(Map<String, dynamic> json) {
    return AnalyseMultiSummary(
      totalEndpoints: json['total_endpoints'] as int,
      detectedCount: json['detected_count'] as int,
      highestRisk: json['highest_risk'] as Map<String, dynamic>,
      overallRiskLevel: json['overall_risk_level'] as String,
    );
  }

  final int totalEndpoints;
  final int detectedCount;
  final Map<String, dynamic> highestRisk;
  final String overallRiskLevel;
}

/// Result of multi-endpoint analysis.
class AnalyseMultiResult {
  const AnalyseMultiResult({
    required this.results,
    required this.summary,
    this.crossEndpointModifier,
    this.creditsUsed,
    this.externalId,
    this.customerId,
    this.metadata,
  });

  factory AnalyseMultiResult.fromJson(Map<String, dynamic> json) {
    return AnalyseMultiResult(
      results: (json['results'] as List)
          .map((e) => DetectionResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: AnalyseMultiSummary.fromJson(json['summary'] as Map<String, dynamic>),
      crossEndpointModifier: (json['cross_endpoint_modifier'] as num?)?.toDouble(),
      creditsUsed: json['credits_used'] as int?,
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final List<DetectionResult> results;
  final AnalyseMultiSummary summary;
  final double? crossEndpointModifier;
  final int? creditsUsed;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
}

// =============================================================================
// Video Analysis
// =============================================================================

/// A safety finding from video analysis.
class VideoSafetyFinding {
  const VideoSafetyFinding({
    required this.frameIndex,
    required this.timestamp,
    required this.description,
    required this.categories,
    required this.severity,
  });

  factory VideoSafetyFinding.fromJson(Map<String, dynamic> json) {
    return VideoSafetyFinding(
      frameIndex: json['frame_index'] as int,
      timestamp: (json['timestamp'] as num).toDouble(),
      description: json['description'] as String,
      categories: (json['categories'] as List).cast<String>(),
      severity: (json['severity'] as num).toDouble(),
    );
  }

  final int frameIndex;
  final double timestamp;
  final String description;
  final List<String> categories;
  final double severity;
}

/// Result of video safety analysis.
class VideoAnalysisResult {
  const VideoAnalysisResult({
    this.fileId,
    required this.framesAnalyzed,
    required this.safetyFindings,
    required this.overallRiskScore,
    required this.overallSeverity,
    this.creditsUsed,
    this.externalId,
    this.customerId,
    this.metadata,
  });

  factory VideoAnalysisResult.fromJson(Map<String, dynamic> json) {
    return VideoAnalysisResult(
      fileId: json['file_id'] as String?,
      framesAnalyzed: json['frames_analyzed'] as int,
      safetyFindings: (json['safety_findings'] as List)
          .map((e) => VideoSafetyFinding.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallRiskScore: (json['overall_risk_score'] as num).toDouble(),
      overallSeverity: json['overall_severity'] as String,
      creditsUsed: json['credits_used'] as int?,
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String? fileId;
  final int framesAnalyzed;
  final List<VideoSafetyFinding> safetyFindings;
  final double overallRiskScore;
  final String overallSeverity;
  final int? creditsUsed;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
}

// =============================================================================
// Webhooks
// =============================================================================

/// Webhook event types.
class WebhookEventType {
  WebhookEventType._();

  static const String incidentCritical = 'incident.critical';
  static const String incidentHigh = 'incident.high';
  static const String groomingDetected = 'grooming.detected';
  static const String selfHarmDetected = 'self_harm.detected';
  static const String bullyingSevere = 'bullying.severe';
  static const String verificationCompleted = 'verification.completed';
  static const String minorDetected = 'minor.detected';
  static const String csamDetected = 'csam.detected';
  static const String csamCritical = 'csam.critical';

  /// Every event type the API accepts.
  static const List<String> values = [
    incidentCritical,
    incidentHigh,
    groomingDetected,
    selfHarmDetected,
    bullyingSevere,
    verificationCompleted,
    minorDetected,
    csamDetected,
    csamCritical,
  ];
}

/// A webhook configuration.
class Webhook {
  const Webhook({
    required this.id,
    required this.url,
    required this.events,
    required this.active,
    this.name,
    this.secret,
    this.failureCount,
    this.lastTriggeredAt,
    this.lastError,
    this.createdAt,
    this.updatedAt,
  });

  factory Webhook.fromJson(Map<String, dynamic> json) {
    return Webhook(
      id: json['id'] as String,
      name: json['name'] as String?,
      url: json['url'] as String,
      events: List<String>.from(json['events'] as List? ?? const []),
      active: json['is_active'] as bool? ?? false,
      secret: json['secret'] as String?,
      failureCount: (json['failure_count'] as num?)?.toInt(),
      lastTriggeredAt: json['last_triggered_at'] as String?,
      lastError: json['last_error'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final String id;
  final String? name;
  final String url;
  final List<String> events;

  /// Whether the webhook receives deliveries (`is_active` in the API).
  final bool active;

  /// The signing secret. Present only when the webhook is created.
  final String? secret;
  final int? failureCount;
  final String? lastTriggeredAt;
  final String? lastError;
  final String? createdAt;
  final String? updatedAt;
}

/// Result from listing webhooks.
class WebhookListResult {
  const WebhookListResult({required this.webhooks});

  factory WebhookListResult.fromJson(Map<String, dynamic> json) {
    return WebhookListResult(
      webhooks: (json['webhooks'] as List? ?? const [])
          .map((w) => Webhook.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<Webhook> webhooks;
}

/// Input for creating a webhook.
class CreateWebhookInput {
  const CreateWebhookInput({
    required this.name,
    required this.url,
    required this.events,
    this.headers,
    @Deprecated('New webhooks are always active; use updateWebhook to pause one.')
    this.active = true,
  });

  /// A name for the webhook (1 to 100 characters).
  final String name;

  /// The HTTPS endpoint that receives deliveries.
  final String url;

  /// One to five event types; see [WebhookEventType].
  final List<String> events;

  /// Extra headers sent with every delivery.
  final Map<String, String>? headers;

  /// Not sent: the API creates every webhook active.
  final bool active;
}

/// Result from creating a webhook.
class CreateWebhookResult {
  const CreateWebhookResult({required this.webhook, this.message});

  factory CreateWebhookResult.fromJson(Map<String, dynamic> json) {
    return CreateWebhookResult(
      webhook: Webhook.fromJson(json),
      message: json['message'] as String?,
    );
  }

  /// The created webhook, including its signing secret.
  final Webhook webhook;
  final String? message;
}

/// Input for updating a webhook. Only the fields that are set are sent.
class UpdateWebhookInput {
  const UpdateWebhookInput({
    this.name,
    this.url,
    this.events,
    this.active,
    this.headers,
  });

  final String? name;
  final String? url;
  final List<String>? events;

  /// Sent as `is_active`.
  final bool? active;
  final Map<String, String>? headers;
}

/// Result from updating a webhook.
class UpdateWebhookResult {
  const UpdateWebhookResult({required this.webhook, this.message});

  factory UpdateWebhookResult.fromJson(Map<String, dynamic> json) {
    return UpdateWebhookResult(
      webhook: Webhook.fromJson(json),
      message: json['message'] as String?,
    );
  }

  final Webhook webhook;
  final String? message;
}

/// Result from deleting a webhook.
class DeleteWebhookResult {
  const DeleteWebhookResult({required this.success, this.message});

  factory DeleteWebhookResult.fromJson(Map<String, dynamic> json) {
    return DeleteWebhookResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  final bool success;
  final String? message;
}

/// Result from testing a webhook.
class TestWebhookResult {
  const TestWebhookResult({
    required this.success,
    this.statusCode,
    this.latencyMs,
    this.error,
  });

  factory TestWebhookResult.fromJson(Map<String, dynamic> json) {
    return TestWebhookResult(
      success: json['success'] as bool? ?? false,
      statusCode: (json['status_code'] as num?)?.toInt(),
      latencyMs: (json['latency_ms'] as num?)?.toInt(),
      error: json['error'] as String?,
    );
  }

  /// Whether the endpoint answered with a 2xx status.
  final bool success;
  final int? statusCode;
  final int? latencyMs;
  final String? error;
}

/// Result from regenerating a webhook secret.
class RegenerateSecretResult {
  const RegenerateSecretResult({required this.secret});

  factory RegenerateSecretResult.fromJson(Map<String, dynamic> json) {
    return RegenerateSecretResult(secret: json['secret'] as String);
  }

  /// The new signing secret, which replaces the previous one.
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

// =============================================================================
// Document Analysis
// =============================================================================

/// Breakdown of how text was extracted from the document.
class DocumentExtractionSummary {
  const DocumentExtractionSummary({
    required this.textLayerPages,
    required this.ocrPages,
    required this.failedPages,
    required this.averageOcrConfidence,
  });

  factory DocumentExtractionSummary.fromJson(Map<String, dynamic> json) {
    return DocumentExtractionSummary(
      textLayerPages: _optInt(json['text_layer_pages']) ?? 0,
      ocrPages: _optInt(json['ocr_pages']) ?? 0,
      failedPages: _optInt(json['failed_pages']) ?? 0,
      averageOcrConfidence: (json['average_ocr_confidence'] as num).toDouble(),
    );
  }

  final int textLayerPages;
  final int ocrPages;
  final int failedPages;
  final double averageOcrConfidence;
}

/// Detection result for a single endpoint on a single page.
class DocumentPageEndpointResult {
  const DocumentPageEndpointResult({
    required this.endpoint,
    required this.detected,
    required this.severity,
    required this.confidence,
    required this.riskScore,
    required this.level,
    required this.categories,
    required this.evidence,
    required this.recommendedAction,
    required this.rationale,
    this.detectedLanguage,
  });

  factory DocumentPageEndpointResult.fromJson(Map<String, dynamic> json) {
    return DocumentPageEndpointResult(
      endpoint: json['endpoint'] as String,
      detected: json['detected'] as bool,
      severity: (json['severity'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      riskScore: (json['risk_score'] as num).toDouble(),
      level: json['level'] as String,
      categories: (json['categories'] as List)
          .map((e) => DetectionCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      evidence: (json['evidence'] as List)
          .map((e) => DetectionEvidence.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedAction: json['recommended_action'] as String,
      rationale: json['rationale'] as String,
      detectedLanguage: json['detected_language'] as String?,
    );
  }

  final String endpoint;
  final bool detected;
  final double severity;
  final double confidence;
  final double riskScore;
  final String level;
  final List<DetectionCategory> categories;
  final List<DetectionEvidence> evidence;
  final String recommendedAction;
  final String rationale;
  final String? detectedLanguage;
}

/// Detection results for a single page.
class DocumentPageResult {
  const DocumentPageResult({
    required this.pageNumber,
    required this.textPreview,
    required this.extractionMethod,
    this.ocrConfidence,
    required this.results,
    required this.pageRiskScore,
    required this.pageSeverity,
  });

  factory DocumentPageResult.fromJson(Map<String, dynamic> json) {
    return DocumentPageResult(
      pageNumber: _optInt(json['page_number']) ?? 0,
      textPreview: json['text_preview'] as String,
      extractionMethod: json['extraction_method'] as String,
      ocrConfidence: _optDouble(json['ocr_confidence']),
      results: (json['results'] as List)
          .map((e) => DocumentPageEndpointResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageRiskScore: (json['page_risk_score'] as num).toDouble(),
      pageSeverity: json['page_severity'] as String,
    );
  }

  final int pageNumber;
  final String textPreview;
  final String extractionMethod;
  final double? ocrConfidence;
  final List<DocumentPageEndpointResult> results;
  final double pageRiskScore;
  final String pageSeverity;
}

/// A page the analysis flagged.
class DocumentFlaggedPage {
  const DocumentFlaggedPage({
    required this.pageNumber,
    required this.riskScore,
    required this.severity,
    required this.detectedEndpoints,
  });

  factory DocumentFlaggedPage.fromJson(Map<String, dynamic> json) {
    return DocumentFlaggedPage(
      pageNumber: _optInt(json['page_number']) ?? 0,
      riskScore: (json['risk_score'] as num).toDouble(),
      severity: json['severity'] as String,
      detectedEndpoints: (json['detected_endpoints'] as List).cast<String>(),
    );
  }

  final int pageNumber;
  final double riskScore;
  final String severity;
  final List<String> detectedEndpoints;
}

/// Result of document (PDF) safety analysis.
class DocumentAnalysisResult {
  const DocumentAnalysisResult({
    this.fileId,
    required this.documentHash,
    required this.totalPages,
    required this.pagesAnalyzed,
    required this.extractionSummary,
    required this.pageResults,
    required this.overallRiskScore,
    required this.overallSeverity,
    required this.detectedEndpoints,
    required this.flaggedPages,
    required this.creditsUsed,
    required this.processingTimeMs,
    this.language,
    this.languageStatus,
    this.support,
    this.externalId,
    this.customerId,
    this.metadata,
  });

  factory DocumentAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DocumentAnalysisResult(
      fileId: json['file_id'] as String?,
      documentHash: json['document_hash'] as String,
      totalPages: _optInt(json['total_pages']) ?? 0,
      pagesAnalyzed: _optInt(json['pages_analyzed']) ?? 0,
      extractionSummary: DocumentExtractionSummary.fromJson(
          json['extraction_summary'] as Map<String, dynamic>),
      pageResults: (json['page_results'] as List)
          .map((e) => DocumentPageResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallRiskScore: (json['overall_risk_score'] as num).toDouble(),
      overallSeverity: json['overall_severity'] as String,
      detectedEndpoints: (json['detected_endpoints'] as List).cast<String>(),
      flaggedPages: (json['flagged_pages'] as List)
          .map((e) => DocumentFlaggedPage.fromJson(e as Map<String, dynamic>))
          .toList(),
      creditsUsed: _optInt(json['credits_used']) ?? 0,
      processingTimeMs: _optInt(json['processing_time_ms']) ?? 0,
      language: json['language'] as String?,
      languageStatus: json['language_status'] as String?,
      support: json['support'] as Map<String, dynamic>?,
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String? fileId;
  final String documentHash;
  final int totalPages;
  final int pagesAnalyzed;
  final DocumentExtractionSummary extractionSummary;
  final List<DocumentPageResult> pageResults;
  final double overallRiskScore;
  final String overallSeverity;
  final List<String> detectedEndpoints;
  final List<DocumentFlaggedPage> flaggedPages;
  final int creditsUsed;
  final int processingTimeMs;
  final String? language;
  final String? languageStatus;
  final Map<String, dynamic>? support;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
}

// =============================================================================
// JSON helpers
// =============================================================================

double? _optDouble(Object? value) => (value as num?)?.toDouble();

int? _optInt(Object? value) => (value as num?)?.toInt();

List<String> _stringList(Object? value) =>
    value is List ? value.map((e) => e.toString()).toList() : const [];

Map<String, dynamic>? _optMap(Object? value) =>
    value is Map<String, dynamic> ? value : null;

List<Map<String, dynamic>> _mapList(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : const [];

// =============================================================================
// Verification Sessions
// =============================================================================

/// Input for creating a hosted age or identity verification session.
class CreateVerificationSessionInput {
  const CreateVerificationSessionInput({
    this.mode = VerificationMode.age,
    this.documentType,
    this.chipPolicy,
    this.autoCapture,
  });

  /// Age verification or full identity verification.
  final VerificationMode mode;

  /// Restricts the session to one document type.
  final VerificationDocumentType? documentType;

  /// How a passport or ID card chip read counts as document evidence.
  /// The API defaults to [ChipPolicy.optional].
  final ChipPolicy? chipPolicy;

  /// Whether the hosted page takes the document photo itself once the
  /// document is framed. The API defaults to `true`.
  final bool? autoCapture;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'mode': mode.value};
    if (documentType != null) map['document_type'] = documentType!.value;
    if (chipPolicy != null && chipPolicy != ChipPolicy.unknown) {
      map['chip_policy'] = chipPolicy!.value;
    }
    if (autoCapture != null) map['auto_capture'] = autoCapture;
    return map;
  }
}

/// A newly created verification session.
class VerificationSession {
  const VerificationSession({
    required this.sessionId,
    required this.mobileUrl,
    required this.expiresAt,
    required this.mode,
    this.verificationMode,
    this.chipPolicy,
    this.autoCapture,
    this.recommendedImageWidth,
  });

  factory VerificationSession.fromJson(Map<String, dynamic> json) {
    return VerificationSession(
      sessionId: json['session_id'] as String,
      mobileUrl: json['mobile_url'] as String,
      expiresAt: _optInt(json['expires_at']) ?? 0,
      mode: json['mode'] as String? ?? '',
      verificationMode: json['verification_mode'] as String?,
      chipPolicy: json['chip_policy'] == null
          ? null
          : ChipPolicy.fromString(json['chip_policy'] as String?),
      autoCapture: json['auto_capture'] as bool?,
      recommendedImageWidth: _optInt(json['recommended_image_width']),
    );
  }

  final String sessionId;

  /// The hosted page to open on the user's phone (or show as a QR code).
  final String mobileUrl;

  /// When the session expires, in milliseconds since the epoch.
  final int expiresAt;

  /// `age` or `identity`.
  final String mode;

  /// `full` (document and live face) or `liveness_only`.
  final String? verificationMode;
  final ChipPolicy? chipPolicy;
  final bool? autoCapture;

  /// The capture width, in pixels, the API recommends for uploads.
  final int? recommendedImageWidth;

  /// [expiresAt] as a [DateTime].
  DateTime get expiresAtTime =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt, isUtc: true);
}

/// Face match outcome of a verification.
class VerificationFaceMatch {
  const VerificationFaceMatch({
    required this.matched,
    this.confidence,
    this.matchScore,
  });

  factory VerificationFaceMatch.fromJson(Map<String, dynamic> json) {
    return VerificationFaceMatch(
      matched: json['matched'] as bool? ?? false,
      confidence: _optDouble(json['confidence']),
      matchScore: _optDouble(json['match_score']),
    );
  }

  final bool matched;

  /// Kept for compatibility; prefer [matchScore].
  final double? confidence;

  /// How strongly the faces match, from 0.0 to 1.0: 0.5 at the match
  /// threshold, high for a clear match, near 0 for different people.
  final double? matchScore;
}

/// Outcome of a completed or failed verification session.
class VerificationResult {
  const VerificationResult({
    this.status,
    this.age,
    this.ageRangeLow,
    this.ageRangeHigh,
    this.isMinor,
    this.documentEvidence,
    this.faceMatch,
    this.livenessValid,
    this.dateOfBirth,
    this.failureReasons = const [],
    this.document,
  });

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    final ageRange = _optMap(json['age_range']);
    final faceMatch = _optMap(json['face_match']);
    return VerificationResult(
      status: json['status'] as String?,
      age: _optDouble(json['age']),
      ageRangeLow: _optDouble(ageRange?['low']),
      ageRangeHigh: _optDouble(ageRange?['high']),
      isMinor: json['is_minor'] as bool?,
      documentEvidence: json['document_evidence'] as String?,
      faceMatch:
          faceMatch == null ? null : VerificationFaceMatch.fromJson(faceMatch),
      livenessValid: _optMap(json['liveness'])?['valid'] as bool?,
      dateOfBirth: json['date_of_birth'] as String?,
      failureReasons: _stringList(json['failure_reasons']),
      document: _optMap(json['document']),
    );
  }

  final String? status;
  final double? age;

  /// When the age came from the selfie alone: the range the true age falls
  /// in about 8 cases out of 10.
  final double? ageRangeLow;
  final double? ageRangeHigh;
  final bool? isMinor;

  /// `photo`, `chip` or `photo_and_chip`.
  final String? documentEvidence;
  final VerificationFaceMatch? faceMatch;
  final bool? livenessValid;
  final String? dateOfBirth;
  final List<String> failureReasons;

  /// Document details. The extracted identity fields are returned once, to
  /// the API key that created the session, and are absent on later polls.
  final Map<String, dynamic>? document;
}

/// Status and outcome of a verification session.
class VerificationSessionResult {
  const VerificationSessionResult({
    required this.sessionId,
    required this.status,
    required this.rawStatus,
    this.result,
    this.verificationMode,
    this.documentEvidence,
    this.stepProgress,
    this.chipPolicy,
    this.capture,
    this.createdAt,
    this.expiresAt,
  });

  factory VerificationSessionResult.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? '';
    final result = _optMap(json['result']);
    return VerificationSessionResult(
      sessionId: json['session_id'] as String,
      status: VerificationSessionStatus.fromString(rawStatus),
      rawStatus: rawStatus,
      result: result == null ? null : VerificationResult.fromJson(result),
      verificationMode: json['verification_mode'] as String?,
      documentEvidence: json['document_evidence'] as String?,
      stepProgress: json['step_progress'] as String?,
      chipPolicy: json['chip_policy'] == null
          ? null
          : ChipPolicy.fromString(json['chip_policy'] as String?),
      capture: _optMap(json['capture']),
      createdAt: _optInt(json['created_at']),
      expiresAt: _optInt(json['expires_at']),
    );
  }

  final String sessionId;
  final VerificationSessionStatus status;

  /// The status exactly as the API sent it, for values newer than the SDK.
  final String rawStatus;
  final VerificationResult? result;
  final String? verificationMode;
  final String? documentEvidence;

  /// The step the user has reached, for showing progress while polling.
  final String? stepProgress;
  final ChipPolicy? chipPolicy;

  /// How the uploads were captured, as the client reported it.
  final Map<String, dynamic>? capture;

  /// Milliseconds since the epoch.
  final int? createdAt;

  /// Milliseconds since the epoch.
  final int? expiresAt;
}

// =============================================================================
// Image Match
// =============================================================================

/// Checks that verifyImageMatch can run.
class ImageMatchCheck {
  ImageMatchCheck._();

  static const String faceMatch = 'face_match';
  static const String age = 'age';
  static const String forensic = 'forensic';
  static const String synthetic = 'synthetic';
}

/// Face match outcome of an image match.
class ImageFaceMatch {
  const ImageFaceMatch({
    required this.matched,
    this.similarity,
    this.matchScore,
    this.reason,
  });

  factory ImageFaceMatch.fromJson(Map<String, dynamic> json) {
    return ImageFaceMatch(
      matched: json['matched'] as bool? ?? false,
      similarity: _optDouble(json['similarity']),
      matchScore: _optDouble(json['match_score']),
      reason: json['reason'] as String?,
    );
  }

  final bool matched;
  final double? similarity;
  final double? matchScore;
  final String? reason;
}

/// Result of verifyImageMatch.
class VerifyImageMatchResult {
  const VerifyImageMatchResult({
    required this.schemaVersion,
    required this.checksRun,
    this.faceMatch,
    this.estimatedAge,
    this.ageConfidence,
    this.forensic,
    this.synthetic,
    this.creditsUsed,
    this.processingMs,
    this.externalId,
    this.customerId,
    this.metadata,
  });

  factory VerifyImageMatchResult.fromJson(Map<String, dynamic> json) {
    final faceMatch = _optMap(json['face_match']);
    final age = _optMap(json['age']);
    return VerifyImageMatchResult(
      schemaVersion: json['schema_version'] as String? ?? '',
      checksRun: _stringList(json['checks_run']),
      faceMatch: faceMatch == null ? null : ImageFaceMatch.fromJson(faceMatch),
      estimatedAge: _optDouble(age?['estimated_age']),
      ageConfidence: _optDouble(age?['confidence']),
      forensic: _optMap(json['forensic']),
      synthetic: _optMap(json['synthetic']),
      creditsUsed: _optInt(json['credits_used']),
      processingMs: _optInt(json['processing_ms']),
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      metadata: _optMap(json['metadata']),
    );
  }

  final String schemaVersion;

  /// The checks that ran. `face_match` runs only with a reference image.
  final List<String> checksRun;
  final ImageFaceMatch? faceMatch;
  final double? estimatedAge;
  final double? ageConfidence;
  final Map<String, dynamic>? forensic;
  final Map<String, dynamic>? synthetic;
  final int? creditsUsed;
  final int? processingMs;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
}

// =============================================================================
// Incidents
// =============================================================================

/// Filters for listing incidents. Every field is optional.
class ListIncidentsInput {
  const ListIncidentsInput({
    this.category,
    this.severity,
    this.status,
    this.source,
    this.from,
    this.to,
    this.platform,
    this.externalId,
    this.customerId,
    this.limit,
    this.cursor,
    this.includeSummary = false,
  });

  /// Risk category, for example `bullying` or `grooming`.
  final String? category;

  /// `low`, `medium`, `high` or `critical`.
  final String? severity;

  /// `new`, `reviewed`, `escalated`, `resolved` or `dismissed`.
  final String? status;

  /// `text`, `voice`, `image`, `video` or `video_stream`.
  final String? source;

  /// ISO 8601 inclusive lower bound on the creation time.
  final String? from;

  /// ISO 8601 exclusive upper bound on the creation time.
  final String? to;
  final String? platform;
  final String? externalId;
  final String? customerId;

  /// 1 to 100; the API defaults to 25.
  final int? limit;

  /// The `nextCursor` of the previous page.
  final String? cursor;

  /// Includes each incident's summary (extra credits per row).
  final bool includeSummary;

  Map<String, String> toQuery() {
    final query = <String, String>{};
    if (category != null) query['category'] = category!;
    if (severity != null) query['severity'] = severity!;
    if (status != null) query['status'] = status!;
    if (source != null) query['source'] = source!;
    if (from != null) query['from'] = from!;
    if (to != null) query['to'] = to!;
    if (platform != null) query['platform'] = platform!;
    if (externalId != null) query['external_id'] = externalId!;
    if (customerId != null) query['customer_id'] = customerId!;
    if (limit != null) query['limit'] = limit.toString();
    if (cursor != null) query['cursor'] = cursor!;
    if (includeSummary) query['include_summary'] = 'true';
    return query;
  }
}

/// An incident recorded for the account.
///
/// List rows carry the summary fields; `getIncident` also fills the detail
/// fields. Every field the API sends is kept in [raw].
class Incident {
  const Incident({
    required this.id,
    required this.riskCategory,
    required this.riskLevel,
    required this.status,
    required this.raw,
    this.confidenceScore,
    this.detectedPatterns = const [],
    this.recommendedActions = const [],
    this.platform,
    this.language,
    this.source,
    this.fileId,
    this.recommendedStatus,
    this.speakerStance,
    this.isTest,
    this.externalId,
    this.customerId,
    this.createdAt,
    this.summary,
    this.review,
    this.e2eEnvelopeFields = const [],
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      riskCategory: json['risk_category'] as String? ?? '',
      riskLevel: json['risk_level'] as String? ?? '',
      status: json['status'] as String? ?? '',
      confidenceScore: _optDouble(json['confidence_score']),
      detectedPatterns: _stringList(json['detected_patterns']),
      recommendedActions: _stringList(json['recommended_actions']),
      platform: json['platform'] as String?,
      language: json['language'] as String?,
      source: json['source'] as String?,
      fileId: json['file_id'] as String?,
      recommendedStatus: json['recommended_status'] as String?,
      speakerStance: json['speaker_stance'] as String?,
      isTest: json['is_test'] as bool?,
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      createdAt: json['created_at'] as String?,
      summary: json['summary'],
      review: _optMap(json['review']),
      e2eEnvelopeFields: _stringList(json['_e2e_envelope_fields']),
      raw: json,
    );
  }

  final String id;
  final String riskCategory;

  /// `low`, `moderate`, `high` or `critical`.
  final String riskLevel;
  final String status;
  final double? confidenceScore;
  final List<String> detectedPatterns;
  final List<String> recommendedActions;
  final String? platform;
  final String? language;
  final String? source;
  final String? fileId;
  final String? recommendedStatus;
  final String? speakerStance;
  final bool? isTest;
  final String? externalId;
  final String? customerId;

  /// ISO 8601 timestamp.
  final String? createdAt;

  /// A string, an object, or an encrypted envelope when the account uses its
  /// own encryption key (see [e2eEnvelopeFields]).
  final Object? summary;
  final Map<String, dynamic>? review;

  /// Fields that are encrypted with the account's own key and must be
  /// decrypted locally.
  final List<String> e2eEnvelopeFields;

  /// The incident exactly as the API sent it.
  final Map<String, dynamic> raw;
}

/// A page of incidents.
class ListIncidentsResult {
  const ListIncidentsResult({
    required this.incidents,
    required this.totalReturned,
    this.nextCursor,
  });

  factory ListIncidentsResult.fromJson(Map<String, dynamic> json) {
    return ListIncidentsResult(
      incidents: _mapList(json['incidents']).map(Incident.fromJson).toList(),
      totalReturned: _optInt(json['total_returned']) ?? 0,
      nextCursor: json['next_cursor'] as String?,
    );
  }

  final List<Incident> incidents;
  final int totalReturned;

  /// Pass as [ListIncidentsInput.cursor] for the next page; `null` on the
  /// last page.
  final String? nextCursor;
}

/// Incident counts for the account.
class IncidentsOverview {
  const IncidentsOverview({
    required this.totalIncidents,
    required this.requiresReviewCount,
    required this.last24hCount,
    required this.last7dCount,
    required this.last30dCount,
    required this.countsByCategory,
    required this.countsBySeverity,
    required this.countsBySource,
    required this.countsByStatus,
    required this.topPlatforms,
    this.from,
    this.to,
  });

  factory IncidentsOverview.fromJson(Map<String, dynamic> json) {
    final timeframe = _optMap(json['timeframe']);
    return IncidentsOverview(
      from: timeframe?['from'] as String?,
      to: timeframe?['to'] as String?,
      totalIncidents: _optInt(json['total_incidents']) ?? 0,
      requiresReviewCount: _optInt(json['requires_review_count']) ?? 0,
      last24hCount: _optInt(json['last_24h_count']) ?? 0,
      last7dCount: _optInt(json['last_7d_count']) ?? 0,
      last30dCount: _optInt(json['last_30d_count']) ?? 0,
      countsByCategory: _counts(json['counts_by_category']),
      countsBySeverity: _counts(json['counts_by_severity']),
      countsBySource: _counts(json['counts_by_source']),
      countsByStatus: _counts(json['counts_by_status']),
      topPlatforms: {
        for (final row in _mapList(json['top_platforms']))
          row['platform'].toString(): _optInt(row['count']) ?? 0,
      },
    );
  }

  static Map<String, int> _counts(Object? value) => {
        for (final entry in (_optMap(value) ?? const {}).entries)
          entry.key: _optInt(entry.value) ?? 0,
      };

  final String? from;
  final String? to;
  final int totalIncidents;
  final int requiresReviewCount;
  final int last24hCount;
  final int last7dCount;
  final int last30dCount;
  final Map<String, int> countsByCategory;
  final Map<String, int> countsBySeverity;
  final Map<String, int> countsBySource;
  final Map<String, int> countsByStatus;

  /// Incident count per platform, busiest first.
  final Map<String, int> topPlatforms;
}

/// One bucket of an incident trend series.
class IncidentTrendBucket {
  const IncidentTrendBucket({
    required this.bucketStart,
    required this.total,
    required this.bySeverity,
  });

  factory IncidentTrendBucket.fromJson(Map<String, dynamic> json) {
    return IncidentTrendBucket(
      bucketStart: json['bucket_start'] as String? ?? '',
      total: _optInt(json['total']) ?? 0,
      bySeverity: IncidentsOverview._counts(json['by_severity']),
    );
  }

  final String bucketStart;
  final int total;
  final Map<String, int> bySeverity;
}

/// Incident counts over time.
class IncidentTrends {
  const IncidentTrends({
    required this.bucketSize,
    required this.series,
    this.from,
    this.to,
  });

  factory IncidentTrends.fromJson(Map<String, dynamic> json) {
    final timeframe = _optMap(json['timeframe']);
    return IncidentTrends(
      bucketSize: json['bucket_size'] as String? ?? '',
      from: timeframe?['from'] as String?,
      to: timeframe?['to'] as String?,
      series:
          _mapList(json['series']).map(IncidentTrendBucket.fromJson).toList(),
    );
  }

  /// `hour`, `day` or `week`.
  final String bucketSize;
  final String? from;
  final String? to;
  final List<IncidentTrendBucket> series;
}

/// A moderator decision on one or more incidents.
class ReviewIncidentInput {
  const ReviewIncidentInput({
    required this.action,
    required this.reasonCode,
    required this.moderatorExternalId,
    this.reasonComment,
    this.newRiskLevel,
    this.newRiskCategory,
    this.retentionClass,
  });

  /// `confirm`, `downgrade`, `escalate`, `reclassify`, `dismiss`, `resolve`
  /// or `reopen`.
  final String action;

  /// `confirmed_accurate`, `false_positive`, `out_of_context`,
  /// `insufficient_severity`, `incorrect_category`,
  /// `requires_law_enforcement`, `parent_notified` or `other`.
  final String reasonCode;

  /// A stable identifier for the moderator, so the audit trail can
  /// attribute the decision.
  final String moderatorExternalId;
  final String? reasonComment;
  final String? newRiskLevel;

  /// Required when [action] is `reclassify`.
  final String? newRiskCategory;
  final String? retentionClass;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'action': action,
      'reason_code': reasonCode,
      'moderator_external_id': moderatorExternalId,
    };
    if (reasonComment != null) map['reason_comment'] = reasonComment;
    if (newRiskLevel != null) map['new_risk_level'] = newRiskLevel;
    if (newRiskCategory != null) map['new_risk_category'] = newRiskCategory;
    if (retentionClass != null) map['retention_class'] = retentionClass;
    return map;
  }
}

/// Result of reviewing one incident.
class ReviewIncidentResult {
  const ReviewIncidentResult({
    required this.incidentId,
    this.ok = true,
    this.original,
    this.revised,
    this.auditReceipt,
    this.error,
  });

  factory ReviewIncidentResult.fromJson(Map<String, dynamic> json) {
    return ReviewIncidentResult(
      incidentId: json['incident_id'] as String? ?? '',
      ok: json['ok'] as bool? ?? true,
      original: _optMap(json['original']),
      revised: _optMap(json['revised']),
      auditReceipt: _optMap(json['audit_receipt']),
      error: json['error'] as String?,
    );
  }

  final String incidentId;

  /// False when this incident failed inside a batch review.
  final bool ok;

  /// `risk_category` and `risk_level` before the review.
  final Map<String, dynamic>? original;

  /// `risk_category` and `risk_level` after the review.
  final Map<String, dynamic>? revised;
  final Map<String, dynamic>? auditReceipt;
  final String? error;
}

/// Result of reviewing several incidents at once.
class BatchReviewIncidentsResult {
  const BatchReviewIncidentsResult({
    required this.total,
    required this.succeeded,
    required this.failed,
    required this.results,
  });

  factory BatchReviewIncidentsResult.fromJson(Map<String, dynamic> json) {
    return BatchReviewIncidentsResult(
      total: _optInt(json['total']) ?? 0,
      succeeded: _optInt(json['succeeded']) ?? 0,
      failed: _optInt(json['failed']) ?? 0,
      results: _mapList(json['results'])
          .map(ReviewIncidentResult.fromJson)
          .toList(),
    );
  }

  final int total;
  final int succeeded;
  final int failed;
  final List<ReviewIncidentResult> results;
}

// =============================================================================
// Nickname
// =============================================================================

/// Input for reading a display name.
class DetectNicknameInput {
  const DetectNicknameInput({
    required this.name,
    this.strictness,
    this.language,
    this.ageGroup,
    this.conversationType,
    this.platformReserved,
  });

  /// The display name, as the user typed it.
  final String name;

  /// How readily a doubtful reading is acted on; the API defaults to
  /// `balanced`.
  final String? strictness;
  final String? language;
  final String? ageGroup;

  /// The setting the name is shown in, for example `gaming_chat`.
  final String? conversationType;

  /// Names the platform reserves for itself.
  final List<String>? platformReserved;

  Map<String, dynamic> toJson() {
    final context = <String, dynamic>{};
    if (language != null) context['language'] = language;
    if (ageGroup != null) context['age_group'] = ageGroup;
    if (conversationType != null) {
      context['conversation_type'] = conversationType;
    }
    if (platformReserved != null) {
      context['platform_reserved'] = platformReserved;
    }
    final map = <String, dynamic>{'name': name};
    if (strictness != null) map['strictness'] = strictness;
    if (context.isNotEmpty) map['context'] = context;
    return map;
  }
}

/// One part of a display name and how it reads.
class NicknamePart {
  const NicknamePart({required this.text, required this.reading, this.category});

  factory NicknamePart.fromJson(Map<String, dynamic> json) {
    return NicknamePart(
      text: json['text'] as String? ?? '',
      reading: json['reading'] as String? ?? '',
      category: json['category'] as String?,
    );
  }

  final String text;

  /// `ordinary`, `concerning` or `unclear`.
  final String reading;
  final String? category;
}

/// Result of reading a display name.
class NicknameResult {
  const NicknameResult({
    required this.signal,
    required this.categories,
    required this.parts,
    required this.rationale,
    required this.recommendation,
    this.recommendationDetail,
    this.confidence,
    this.language,
    this.strictness,
    this.readingComplete,
    this.creditsUsed,
  });

  factory NicknameResult.fromJson(Map<String, dynamic> json) {
    return NicknameResult(
      signal: json['signal'] as String? ?? '',
      categories: _stringList(json['categories']),
      parts: _mapList(json['parts']).map(NicknamePart.fromJson).toList(),
      rationale: json['rationale'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      recommendationDetail: json['recommendation_detail'] as String?,
      confidence: _optDouble(json['confidence']),
      language: json['language'] as String?,
      strictness: json['strictness'] as String?,
      readingComplete: json['reading_complete'] as bool?,
      creditsUsed: _optInt(json['credits_used']),
    );
  }

  /// `none`, `low` or `review`: a signal about the name, not a verdict on
  /// the person.
  final String signal;
  final List<String> categories;
  final List<NicknamePart> parts;
  final String rationale;

  /// `allow`, `allow_and_watch`, `ask_to_rename` or `hold_for_review`.
  final String recommendation;
  final String? recommendationDetail;
  final double? confidence;
  final String? language;
  final String? strictness;
  final bool? readingComplete;
  final int? creditsUsed;
}

// =============================================================================
// Synthetic Content
// =============================================================================

/// Result of synthetic (AI-generated) content detection for text, image,
/// audio or video.
///
/// The fields shared by every input type are typed; the input-specific
/// analysis is kept in [raw].
class SyntheticContentResult {
  const SyntheticContentResult({
    required this.detected,
    required this.classification,
    required this.confidence,
    required this.riskScore,
    required this.level,
    required this.recommendedAction,
    required this.rationale,
    required this.raw,
    this.endpoint,
    this.severity,
    this.categories = const [],
    this.evidence = const [],
    this.actionDetail,
    this.inputType,
    this.creditsUsed,
    this.processingTimeMs,
    this.language,
    this.languageStatus,
    this.externalId,
    this.customerId,
    this.metadata,
    this.fileId,
  });

  factory SyntheticContentResult.fromJson(Map<String, dynamic> json) {
    return SyntheticContentResult(
      endpoint: json['endpoint'] as String?,
      detected: json['detected'] as bool? ?? false,
      classification: json['classification'] as String? ?? 'unknown',
      confidence: _optDouble(json['confidence']) ?? 0,
      riskScore: _optDouble(json['risk_score']) ?? 0,
      severity: _optDouble(json['severity']),
      level: json['level'] as String? ?? 'none',
      categories: _mapList(json['categories'])
          .map(DetectionCategory.fromJson)
          .toList(),
      evidence:
          _mapList(json['evidence']).map(DetectionEvidence.fromJson).toList(),
      recommendedAction: json['recommended_action'] as String? ?? 'none',
      actionDetail: json['action_detail'] as String?,
      rationale: json['rationale'] as String? ?? '',
      inputType: json['input_type'] as String?,
      creditsUsed: _optInt(json['credits_used']),
      processingTimeMs: _optDouble(json['processing_time_ms']),
      language: json['language'] as String?,
      languageStatus: json['language_status'] as String?,
      externalId: json['external_id'] as String?,
      customerId: json['customer_id'] as String?,
      metadata: _optMap(json['metadata']),
      fileId: json['file_id'] as String?,
      raw: json,
    );
  }

  final String? endpoint;
  final bool detected;

  /// `confirmed_synthetic`, `suspected_synthetic`, `unknown` or
  /// `confirmed_authentic`.
  final String classification;
  final double confidence;
  final double riskScore;
  final double? severity;
  final String level;
  final List<DetectionCategory> categories;
  final List<DetectionEvidence> evidence;
  final String recommendedAction;
  final String? actionDetail;
  final String rationale;

  /// `image`, `audio` or `video`; absent for text.
  final String? inputType;
  final int? creditsUsed;
  final double? processingTimeMs;
  final String? language;
  final String? languageStatus;
  final String? externalId;
  final String? customerId;
  final Map<String, dynamic>? metadata;
  final String? fileId;

  /// The result exactly as the API sent it.
  final Map<String, dynamic> raw;
}

// =============================================================================
// Usage Summary and Quota
// =============================================================================

/// Request counts for one day, with the plan's limits.
class UsageSummary {
  const UsageSummary({
    required this.tier,
    required this.date,
    required this.totalRequests,
    required this.successRequests,
    required this.errorRequests,
    required this.requestsPerMinute,
    required this.requestsPerMonth,
    required this.requestsPerDay,
    required this.remainingToday,
    this.apiKeyId,
  });

  factory UsageSummary.fromJson(Map<String, dynamic> json) {
    final usage = _optMap(json['usage']) ?? const {};
    final quota = _optMap(json['quota']) ?? const {};
    return UsageSummary(
      apiKeyId: json['apiKeyId'] as String?,
      tier: json['tier'] as String? ?? '',
      date: json['date'] as String? ?? '',
      totalRequests: _optInt(usage['totalRequests']) ?? 0,
      successRequests: _optInt(usage['successRequests']) ?? 0,
      errorRequests: _optInt(usage['errorRequests']) ?? 0,
      requestsPerMinute: _optInt(quota['requestsPerMinute']) ?? 0,
      requestsPerMonth: _optInt(quota['requestsPerMonth']) ?? 0,
      requestsPerDay: _optInt(quota['requestsPerDay']) ?? 0,
      remainingToday: _optInt(quota['remainingToday']) ?? 0,
    );
  }

  final String? apiKeyId;
  final String tier;
  final String date;
  final int totalRequests;
  final int successRequests;
  final int errorRequests;
  final int requestsPerMinute;
  final int requestsPerMonth;

  /// -1 when the plan has no daily limit.
  final int requestsPerDay;

  /// -1 when the plan has no daily limit.
  final int remainingToday;
}

/// Current rate-limit and quota state of the API key.
class UsageQuota {
  const UsageQuota({
    required this.tier,
    required this.requestsPerMinute,
    required this.requestsPerMonth,
    required this.requestsPerDay,
    required this.requestsThisMinute,
    required this.requestsToday,
    required this.remainingThisMinute,
    required this.remainingToday,
    this.apiKeyId,
    this.resetsInSeconds,
  });

  factory UsageQuota.fromJson(Map<String, dynamic> json) {
    final limits = _optMap(json['limits']) ?? const {};
    final current = _optMap(json['current']) ?? const {};
    final remaining = _optMap(json['remaining']) ?? const {};
    return UsageQuota(
      apiKeyId: json['apiKeyId'] as String?,
      tier: json['tier'] as String? ?? '',
      requestsPerMinute: _optInt(limits['requestsPerMinute']) ?? 0,
      requestsPerMonth: _optInt(limits['requestsPerMonth']) ?? 0,
      requestsPerDay: _optInt(limits['requestsPerDay']) ?? 0,
      requestsThisMinute: _optInt(current['requestsThisMinute']) ?? 0,
      requestsToday: _optInt(current['requestsToday']) ?? 0,
      remainingThisMinute: _optInt(remaining['requestsThisMinute']) ?? 0,
      remainingToday: _optInt(remaining['requestsToday']) ?? 0,
      resetsInSeconds: _optInt(json['resetsInSeconds']),
    );
  }

  final String? apiKeyId;
  final String tier;
  final int requestsPerMinute;
  final int requestsPerMonth;
  final int requestsPerDay;
  final int requestsThisMinute;
  final int requestsToday;
  final int remainingThisMinute;
  final int remainingToday;

  /// Seconds until the per-minute window resets.
  final int? resetsInSeconds;
}
