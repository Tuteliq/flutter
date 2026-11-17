/// Severity level for detected issues.
enum Severity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const Severity(this.value);
  final String value;

  static Severity fromString(String value) {
    return Severity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Severity.low,
    );
  }
}

/// Risk level for grooming detection.
enum GroomingRisk {
  none('none'),
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const GroomingRisk(this.value);
  final String value;

  static GroomingRisk fromString(String value) {
    return GroomingRisk.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GroomingRisk.none,
    );
  }
}

/// Overall risk level for content analysis.
enum RiskLevel {
  safe('safe'),
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const RiskLevel(this.value);
  final String value;

  static RiskLevel fromString(String value) {
    return RiskLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RiskLevel.safe,
    );
  }
}

/// Emotion trend direction.
enum EmotionTrend {
  improving('improving'),
  stable('stable'),
  worsening('worsening');

  const EmotionTrend(this.value);
  final String value;

  static EmotionTrend fromString(String value) {
    return EmotionTrend.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EmotionTrend.stable,
    );
  }
}

/// Target audience for action plans.
enum Audience {
  child('child'),
  parent('parent'),
  educator('educator'),
  platform('platform');

  const Audience(this.value);
  final String value;
}

/// Role of message sender in grooming detection.
enum MessageRole {
  adult('adult'),
  child('child'),
  unknown('unknown');

  const MessageRole(this.value);
  final String value;
}

/// Supported languages for analysis.
///
/// English is stable; the other languages are in beta. A code the SDK does
/// not know yet parses to [Language.unknown] instead of throwing.
enum Language {
  en('en'),
  es('es'),
  pt('pt'),
  uk('uk'),
  sv('sv'),
  no_('no'),
  da('da'),
  fi('fi'),
  de('de'),
  fr('fr'),
  nl('nl'),
  pl('pl'),
  it('it'),
  tr('tr'),
  ro('ro'),
  el('el'),
  cs('cs'),
  hu('hu'),
  bg('bg'),
  hr('hr'),
  sk('sk'),
  lt('lt'),
  lv('lv'),
  et('et'),
  sl('sl'),
  mt('mt'),
  ga('ga'),
  zh('zh'),
  ja('ja'),
  ko('ko'),
  ar('ar'),
  ru('ru'),
  unknown('unknown');

  const Language(this.value);
  final String value;

  static Language fromString(String value) =>
      Language.values.firstWhere((e) => e.value == value,
          orElse: () => Language.unknown);
}

/// Language support status.
enum LanguageStatus {
  stable('stable'),
  beta('beta'),
  unknown('unknown');

  const LanguageStatus(this.value);
  final String value;

  static LanguageStatus fromString(String value) =>
      LanguageStatus.values.firstWhere((e) => e.value == value,
          orElse: () => LanguageStatus.unknown);
}

/// Detection endpoint types.
enum Detection {
  bullying('bullying'),
  grooming('grooming'),
  unsafe('unsafe'),
  socialEngineering('social-engineering'),
  appFraud('app-fraud'),
  romanceScam('romance-scam'),
  muleRecruitment('mule-recruitment'),
  gamblingHarm('gambling-harm'),
  coerciveControl('coercive-control'),
  vulnerabilityExploitation('vulnerability-exploitation'),
  radicalisation('radicalisation'),
  distressSignals('distress-signals'),
  tfgbv('tfgbv'),
  unknown('unknown');

  const Detection(this.value);
  final String value;

  static Detection fromString(String value) =>
      Detection.values.firstWhere((e) => e.value == value,
          orElse: () => Detection.unknown);
}

/// Account tier levels.
///
/// Build, Assure and Enterprise are the current plans; Starter, Indie, Pro
/// and Business are legacy plans that existing accounts keep. A tier the SDK
/// does not know yet parses to [Tier.unknown] instead of throwing.
enum Tier {
  starter('starter'),
  indie('indie'),
  pro('pro'),
  business('business'),
  build('build'),
  assure('assure'),
  enterprise('enterprise'),
  unknown('unknown');

  const Tier(this.value);
  final String value;

  static Tier fromString(String value) =>
      Tier.values.firstWhere((e) => e.value == value,
          orElse: () => Tier.unknown);
}

/// Recommended action returned by the detection endpoints, weakest first.
enum RecommendedAction {
  none('none'),
  monitor('monitor'),
  flagForReview('flag_for_review'),
  block('block'),
  immediateIntervention('immediate_intervention');

  const RecommendedAction(this.value);
  final String value;

  /// Parses an API value. Returns `null` for a value the SDK does not know.
  static RecommendedAction? tryParse(String? value) {
    for (final action in RecommendedAction.values) {
      if (action.value == value) return action;
    }
    return null;
  }

  /// The most severe of [values]. An unrecognised value counts as
  /// [flagForReview], so it is never silently reported as [none].
  static RecommendedAction mostSevere(Iterable<String?> values) {
    var result = RecommendedAction.none;
    for (final value in values) {
      final action = tryParse(value) ?? RecommendedAction.flagForReview;
      if (action.index > result.index) result = action;
    }
    return result;
  }
}

/// Verification session mode.
enum VerificationMode {
  age('age'),
  identity('identity');

  const VerificationMode(this.value);
  final String value;
}

/// Identity document type for a verification session.
enum VerificationDocumentType {
  passport('passport'),
  nationalId('national_id'),
  driversLicense('drivers_license');

  const VerificationDocumentType(this.value);
  final String value;
}

/// How a passport or ID card chip read counts as document evidence.
enum ChipPolicy {
  optional('optional'),
  required('required'),
  insteadOfPhoto('instead_of_photo'),
  unknown('unknown');

  const ChipPolicy(this.value);
  final String value;

  static ChipPolicy fromString(String? value) =>
      ChipPolicy.values.firstWhere((e) => e.value == value,
          orElse: () => ChipPolicy.unknown);
}

/// Status of a verification session.
enum VerificationSessionStatus {
  pending('pending'),
  inProgress('in_progress'),
  documentRequired('document_required'),
  completed('completed'),
  failed('failed'),
  expired('expired'),
  unknown('unknown');

  const VerificationSessionStatus(this.value);
  final String value;

  static VerificationSessionStatus fromString(String? value) =>
      VerificationSessionStatus.values.firstWhere((e) => e.value == value,
          orElse: () => VerificationSessionStatus.unknown);
}
