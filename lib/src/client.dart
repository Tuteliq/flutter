import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'enums.dart';
import 'errors.dart';
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
  Tuteliq({
    required String apiKey,
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String baseUrl = 'https://api.tuteliq.ai',
  })  : _apiKey = apiKey,
        _timeout = timeout,
        _maxRetries = maxRetries,
        _retryDelay = retryDelay,
        _baseUrl = baseUrl {
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
  final http.Client _client = http.Client();

  /// Current usage statistics (updated after each request).
  Usage? usage;

  /// Request ID from the last API call.
  String? lastRequestId;

  /// Create a voice streaming session over WebSocket.
  VoiceStreamSession voiceStream({
    VoiceStreamConfig? config,
    VoiceStreamHandlers? handlers,
  }) {
    return VoiceStreamSession(_apiKey, config, handlers);
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

    String recommendedAction;
    if (actions.contains('immediate_intervention')) {
      recommendedAction = 'immediate_intervention';
    } else if (actions.contains('flag_for_moderator')) {
      recommendedAction = 'flag_for_moderator';
    } else if (actions.contains('monitor')) {
      recommendedAction = 'monitor';
    } else {
      recommendedAction = 'none';
    }

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

  Future<Map<String, dynamic>> _requestWithMethod(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    Exception? lastError;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
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
        if (attempt < _maxRetries - 1) {
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
    ));

    final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send().timeout(_timeout);
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
  Future<VoiceAnalysisResult> analyzeVoice({
    required List<int> file,
    required String filename,
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
    );
    return VoiceAnalysisResult.fromJson(data);
  }

  // ===========================================================================
  // Image Analysis
  // ===========================================================================

  /// Analyze image content for safety concerns.
  Future<ImageAnalysisResult> analyzeImage({
    required List<int> file,
    required String filename,
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
    );
    return ImageAnalysisResult.fromJson(data);
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
  Future<CreateWebhookResult> createWebhook(CreateWebhookInput input) async {
    final body = <String, dynamic>{
      'url': input.url,
      'events': input.events,
      'active': input.active,
    };
    final data = await _request('/api/v1/webhooks', body);
    return CreateWebhookResult.fromJson(data);
  }

  /// Update an existing webhook.
  Future<UpdateWebhookResult> updateWebhook(
      String id, UpdateWebhookInput input) async {
    final body = <String, dynamic>{};
    if (input.url != null) body['url'] = input.url;
    if (input.events != null) body['events'] = input.events;
    if (input.active != null) body['active'] = input.active;
    final data = await _requestWithMethod(
      'PATCH',
      '/api/v1/webhooks/$id',
      body: body,
    );
    return UpdateWebhookResult.fromJson(data);
  }

  /// Delete a webhook.
  Future<DeleteWebhookResult> deleteWebhook(String id) async {
    final data = await _requestWithMethod('DELETE', '/api/v1/webhooks/$id');
    return DeleteWebhookResult.fromJson(data);
  }

  /// Test a webhook by sending a test event.
  Future<TestWebhookResult> testWebhook(String id) async {
    final data = await _request('/api/v1/webhooks/$id/test', {});
    return TestWebhookResult.fromJson(data);
  }

  /// Regenerate the secret for a webhook.
  Future<RegenerateSecretResult> regenerateWebhookSecret(String id) async {
    final data = await _request('/api/v1/webhooks/$id/secret', {});
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
}
