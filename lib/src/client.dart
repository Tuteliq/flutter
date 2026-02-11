import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'enums.dart';
import 'errors.dart';
import 'models.dart';

/// SafeNest API client for child safety analysis.
///
/// Example:
/// ```dart
/// final client = SafeNest(apiKey: 'your-api-key');
/// final result = await client.detectBullying('Some text to analyze');
/// if (result.isBullying) {
///   print('Severity: ${result.severity}');
/// }
/// ```
class SafeNest {
  /// Creates a new SafeNest client.
  ///
  /// [apiKey] is required and must be a valid SafeNest API key.
  /// [timeout] is the request timeout (default: 30 seconds).
  /// [maxRetries] is the number of retry attempts for transient failures.
  /// [retryDelay] is the initial retry delay.
  /// [baseUrl] is the API base URL (default: https://api.safenest.dev).
  SafeNest({
    required String apiKey,
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String baseUrl = 'https://api.safenest.dev',
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
    if (context != null) body['context'] = context.toJson();
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
    if (contextMap.isNotEmpty) body['context'] = contextMap;

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
    if (context != null) body['context'] = context.toJson();
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

    return AnalyzeResult(
      riskLevel: riskLevel,
      riskScore: maxRiskScore,
      summary: summary,
      bullying: bullyingResult,
      unsafe: unsafeResult,
      recommendedAction: recommendedAction,
      externalId: externalId,
      metadata: metadata,
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
    if (context != null) body['context'] = context.toJson();
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

    if (input.context != null) body['context'] = input.context!.toJson();
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
      } catch (e) {
        lastError = e as Exception;
        if (attempt < _maxRetries - 1) {
          await Future.delayed(_retryDelay * (1 << attempt));
        }
      }
    }

    throw lastError ?? const SafeNestException('Request failed after retries');
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
      case 404:
        throw NotFoundException(message, details);
      case 429:
        throw RateLimitException(message, details);
      default:
        if (response.statusCode >= 500) {
          throw ServerException(message, response.statusCode, details);
        }
        throw SafeNestException(message, details);
    }
  }
}
