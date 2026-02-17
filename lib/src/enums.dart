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
  fr('fr');

  const Language(this.value);
  final String value;

  static Language fromString(String value) =>
      Language.values.firstWhere((e) => e.value == value,
          orElse: () => throw ArgumentError('Unknown language: $value'));
}

/// Language support status.
enum LanguageStatus {
  stable('stable'),
  beta('beta');

  const LanguageStatus(this.value);
  final String value;

  static LanguageStatus fromString(String value) =>
      LanguageStatus.values.firstWhere((e) => e.value == value,
          orElse: () => throw ArgumentError('Unknown language status: $value'));
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
  radicalisation('radicalisation');

  const Detection(this.value);
  final String value;

  static Detection fromString(String value) =>
      Detection.values.firstWhere((e) => e.value == value,
          orElse: () => throw ArgumentError('Unknown detection: $value'));
}

/// Account tier levels.
enum Tier {
  starter('starter'),
  indie('indie'),
  pro('pro'),
  business('business'),
  enterprise('enterprise');

  const Tier(this.value);
  final String value;

  static Tier fromString(String value) =>
      Tier.values.firstWhere((e) => e.value == value,
          orElse: () => throw ArgumentError('Unknown tier: $value'));
}
