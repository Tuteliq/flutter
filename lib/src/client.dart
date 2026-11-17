import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'enums.dart';
import 'errors.dart';
import 'media_type.dart';
import 'models.dart';
import 'voice_stream.dart';

/// Tuteliq API client for child safety analysis.
///
/// Example:
/// ```dart
/// final client = Tuteliq(apiKey: 'your-api-key');
/// final result = await client.detectBullying('Some text to analyze');
/// if (result.isBullying) {
///   print('Severity: ${result.severity}');
/// }
/// ```
class Tuteliq {
  static const String _sdkIdentifier = 'Flutter SDK';

  static String _resolvePlatform(String? platform) {
    if (platform != null && platform.isNotEmpty) {
      return '$platform - $_sdkIdentifier';
    }
    return _sdkIdentifier;
  }

  /// Creates a new Tuteliq client.
  ///
  /// [apiKey] is required and must be a valid Tuteliq API key.
  /// [timeout] is the request timeout (default: 30 seconds).
  /// [maxRetries] is the number of retry attempts for transient failures.
  /// [retryDelay] is the initial retry delay.
  /// [baseUrl] is the API base URL (default: https://api.tuteliq.ai).
  /// [httpClient] replaces the underlying HTTP client, for example to add
  /// logging or to stub the API in tests.
  Tuteliq({
    required String apiKey,
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String baseUrl = 'https://api.tuteliq.ai',
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _timeout = timeout,
        _maxRetries = maxRetries,
        _retryDelay = retryDelay,
        _baseUrl = baseUrl,
        _client = httpClient ?? http.Client() {
    if (apiKey.isEmpty) {
      throw ArgumentError('API key is required');
    }
    if (apiKey.length < 10) {
      throw ArgumentError('API key appears to be invalid');
    }
  }

  final String _apiKey;
  final Duration _timeout;
  final int _maxRetries;
  final Duration _retryDelay;
  final String _baseUrl;
  final http.Client _client;

  /// Current usage statistics (updated after each request).
  Usage? usage;

  /// Request ID from the last API call.
  String? lastRequestId;

  /// Create a voice streaming session over WebSocket.
  VoiceStreamSession voiceStream({
    VoiceStreamConfig? config,
    VoiceStreamHandlers? handlers,
  }) {
    return VoiceStreamSession(_apiKey, config, handlers, baseUrl: _baseUrl);
  }

  /// Closes the HTTP client.
  void close() {
    _client.close();
  }

  // ===========================================================================
  // Safety Detection
  // ===========================================================================

  /// Detect bullying in content.
  Future<BullyingResult> detectBullying(
    String content, {
    AnalysisContext? context,
    String? externalId,
    Map<String, dynamic>? metadata,
  }) async {
    final body = <String, dynamic>{'text': content};
    final contextMap = context?.toJson() ?? <String, dynamic>{};
    contextMap['platform'] = _resolvePlatform(context?.platform);
    body['context'] = contextMap;
    if (externalId != null) body['external_id'] = externalId;
    if (metadata != null) body['metadata'] = metadata;

    final data = await _request('/api/v1/safety/bullying', body);
    return BullyingResult.fromJson(data);
  }

  /// Detect bullying using input object.
  Future<BullyingResult> detectBullyingWithInput(DetectBullyingInput input) {
    return detectBullying(
      input.content,
      context: input.context,
      externalId: input.externalId,
      metadata: input.metadata,
    );
  }

  /// Detect grooming patterns in a conversation.
  Future<GroomingResult> detectGrooming(DetectGroomingInput input) async {
    final body = <String, dynamic>{
      'messages': input.messages.map((m) => m.toJson()).toList(),
    };

    final contextMap = <String, dynamic>{};
    if (input.childAge != null) contextMap['child_age'] = input.childAge;
    if (input.context != null) contextMap.addAll(input.context!.toJson());
    contextMap['platform'] = _resolvePlatform(input.context?.platform);
    body['context'] = contextMap;

    if (input.externalId != null) body['external_id'] = input.externalId;
    if (input.metadata != null) body['metadata'] = input.metadata;

    final data = await _request('/api/v1/safety/grooming', body);
    return GroomingResult.fromJson(data);
  }

  /// Detect unsafe content.
  Future<UnsafeResult> detectUnsafe(
    String content, {
    AnalysisContext? context,
    String? externalId,
    Map<String, dynamic>? metadata,
  }) async {
    final body = <String, dynamic>{'text': content};
    final contextMap = context?.toJson() ?? <String, dynamic>{};
    contextMap['platform'] = _resolvePlatform(context?.platform);
    body['context'] = contextMap;
    if (externalId != null) body['external_id'] = externalId;
    if (metadata != null) body['metadata'] = metadata;

    final data = await _request('/api/v1/safety/unsafe', body);
    return UnsafeResult.fromJson(data);
  }

  /// Detect unsafe content using input object.
  Future<UnsafeResult> detectUnsafeWithInput(DetectUnsafeInput input) {
    return detectUnsafe(
      input.content,
      context: input.context,
      externalId: input.externalId,
      metadata: input.metadata,
    );
  }

  /// Quick analysis - runs bullying and unsafe detection.
  Future<AnalyzeResult> analyze(
    String content, {
    AnalysisContext? context,
    List<String>? include,
    String? externalId,
    Map<String, dynamic>? metadata,
  }) async {
    final checks = include ?? ['bullying', 'unsafe'];

    BullyingResult? bullyingResult;
    UnsafeResult? unsafeResult;
    var maxRiskScore = 0.0;

    // Run checks (could be parallelized with Future.wait)
    if (checks.contains('bullying')) {
      bullyingResult = await detectBullying(
        content,
        context: context,
        externalId: externalId,
        metadata: metadata,
      );
      if (bullyingResult.riskScore > maxRiskScore) {
        maxRiskScore = bullyingResult.riskScore;
      }
    }

    if (checks.contains('unsafe')) {
      unsafeResult = await detectUnsafe(
        content,
        context: context,
        externalId: externalId,
        metadata: metadata,
      );
      if (unsafeResult.riskScore > maxRiskScore) {
        maxRiskScore = unsafeResult.riskScore;
      }
    }

    // Determine risk level
    final RiskLevel riskLevel;
    if (maxRiskScore >= 0.9) {
      riskLevel = RiskLevel.critical;
    } else if (maxRiskScore >= 0.7) {
      riskLevel = RiskLevel.high;
    } else if (maxRiskScore >= 0.5) {
      riskLevel = RiskLevel.medium;
    } else if (maxRiskScore >= 0.3) {
      riskLevel = RiskLevel.low;
    } else {
      riskLevel = RiskLevel.safe;
    }

    // Build summary
    final findings = <String>[];
    if (bullyingResult?.isBullying == true) {
      findings.add('Bullying detected (${bullyingResult!.severity.value})');
    }
    if (unsafeResult?.unsafe == true) {
      findings.add('Unsafe content: ${unsafeResult!.categories.join(', ')}');
    }
    final summary = findings.isEmpty
        ? 'No safety concerns detected.'
        : findings.join('. ');

    // Determine recommended action
    final actions = <String>[];
    if (bullyingResult != null) actions.add(bullyingResult.recommendedAction);
    if (unsafeResult != null) actions.add(unsafeResult.recommendedAction);

    // The most severe action wins, so a blocking verdict is never reported
    // as a weaker one.
    final recommendedAction = RecommendedAction.mostSevere(actions).value;

    // Sum credits from sub-results when available
    int? totalCredits;
    if (bullyingResult?.creditsUsed != null || unsafeResult?.creditsUsed != null) {
      totalCredits = (bullyingResult?.creditsUsed ?? 0) + (unsafeResult?.creditsUsed ?? 0);
    }

    return AnalyzeResult(
      riskLevel: riskLevel,
      riskScore: maxRiskScore,
      summary: summary,
      bullying: bullyingResult,
      unsafe: unsafeResult,
      recommendedAction: recommendedAction,
      externalId: externalId,
      metadata: metadata,
      creditsUsed: totalCredits,
    );
  }

  /// Quick analysis using input object.
  Future<AnalyzeResult> analyzeWithInput(AnalyzeInput input) {
    return analyze(
      input.content,
      context: input.context,
      include: input.include,
      externalId: input.externalId,
      metadata: input.metadata,
    );
  }

  // ===========================================================================
  // Emotion Analysis
  // ===========================================================================

  /// Analyze emotions in content or conversation.
  Future<EmotionsResult> analyzeEmotions(
    String content, {
    AnalysisContext? context,
    String? externalId,
    Map<String, dynamic>? metadata,
  }) async {
    final body = <String, dynamic>{
      'messages': [
        {'sender': 'user', 'text': content}
      ],
    };
    final contextMap = context?.toJson() ?? <String, dynamic>{};
    contextMap['platform'] = _resolvePlatform(context?.platform);
    body['context'] = contextMap;
    if (externalId != null) body['external_id'] = externalId;
    if (metadata != null) body['metadata'] = metadata;

    final data = await _request('/api/v1/analysis/emotions', body);
    return EmotionsResult.fromJson(data);
  }

  /// Analyze emotions using input object.
  Future<EmotionsResult> analyzeEmotionsWithInput(
      AnalyzeEmotionsInput input) async {
    final body = <String, dynamic>{};

    if (input.content != null) {
      body['messages'] = [
        {'sender': 'user', 'text': input.content}
      ];
    } else if (input.messages != null) {
      body['messages'] = input.messages!.map((m) => m.toJson()).toList();
    }

    final contextMap = input.context?.toJson() ?? <String, dynamic>{};
    contextMap['platform'] = _resolvePlatform(input.context?.platform);
    body['context'] = contextMap;
    if (input.externalId != null) body['external_id'] = input.externalId;
    if (input.metadata != null) body['metadata'] = input.metadata;

    final data = await _request('/api/v1/analysis/emotions', body);
    return EmotionsResult.fromJson(data);
  }

  // ===========================================================================
  // Guidance
  // ===========================================================================

  /// Get age-appropriate action guidance.
  Future<ActionPlanResult> getActionPlan(GetActionPlanInput input) async {
    final body = <String, dynamic>{
      'role': (input.audience ?? Audience.parent).value,
      'situation': input.situation,
    };

    if (input.childAge != null) body['child_age'] = input.childAge;
    if (input.severity != null) body['severity'] = input.severity!.value;
    if (input.externalId != null) body['external_id'] = input.externalId;
    if (input.metadata != null) body['metadata'] = input.metadata;

    final data = await _request('/api/v1/guidance/action-plan', body);
    return ActionPlanResult.fromJson(data);
  }

  // ===========================================================================
  // Reports
  // ===========================================================================

  /// Generate an incident report.
  Future<ReportResult> generateReport(GenerateReportInput input) async {
    final body = <String, dynamic>{
      'messages': input.messages.map((m) => m.toJson()).toList(),
    };

    final meta = <String, dynamic>{};
    if (input.childAge != null) meta['child_age'] = input.childAge;
    if (input.incidentType != null) meta['type'] = input.incidentType;
    if (meta.isNotEmpty) body['meta'] = meta;

    if (input.externalId != null) body['external_id'] = input.externalId;
    if (input.metadata != null) body['metadata'] = input.metadata;

    final data = await _request('/api/v1/reports/incident', body);
    return ReportResult.fromJson(data);
  }

  // ===========================================================================
  // Account Management (GDPR)
  // ===========================================================================

  /// Delete all account data (GDPR Article 17 — Right to Erasure).
  Future<AccountDeletionResult> deleteAccountData() async {
    final data = await _requestWithMethod('DELETE', '/api/v1/account/data');
    return AccountDeletionResult.fromJson(data);
  }

  /// Export all account data as JSON (GDPR Article 20 — Right to Data Portability).
  Future<AccountExportResult> exportAccountData() async {
    final data = await _requestWithMethod('GET', '/api/v1/account/export');
    return AccountExportResult.fromJson(data);
  }

  /// Record user consent (GDPR Article 7).
  Future<ConsentActionResult> recordConsent(RecordConsentInput input) async {
    final data = await _request('/api/v1/account/consent', {
      'consent_type': input.consentType.value,
      'version': input.version,
    });
    return ConsentActionResult.fromJson(data);
  }

  /// Get current consent status (GDPR Article 7).
  Future<ConsentStatusResult> getConsentStatus({ConsentType? type}) async {
    final query = type != null ? '?type=${type.value}' : '';
    final data = await _requestWithMethod('GET', '/api/v1/account/consent$query');
    return ConsentStatusResult.fromJson(data);
  }

  /// Withdraw consent (GDPR Article 7.3).
  Future<ConsentActionResult> withdrawConsent(ConsentType type) async {
    final data = await _requestWithMethod('DELETE', '/api/v1/account/consent/${type.value}');
    return ConsentActionResult.fromJson(data);
  }

  /// Rectify user data (GDPR Article 16 — Right to Rectification).
  Future<RectifyDataResult> rectifyData(RectifyDataInput input) async {
    final data = await _requestWithMethod('PATCH', '/api/v1/account/data', body: {
      'collection': input.collection,
      'document_id': input.documentId,
      'fields': input.fields,
    });
    return RectifyDataResult.fromJson(data);
  }

  /// Get audit logs (GDPR Article 15 — Right of Access).
  Future<AuditLogsResult> getAuditLogs({AuditAction? action, int? limit}) async {
    final params = <String>[];
    if (action != null) params.add('action=${action.value}');
    if (limit != null) params.add('limit=$limit');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final data = await _requestWithMethod('GET', '/api/v1/account/audit-logs$query');
    return AuditLogsResult.fromJson(data);
  }

  // ===========================================================================
  // Breach Management (GDPR Article 33/34)
  // ===========================================================================

  /// Log a new data breach.
  Future<LogBreachResult> logBreach(LogBreachInput input) async {
    final data = await _request('/api/v1/admin/breach', {
      'title': input.title,
      'description': input.description,
      'severity': input.severity.value,
      'affected_user_ids': input.affectedUserIds,
      'data_categories': input.dataCategories,
      'reported_by': input.reportedBy,
    });
    return LogBreachResult.fromJson(data);
  }

  /// List data breaches.
  Future<BreachListResult> listBreaches({BreachStatusValue? status, int? limit}) async {
    final params = <String>[];
    if (status != null) params.add('status=${status.value}');
    if (limit != null) params.add('limit=$limit');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final data = await _requestWithMethod('GET', '/api/v1/admin/breach$query');
    return BreachListResult.fromJson(data);
  }

  /// Get a single breach by ID.
  Future<BreachResult> getBreach(String id) async {
    final data = await _requestWithMethod('GET', '/api/v1/admin/breach/$id');
    return BreachResult.fromJson(data);
  }

  /// Update a breach's status.
  Future<BreachResult> updateBreachStatus(String id, UpdateBreachInput input) async {
    final body = <String, dynamic>{
      'status': input.status.value,
    };
    if (input.notificationStatus != null) {
      body['notification_status'] = input.notificationStatus!.value;
    }
    if (input.notes != null) {
      body['notes'] = input.notes;
    }
    final data = await _requestWithMethod('PATCH', '/api/v1/admin/breach/$id', body: body);
    return BreachResult.fromJson(data);
  }

  // ===========================================================================
  // Private Methods
  // ===========================================================================

  Future<Map<String, dynamic>> _request(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _requestWithMethod('POST', path, body: body);
  }

  /// Sends a JSON request, retrying transient failures unless [retry] is
  /// false. Requests that create something are sent once, so a timeout never
  /// creates it twice.
  Future<Map<String, dynamic>> _requestWithMethod(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool retry = true,
  }) async {
    Exception? lastError;
    final attempts = retry ? _maxRetries : 1;

    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        return await _performRequest(method, path, body: body);
      } on AuthenticationException {
        rethrow;
      } on ValidationException {
        rethrow;
      } on NotFoundException {
        rethrow;
      } on QuotaExceededException {
        rethrow;
      } on TierAccessException {
        rethrow;
      } catch (e) {
        lastError = e as Exception;
        if (attempt < attempts - 1) {
          await Future.delayed(_retryDelay * (1 << attempt));
        }
      }
    }

    throw lastError ?? const TuteliqException('Request failed after retries');
  }

  Future<Map<String, dynamic>> _performRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final http.Response response;
    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    try {
      switch (method) {
        case 'DELETE':
          response = await _client.delete(uri, headers: headers).timeout(_timeout);
          break;
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
              .timeout(_timeout);
          break;
        default:
          response = await _client
              .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
              .timeout(_timeout);
      }
    } on TimeoutException {
      throw TimeoutException('Request timed out after ${_timeout.inSeconds}s');
    } catch (e) {
      throw NetworkException(e.toString());
    }

    // Extract metadata from headers
    lastRequestId = response.headers['x-request-id'];

    // Monthly usage headers
    final limit = int.tryParse(response.headers['x-monthly-limit'] ?? '');
    final used = int.tryParse(response.headers['x-monthly-used'] ?? '');
    final remaining = int.tryParse(response.headers['x-monthly-remaining'] ?? '');

    if (limit != null && used != null && remaining != null) {
      usage = Usage(limit: limit, used: used, remaining: remaining);
    }

    // Handle errors
    if (response.statusCode >= 400) {
      _handleErrorResponse(response);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Never _handleErrorResponse(http.Response response) {
    String message;
    dynamic details;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      message = error?['message'] as String? ?? 'Request failed';
      details = error?['details'];
    } catch (_) {
      message = 'Request failed';
      details = null;
    }

    switch (response.statusCode) {
      case 400:
        throw ValidationException(message, details);
      case 401:
        throw AuthenticationException(message, details);
      case 402:
        throw QuotaExceededException(message, details);
      case 403:
        throw TierAccessException(message, details);
      case 404:
        throw NotFoundException(message, details);
      case 429:
        throw RateLimitException(message, details);
      default:
        if (response.statusCode >= 500) {
          throw ServerException(message, response.statusCode, details);
        }
        throw TuteliqException(message, details);
    }
  }

  Future<Map<String, dynamic>> _multipartRequest(
    String path, {
    required List<int> file,
    required String filename,
    String? contentType,
    required String fieldName,
    Map<String, String> fields = const {},
  }) async {
    Exception? lastError;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await _performMultipartRequest(
          path,
          file: file,
          filename: filename,
          fieldName: fieldName,
          fields: fields,
          contentType: contentType,
        );
      } on AuthenticationException {
        rethrow;
      } on ValidationException {
        rethrow;
      } on NotFoundException {
        rethrow;
      } on QuotaExceededException {
        rethrow;
      } on TierAccessException {
        rethrow;
      } catch (e) {
        lastError = e as Exception;
        if (attempt < _maxRetries - 1) {
          await Future.delayed(_retryDelay * (1 << attempt));
        }
      }
    }

    throw lastError ?? const TuteliqException('Request failed after retries');
  }

  Future<Map<String, dynamic>> _performMultipartRequest(
    String path, {
    required List<int> file,
    required String filename,
    String? contentType,
    required String fieldName,
    Map<String, String> fields = const {},
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $_apiKey';
    request.fields.addAll(fields);
    request.files.add(http.MultipartFile.fromBytes(
      fieldName,
      file,
      filename: filename,
      contentType: uploadMediaType(filename, file, contentType: contentType),
    ));

    final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _client.send(request).timeout(_timeout);
    } on TimeoutException {
      throw TimeoutException('Request timed out after ${_timeout.inSeconds}s');
    } catch (e) {
      throw NetworkException(e.toString());
    }

    final response = await http.Response.fromStream(streamedResponse);

    // Extract metadata from headers
    lastRequestId = response.headers['x-request-id'];

    final limit = int.tryParse(response.headers['x-monthly-limit'] ?? '');
    final used = int.tryParse(response.headers['x-monthly-used'] ?? '');
    final remaining =
        int.tryParse(response.headers['x-monthly-remaining'] ?? '');

    if (limit != null && used != null && remaining != null) {
      usage = Usage(limit: limit, used: used, remaining: remaining);
    }

    if (response.statusCode >= 400) {
      _handleErrorResponse(response);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ===========================================================================
  // Voice Analysis
  // ===========================================================================

  /// Analyze voice/audio content for safety concerns.
  ///
  /// The file is sent with the content type of its [filename] extension
  /// (for example `.png`, `.mp3`, `.mp4`, `.pdf`); pass [contentType] to set
  /// it explicitly.
  Future<VoiceAnalysisResult> analyzeVoice({
    required List<int> file,
    required String filename,
    String? contentType,
    String analysisType = 'all',
    String? fileId,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
    String? ageGroup,
    String? language,
    String? platform,
    int? childAge,
  }) async {
    final fields = <String, String>{
      'analysis_type': analysisType,
      'platform': _resolvePlatform(platform),
    };
    if (fileId != null) fields['file_id'] = fileId;
    if (externalId != null) fields['external_id'] = externalId;
    if (customerId != null) fields['customer_id'] = customerId;
    if (metadata != null) fields['metadata'] = jsonEncode(metadata);
    if (ageGroup != null) fields['age_group'] = ageGroup;
    if (language != null) fields['language'] = language;
    if (childAge != null) fields['child_age'] = childAge.toString();

    final data = await _multipartRequest(
      '/api/v1/safety/voice',
      file: file,
      filename: filename,
      fieldName: 'file',
      fields: fields,
      contentType: contentType,
    );
    return VoiceAnalysisResult.fromJson(data);
  }

  // ===========================================================================
  // Image Analysis
  // ===========================================================================

  /// Analyze image content for safety concerns.
  ///
  /// The file is sent with the content type of its [filename] extension
  /// (for example `.png`, `.mp3`, `.mp4`, `.pdf`); pass [contentType] to set
  /// it explicitly.
  Future<ImageAnalysisResult> analyzeImage({
    required List<int> file,
    required String filename,
    String? contentType,
    String analysisType = 'all',
    String? fileId,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
    String? ageGroup,
    String? platform,
  }) async {
    final fields = <String, String>{
      'analysis_type': analysisType,
      'platform': _resolvePlatform(platform),
    };
    if (fileId != null) fields['file_id'] = fileId;
    if (externalId != null) fields['external_id'] = externalId;
    if (customerId != null) fields['customer_id'] = customerId;
    if (metadata != null) fields['metadata'] = jsonEncode(metadata);
    if (ageGroup != null) fields['age_group'] = ageGroup;

    final data = await _multipartRequest(
      '/api/v1/safety/image',
      file: file,
      filename: filename,
      fieldName: 'file',
      fields: fields,
      contentType: contentType,
    );
    return ImageAnalysisResult.fromJson(data);
  }

  // ===========================================================================
  // Fraud Detection
  // ===========================================================================

  Map<String, dynamic> _buildDetectionBody(DetectionInput input) {
    final ctx = input.context?.toJson() ?? <String, dynamic>{};
    ctx['platform'] = _resolvePlatform(ctx['platform'] as String?);
    final body = <String, dynamic>{'text': input.content, 'context': ctx};
    if (input.includeEvidence) body['include_evidence'] = true;
    if (input.externalId != null) body['external_id'] = input.externalId;
    if (input.customerId != null) body['customer_id'] = input.customerId;
    if (input.metadata != null) body['metadata'] = input.metadata;
    return body;
  }

  /// Detect social engineering attempts.
  Future<DetectionResult> detectSocialEngineering(
    String content, {
    AnalysisContext? context,
    bool includeEvidence = false,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _request(
      '/api/v1/fraud/social-engineering',
      _buildDetectionBody(DetectionInput(
        content: content,
        context: context,
        includeEvidence: includeEvidence,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
      )),
    );
    return DetectionResult.fromJson(data);
  }

  /// Detect social engineering using input object.
  Future<DetectionResult> detectSocialEngineeringWithInput(DetectionInput input) async {
    final data = await _request('/api/v1/fraud/social-engineering', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Detect app fraud attempts.
  Future<DetectionResult> detectAppFraud(
    String content, {
    AnalysisContext? context,
    bool includeEvidence = false,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _request(
      '/api/v1/fraud/app-fraud',
      _buildDetectionBody(DetectionInput(
        content: content,
        context: context,
        includeEvidence: includeEvidence,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
      )),
    );
    return DetectionResult.fromJson(data);
  }

  /// Detect app fraud using input object.
  Future<DetectionResult> detectAppFraudWithInput(DetectionInput input) async {
    final data = await _request('/api/v1/fraud/app-fraud', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Detect romance scam attempts.
  Future<DetectionResult> detectRomanceScam(
    String content, {
    AnalysisContext? context,
    bool includeEvidence = false,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _request(
      '/api/v1/fraud/romance-scam',
      _buildDetectionBody(DetectionInput(
        content: content,
        context: context,
        includeEvidence: includeEvidence,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
      )),
    );
    return DetectionResult.fromJson(data);
  }

  /// Detect romance scam using input object.
  Future<DetectionResult> detectRomanceScamWithInput(DetectionInput input) async {
    final data = await _request('/api/v1/fraud/romance-scam', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Detect mule recruitment attempts.
  Future<DetectionResult> detectMuleRecruitment(
    String content, {
    AnalysisContext? context,
    bool includeEvidence = false,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _request(
      '/api/v1/fraud/mule-recruitment',
      _buildDetectionBody(DetectionInput(
        content: content,
        context: context,
        includeEvidence: includeEvidence,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
      )),
    );
    return DetectionResult.fromJson(data);
  }

  /// Detect mule recruitment using input object.
  Future<DetectionResult> detectMuleRecruitmentWithInput(DetectionInput input) async {
    final data = await _request('/api/v1/fraud/mule-recruitment', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  // ===========================================================================
  // Safety Extended
  // ===========================================================================

  /// Detect gambling harm indicators.
  Future<DetectionResult> detectGamblingHarm(
    String content, {
    AnalysisContext? context,
    bool includeEvidence = false,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _request(
      '/api/v1/safety/gambling-harm',
      _buildDetectionBody(DetectionInput(
        content: content,
        context: context,
        includeEvidence: includeEvidence,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
      )),
    );
    return DetectionResult.fromJson(data);
  }

  /// Detect gambling harm using input object.
  Future<DetectionResult> detectGamblingHarmWithInput(DetectionInput input) async {
    final data = await _request('/api/v1/safety/gambling-harm', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Detect coercive control patterns.
  Future<DetectionResult> detectCoerciveControl(
    String content, {
    AnalysisContext? context,
    bool includeEvidence = false,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _request(
      '/api/v1/safety/coercive-control',
      _buildDetectionBody(DetectionInput(
        content: content,
        context: context,
        includeEvidence: includeEvidence,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
      )),
    );
    return DetectionResult.fromJson(data);
  }

  /// Detect coercive control using input object.
  Future<DetectionResult> detectCoerciveControlWithInput(DetectionInput input) async {
    final data = await _request('/api/v1/safety/coercive-control', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Detect vulnerability exploitation.
  Future<DetectionResult> detectVulnerabilityExploitation(
    String content, {
    AnalysisContext? context,
    bool includeEvidence = false,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _request(
      '/api/v1/safety/vulnerability-exploitation',
      _buildDetectionBody(DetectionInput(
        content: content,
        context: context,
        includeEvidence: includeEvidence,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
      )),
    );
    return DetectionResult.fromJson(data);
  }

  /// Detect vulnerability exploitation using input object.
  Future<DetectionResult> detectVulnerabilityExploitationWithInput(DetectionInput input) async {
    final data = await _request('/api/v1/safety/vulnerability-exploitation', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Detect radicalisation indicators.
  Future<DetectionResult> detectRadicalisation(
    String content, {
    AnalysisContext? context,
    bool includeEvidence = false,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _request(
      '/api/v1/safety/radicalisation',
      _buildDetectionBody(DetectionInput(
        content: content,
        context: context,
        includeEvidence: includeEvidence,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
      )),
    );
    return DetectionResult.fromJson(data);
  }

  /// Detect radicalisation using input object.
  Future<DetectionResult> detectRadicalisationWithInput(DetectionInput input) async {
    final data = await _request('/api/v1/safety/radicalisation', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Detect distress signals (linguistic signs that someone may need
  /// support).
  Future<DetectionResult> detectDistressSignals(DetectionInput input) async {
    final data = await _request('/api/v1/safety/distress-signals', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Detect technology-facilitated gender-based violence.
  Future<DetectionResult> detectTfgbv(DetectionInput input) async {
    final data = await _request('/api/v1/safety/tfgbv', _buildDetectionBody(input));
    return DetectionResult.fromJson(data);
  }

  /// Read a display name for concerning meanings.
  Future<NicknameResult> detectNickname(DetectNicknameInput input) async {
    if (input.name.trim().isEmpty) {
      throw ArgumentError('Name is required');
    }
    final data = await _request('/api/v1/safety/nickname', input.toJson());
    return NicknameResult.fromJson(data);
  }

  // ===========================================================================
  // Multi-Endpoint Analysis
  // ===========================================================================

  /// Run multiple detection endpoints in a single request.
  Future<AnalyseMultiResult> analyseMulti(AnalyseMultiInput input) async {
    final ctx = input.context?.toJson() ?? <String, dynamic>{};
    ctx['platform'] = _resolvePlatform(ctx['platform'] as String?);
    final body = <String, dynamic>{
      'text': input.content,
      'endpoints': input.detections.map((d) => d.value).toList(),
      'context': ctx,
    };
    if (input.includeEvidence) body['options'] = {'include_evidence': true};
    if (input.externalId != null) body['external_id'] = input.externalId;
    if (input.customerId != null) body['customer_id'] = input.customerId;
    if (input.metadata != null) body['metadata'] = input.metadata;
    final data = await _request('/api/v1/analyse/multi', body);
    return AnalyseMultiResult.fromJson(data);
  }

  // ===========================================================================
  // Video Analysis
  // ===========================================================================

  /// Analyze video content for safety concerns.
  ///
  /// The file is sent with the content type of its [filename] extension
  /// (for example `.png`, `.mp3`, `.mp4`, `.pdf`); pass [contentType] to set
  /// it explicitly.
  Future<VideoAnalysisResult> analyzeVideo({
    required List<int> file,
    required String filename,
    String? contentType,
    String? fileId,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
    String? ageGroup,
    String? platform,
  }) async {
    final fields = <String, String>{
      'platform': _resolvePlatform(platform),
    };
    if (fileId != null) fields['file_id'] = fileId;
    if (externalId != null) fields['external_id'] = externalId;
    if (customerId != null) fields['customer_id'] = customerId;
    if (metadata != null) fields['metadata'] = jsonEncode(metadata);
    if (ageGroup != null) fields['age_group'] = ageGroup;

    final data = await _multipartRequest(
      '/api/v1/safety/video',
      file: file,
      filename: filename,
      fieldName: 'file',
      fields: fields,
      contentType: contentType,
    );
    return VideoAnalysisResult.fromJson(data);
  }

  // ===========================================================================
  // Document Analysis
  // ===========================================================================

  /// Analyze a PDF document, or an image read as a one-page document, for
  /// safety concerns across multiple endpoints.
  ///
  /// Runs the specified detection endpoints on each page. For a messaging
  /// screenshot, set [splitBySender] to judge the last received message with
  /// the rest as history.
  ///
  /// The file is sent with the content type of its [filename] extension
  /// (for example `.png`, `.mp3`, `.mp4`, `.pdf`); pass [contentType] to set
  /// it explicitly.
  ///
  /// Valid endpoints: unsafe, bullying, grooming, social-engineering,
  /// coercive-control, radicalisation, romance-scam, mule-recruitment.
  Future<DocumentAnalysisResult> analyzeDocument({
    required List<int> file,
    required String filename,
    String? contentType,
    List<String>? endpoints,
    String? fileId,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
    String? ageGroup,
    String? language,
    String? platform,
    String? supportThreshold,
    bool splitBySender = false,
  }) async {
    final fields = <String, String>{
      'platform': _resolvePlatform(platform),
    };
    if (endpoints != null) fields['endpoints'] = jsonEncode(endpoints);
    if (splitBySender) fields['split_by_sender'] = 'true';
    if (fileId != null) fields['file_id'] = fileId;
    if (externalId != null) fields['external_id'] = externalId;
    if (customerId != null) fields['customer_id'] = customerId;
    if (metadata != null) fields['metadata'] = jsonEncode(metadata);
    if (ageGroup != null) fields['age_group'] = ageGroup;
    if (language != null) fields['language'] = language;
    if (supportThreshold != null) {
      fields['support_threshold'] = supportThreshold;
    }

    final data = await _multipartRequest(
      '/api/v1/safety/document',
      file: file,
      filename: filename,
      fieldName: 'file',
      fields: fields,
      contentType: contentType,
    );
    return DocumentAnalysisResult.fromJson(data);
  }

  // ===========================================================================
  // Webhooks
  // ===========================================================================

  /// List all webhooks.
  Future<WebhookListResult> listWebhooks() async {
    final data = await _requestWithMethod('GET', '/api/v1/webhooks');
    return WebhookListResult.fromJson(data);
  }

  /// Create a new webhook.
  ///
  /// The signing secret is returned only here; store it to verify
  /// deliveries. Not retried, so a timeout never creates a duplicate.
  Future<CreateWebhookResult> createWebhook(CreateWebhookInput input) async {
    final body = <String, dynamic>{
      'name': input.name,
      'url': input.url,
      'events': input.events,
    };
    if (input.headers != null) body['headers'] = input.headers;
    final data = await _requestWithMethod(
      'POST',
      '/api/v1/webhooks',
      body: body,
      retry: false,
    );
    return CreateWebhookResult.fromJson(data);
  }

  /// Update an existing webhook.
  Future<UpdateWebhookResult> updateWebhook(
      String id, UpdateWebhookInput input) async {
    final body = <String, dynamic>{};
    if (input.name != null) body['name'] = input.name;
    if (input.url != null) body['url'] = input.url;
    if (input.events != null) body['events'] = input.events;
    if (input.active != null) body['is_active'] = input.active;
    if (input.headers != null) body['headers'] = input.headers;
    final data = await _requestWithMethod(
      'PUT',
      '/api/v1/webhooks/${Uri.encodeComponent(id)}',
      body: body,
    );
    return UpdateWebhookResult.fromJson(data);
  }

  /// Delete a webhook.
  Future<DeleteWebhookResult> deleteWebhook(String id) async {
    final data = await _requestWithMethod(
        'DELETE', '/api/v1/webhooks/${Uri.encodeComponent(id)}');
    return DeleteWebhookResult.fromJson(data);
  }

  /// Test a webhook by sending a test event.
  Future<TestWebhookResult> testWebhook(String id) async {
    final data = await _request('/api/v1/webhooks/test', {'webhook_id': id});
    return TestWebhookResult.fromJson(data);
  }

  /// Regenerate the secret for a webhook.
  Future<RegenerateSecretResult> regenerateWebhookSecret(String id) async {
    final data = await _request(
        '/api/v1/webhooks/${Uri.encodeComponent(id)}/regenerate-secret', {});
    return RegenerateSecretResult.fromJson(data);
  }

  // ===========================================================================
  // Pricing
  // ===========================================================================

  /// Get pricing overview.
  Future<PricingResult> getPricing() async {
    final data = await _requestWithMethod('GET', '/api/v1/pricing');
    return PricingResult.fromJson(data);
  }

  /// Get detailed pricing information.
  Future<PricingDetailsResult> getPricingDetails() async {
    final data = await _requestWithMethod('GET', '/api/v1/pricing/details');
    return PricingDetailsResult.fromJson(data);
  }

  // ===========================================================================
  // Usage
  // ===========================================================================

  /// Get usage history (daily breakdown).
  Future<UsageHistoryResult> getUsageHistory({int? days}) async {
    final query = days != null ? '?days=$days' : '';
    final data =
        await _requestWithMethod('GET', '/api/v1/usage/history$query');
    return UsageHistoryResult.fromJson(data);
  }

  /// Get usage broken down by tool/endpoint.
  Future<UsageByToolResult> getUsageByTool({String? date}) async {
    final query = date != null ? '?date=$date' : '';
    final data =
        await _requestWithMethod('GET', '/api/v1/usage/by-tool$query');
    return UsageByToolResult.fromJson(data);
  }

  /// Get monthly usage summary with billing and rate limit info.
  Future<UsageMonthlyResult> getUsageMonthly() async {
    final data = await _requestWithMethod('GET', '/api/v1/usage/monthly');
    return UsageMonthlyResult.fromJson(data);
  }

  /// Get request counts for a day (default today) with the plan's limits.
  Future<UsageSummary> getUsageSummary({String? date}) async {
    final data = await _requestWithMethod(
      'GET',
      _withQuery('/api/v1/usage/summary', {if (date != null) 'date': date}),
    );
    return UsageSummary.fromJson(data);
  }

  /// Get the current rate-limit and quota state of the API key.
  Future<UsageQuota> getQuota() async {
    final data = await _requestWithMethod('GET', '/api/v1/usage/quota');
    return UsageQuota.fromJson(data);
  }

  // ===========================================================================
  // Synthetic Content
  // ===========================================================================

  /// Detect AI-generated text.
  Future<SyntheticContentResult> detectSyntheticText(
    String content, {
    AnalysisContext? context,
    String? supportThreshold,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    final ctx = context?.toJson() ?? <String, dynamic>{};
    ctx['platform'] = _resolvePlatform(context?.platform);
    final body = <String, dynamic>{'text': content, 'context': ctx};
    if (externalId != null) body['external_id'] = externalId;
    if (customerId != null) body['customer_id'] = customerId;
    if (metadata != null) body['metadata'] = metadata;
    if (supportThreshold != null) {
      body['options'] = {'support_threshold': supportThreshold};
    }
    final data = await _request('/api/v1/safety/synthetic-content', body);
    return SyntheticContentResult.fromJson(data);
  }

  /// Detect an AI-generated or manipulated image.
  Future<SyntheticContentResult> detectSyntheticImage({
    required List<int> file,
    required String filename,
    String? contentType,
    String? fileId,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
    String? ageGroup,
    String? language,
    String? platform,
  }) {
    return _syntheticMedia(
      '/api/v1/safety/synthetic-content/image',
      file: file,
      filename: filename,
      contentType: contentType,
      fields: _mediaFields(
        fileId: fileId,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
        ageGroup: ageGroup,
        language: language,
        platform: platform,
      ),
    );
  }

  /// Detect synthetic or cloned speech in an audio file.
  Future<SyntheticContentResult> detectSyntheticAudio({
    required List<int> file,
    required String filename,
    String? contentType,
    String? fileId,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
    String? ageGroup,
    String? language,
    String? platform,
  }) {
    return _syntheticMedia(
      '/api/v1/safety/synthetic-content/audio',
      file: file,
      filename: filename,
      contentType: contentType,
      fields: _mediaFields(
        fileId: fileId,
        externalId: externalId,
        customerId: customerId,
        metadata: metadata,
        ageGroup: ageGroup,
        language: language,
        platform: platform,
      ),
    );
  }

  /// Detect a synthetic or manipulated video.
  Future<SyntheticContentResult> detectSyntheticVideo({
    required List<int> file,
    required String filename,
    String? contentType,
    int? maxFrames,
    String? fileId,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
    String? ageGroup,
    String? language,
    String? platform,
  }) {
    final fields = _mediaFields(
      fileId: fileId,
      externalId: externalId,
      customerId: customerId,
      metadata: metadata,
      ageGroup: ageGroup,
      language: language,
      platform: platform,
    );
    if (maxFrames != null) fields['max_frames'] = maxFrames.toString();
    return _syntheticMedia(
      '/api/v1/safety/synthetic-content/video',
      file: file,
      filename: filename,
      contentType: contentType,
      fields: fields,
    );
  }

  Future<SyntheticContentResult> _syntheticMedia(
    String path, {
    required List<int> file,
    required String filename,
    required String? contentType,
    required Map<String, String> fields,
  }) async {
    final data = await _multipartRequest(
      path,
      file: file,
      filename: filename,
      fieldName: 'file',
      fields: fields,
      contentType: contentType,
    );
    return SyntheticContentResult.fromJson(data);
  }

  Map<String, String> _mediaFields({
    String? fileId,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
    String? ageGroup,
    String? language,
    String? platform,
  }) {
    final fields = <String, String>{'platform': _resolvePlatform(platform)};
    if (fileId != null) fields['file_id'] = fileId;
    if (externalId != null) fields['external_id'] = externalId;
    if (customerId != null) fields['customer_id'] = customerId;
    if (metadata != null) fields['metadata'] = jsonEncode(metadata);
    if (ageGroup != null) fields['age_group'] = ageGroup;
    if (language != null) fields['language'] = language;
    return fields;
  }

  // ===========================================================================
  // Verification
  // ===========================================================================

  /// Create a hosted age or identity verification session.
  ///
  /// Open [VerificationSession.mobileUrl] on the user's phone, then poll
  /// [getVerificationSession] or listen for the `verification.completed`
  /// webhook. Not retried, so a timeout never creates a second session.
  Future<VerificationSession> createVerificationSession([
    CreateVerificationSessionInput input =
        const CreateVerificationSessionInput(),
  ]) async {
    final data = await _requestWithMethod(
      'POST',
      '/api/v1/verify/session',
      body: input.toJson(),
      retry: false,
    );
    return VerificationSession.fromJson(data);
  }

  /// Get the status, and once finished the result, of a verification
  /// session.
  Future<VerificationSessionResult> getVerificationSession(
      String sessionId) async {
    final data = await _requestWithMethod(
        'GET', '/api/v1/verify/session/${Uri.encodeComponent(sessionId)}');
    return VerificationSessionResult.fromJson(data);
  }

  /// Cancel a verification session.
  Future<void> cancelVerificationSession(String sessionId) async {
    await _requestWithMethod(
        'DELETE', '/api/v1/verify/session/${Uri.encodeComponent(sessionId)}');
  }

  /// Run face matching, age estimation, forensic and synthetic-image checks
  /// on one image. Images are processed in memory and never stored.
  ///
  /// [checks] is a subset of [ImageMatchCheck]; the API runs all of them by
  /// default, and `face_match` only runs with a [referenceImage].
  Future<VerifyImageMatchResult> verifyImageMatch({
    required List<int> image,
    List<int>? referenceImage,
    List<String>? checks,
    String? externalId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    if (image.isEmpty) throw ArgumentError('Image is required');
    final body = <String, dynamic>{'image': base64Encode(image)};
    if (referenceImage != null) {
      body['reference_image'] = base64Encode(referenceImage);
    }
    if (checks != null) body['checks'] = checks;
    if (externalId != null) body['external_id'] = externalId;
    if (customerId != null) body['customer_id'] = customerId;
    if (metadata != null) body['metadata'] = metadata;
    final data = await _request('/api/v1/verify-image-match', body);
    return VerifyImageMatchResult.fromJson(data);
  }

  // ===========================================================================
  // Incidents
  // ===========================================================================

  /// List the account's incidents, newest first.
  Future<ListIncidentsResult> listIncidents([
    ListIncidentsInput input = const ListIncidentsInput(),
  ]) async {
    final data = await _requestWithMethod(
        'GET', _withQuery('/api/v1/incidents', input.toQuery()));
    return ListIncidentsResult.fromJson(data);
  }

  /// Get one incident with its detail fields.
  Future<Incident> getIncident(String incidentId) async {
    final data = await _requestWithMethod(
        'GET', '/api/v1/incidents/${Uri.encodeComponent(incidentId)}');
    return Incident.fromJson(data);
  }

  /// Get incident counts for the account.
  Future<IncidentsOverview> getIncidentsOverview({
    String? from,
    String? to,
  }) async {
    final data = await _requestWithMethod(
      'GET',
      _withQuery('/api/v1/incidents/overview', {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      }),
    );
    return IncidentsOverview.fromJson(data);
  }

  /// Get incident counts over time, bucketed by `hour`, `day` or `week`.
  Future<IncidentTrends> getIncidentTrends({
    String? bucket,
    String? from,
    String? to,
  }) async {
    final data = await _requestWithMethod(
      'GET',
      _withQuery('/api/v1/incidents/trends', {
        if (bucket != null) 'bucket': bucket,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      }),
    );
    return IncidentTrends.fromJson(data);
  }

  /// Record a moderator decision on an incident.
  Future<ReviewIncidentResult> reviewIncident(
    String incidentId,
    ReviewIncidentInput input,
  ) async {
    _checkReview(input);
    final data = await _request(
      '/api/v1/incidents/${Uri.encodeComponent(incidentId)}/review',
      input.toJson(),
    );
    return ReviewIncidentResult.fromJson(data);
  }

  /// Record one moderator decision on up to 100 incidents.
  Future<BatchReviewIncidentsResult> batchReviewIncidents(
    List<String> incidentIds,
    ReviewIncidentInput input,
  ) async {
    if (incidentIds.isEmpty || incidentIds.length > 100) {
      throw ArgumentError('incidentIds must hold 1 to 100 incident IDs');
    }
    _checkReview(input);
    final data = await _request('/api/v1/incidents/batch-review', {
      'incident_ids': incidentIds,
      ...input.toJson(),
    });
    return BatchReviewIncidentsResult.fromJson(data);
  }

  void _checkReview(ReviewIncidentInput input) {
    if (input.moderatorExternalId.isEmpty) {
      throw ArgumentError('moderatorExternalId is required');
    }
    if (input.action == 'reclassify' && input.newRiskCategory == null) {
      throw ArgumentError('action "reclassify" requires newRiskCategory');
    }
  }

  static String _withQuery(String path, Map<String, String> query) =>
      query.isEmpty ? path : '$path?${Uri(queryParameters: query).query}';
}
