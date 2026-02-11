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
  });

  final RiskLevel riskLevel;
  final double riskScore;
  final String summary;
  final String recommendedAction;
  final BullyingResult? bullying;
  final UnsafeResult? unsafe;
  final String? externalId;
  final Map<String, dynamic>? metadata;
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
    );
  }

  final List<String> dominantEmotions;
  final EmotionTrend trend;
  final double intensity;
  final List<String> concerningPatterns;
  final String recommendedFollowup;
  final String? externalId;
  final Map<String, dynamic>? metadata;
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
  });

  factory ActionPlanResult.fromJson(Map<String, dynamic> json) {
    return ActionPlanResult(
      steps: List<String>.from(json['steps'] as List),
      tone: json['tone'] as String,
      resources: List<String>.from(json['resources'] as List),
      urgency: json['urgency'] as String,
      externalId: json['external_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final List<String> steps;
  final String tone;
  final List<String> resources;
  final String urgency;
  final String? externalId;
  final Map<String, dynamic>? metadata;
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
    );
  }

  final String summary;
  final RiskLevel riskLevel;
  final List<String> timeline;
  final List<String> keyEvidence;
  final List<String> recommendedNextSteps;
  final String? externalId;
  final Map<String, dynamic>? metadata;
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
