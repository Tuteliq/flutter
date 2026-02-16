import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

const String _voiceStreamUrl = 'wss://api.tuteliq.ai/voice/stream';

class VoiceStreamConfig {
  final int? intervalSeconds;
  final List<String>? analysisTypes;
  final Map<String, String>? context;

  const VoiceStreamConfig({
    this.intervalSeconds,
    this.analysisTypes,
    this.context,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': 'config'};
    if (intervalSeconds != null) map['interval_seconds'] = intervalSeconds;
    if (analysisTypes != null) map['analysis_types'] = analysisTypes;
    if (context != null) map['context'] = context;
    return map;
  }
}

class VoiceReadyEvent {
  final String sessionId;
  final Map<String, dynamic> config;

  VoiceReadyEvent({required this.sessionId, required this.config});

  factory VoiceReadyEvent.fromJson(Map<String, dynamic> json) {
    return VoiceReadyEvent(
      sessionId: json['session_id'] as String,
      config: json['config'] as Map<String, dynamic>? ?? {},
    );
  }
}

class VoiceTranscriptionSegment {
  final double start;
  final double end;
  final String text;

  VoiceTranscriptionSegment({required this.start, required this.end, required this.text});

  factory VoiceTranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return VoiceTranscriptionSegment(
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
    );
  }
}

class VoiceTranscriptionEvent {
  final String text;
  final List<VoiceTranscriptionSegment> segments;
  final int flushIndex;

  VoiceTranscriptionEvent({required this.text, required this.segments, required this.flushIndex});

  factory VoiceTranscriptionEvent.fromJson(Map<String, dynamic> json) {
    return VoiceTranscriptionEvent(
      text: json['text'] as String,
      segments: (json['segments'] as List<dynamic>?)
              ?.map((s) => VoiceTranscriptionSegment.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      flushIndex: json['flush_index'] as int,
    );
  }
}

class VoiceAlertEvent {
  final String category;
  final String severity;
  final double riskScore;
  final Map<String, dynamic> details;
  final int flushIndex;

  VoiceAlertEvent({
    required this.category,
    required this.severity,
    required this.riskScore,
    required this.details,
    required this.flushIndex,
  });

  factory VoiceAlertEvent.fromJson(Map<String, dynamic> json) {
    return VoiceAlertEvent(
      category: json['category'] as String,
      severity: json['severity'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      details: json['details'] as Map<String, dynamic>? ?? {},
      flushIndex: json['flush_index'] as int,
    );
  }
}

class VoiceSessionSummaryEvent {
  final String sessionId;
  final double durationSeconds;
  final String overallRisk;
  final double overallRiskScore;
  final int totalFlushes;
  final String transcript;

  VoiceSessionSummaryEvent({
    required this.sessionId,
    required this.durationSeconds,
    required this.overallRisk,
    required this.overallRiskScore,
    required this.totalFlushes,
    required this.transcript,
  });

  factory VoiceSessionSummaryEvent.fromJson(Map<String, dynamic> json) {
    return VoiceSessionSummaryEvent(
      sessionId: json['session_id'] as String,
      durationSeconds: (json['duration_seconds'] as num).toDouble(),
      overallRisk: json['overall_risk'] as String,
      overallRiskScore: (json['overall_risk_score'] as num).toDouble(),
      totalFlushes: json['total_flushes'] as int,
      transcript: json['transcript'] as String,
    );
  }
}

class VoiceConfigUpdatedEvent {
  final Map<String, dynamic> config;

  VoiceConfigUpdatedEvent({required this.config});

  factory VoiceConfigUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return VoiceConfigUpdatedEvent(
      config: json['config'] as Map<String, dynamic>? ?? {},
    );
  }
}

class VoiceErrorEvent {
  final String code;
  final String message;

  VoiceErrorEvent({required this.code, required this.message});

  factory VoiceErrorEvent.fromJson(Map<String, dynamic> json) {
    return VoiceErrorEvent(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }
}

class VoiceStreamHandlers {
  final void Function(VoiceReadyEvent)? onReady;
  final void Function(VoiceTranscriptionEvent)? onTranscription;
  final void Function(VoiceAlertEvent)? onAlert;
  final void Function(VoiceSessionSummaryEvent)? onSessionSummary;
  final void Function(VoiceConfigUpdatedEvent)? onConfigUpdated;
  final void Function(VoiceErrorEvent)? onError;
  final void Function(int code, String reason)? onClose;

  const VoiceStreamHandlers({
    this.onReady,
    this.onTranscription,
    this.onAlert,
    this.onSessionSummary,
    this.onConfigUpdated,
    this.onError,
    this.onClose,
  });
}

class VoiceStreamSession {
  final String _apiKey;
  final VoiceStreamConfig? _config;
  final VoiceStreamHandlers? _handlers;
  WebSocketChannel? _channel;
  String? _sessionId;
  bool _active = false;
  final Completer<VoiceSessionSummaryEvent> _summaryCompleter = Completer<VoiceSessionSummaryEvent>();
  StreamSubscription? _subscription;

  VoiceStreamSession(this._apiKey, this._config, this._handlers);

  String? get sessionId => _sessionId;
  bool get isActive => _active;

  Future<void> connect() async {
    final uri = Uri.parse(_voiceStreamUrl);
    _channel = WebSocketChannel.connect(
      uri,
      protocols: null,
    );

    // Note: WebSocketChannel.connect doesn't support custom headers directly.
    // The API key is sent as the first message after connection.
    await _channel!.ready;
    _active = true;

    // Send auth message
    _channel!.sink.add(jsonEncode({'type': 'auth', 'token': _apiKey}));

    // Send initial config
    if (_config != null) {
      _channel!.sink.add(jsonEncode(_config!.toJson()));
    }

    final readyCompleter = Completer<void>();

    _subscription = _channel!.stream.listen(
      (data) {
        try {
          final event = jsonDecode(data as String) as Map<String, dynamic>;
          final type = event['type'] as String?;

          switch (type) {
            case 'ready':
              final ready = VoiceReadyEvent.fromJson(event);
              _sessionId = ready.sessionId;
              _handlers?.onReady?.call(ready);
              if (!readyCompleter.isCompleted) readyCompleter.complete();
              break;
            case 'transcription':
              _handlers?.onTranscription?.call(VoiceTranscriptionEvent.fromJson(event));
              break;
            case 'alert':
              _handlers?.onAlert?.call(VoiceAlertEvent.fromJson(event));
              break;
            case 'session_summary':
              final summary = VoiceSessionSummaryEvent.fromJson(event);
              _handlers?.onSessionSummary?.call(summary);
              if (!_summaryCompleter.isCompleted) _summaryCompleter.complete(summary);
              break;
            case 'config_updated':
              _handlers?.onConfigUpdated?.call(VoiceConfigUpdatedEvent.fromJson(event));
              break;
            case 'error':
              _handlers?.onError?.call(VoiceErrorEvent.fromJson(event));
              break;
          }
        } catch (_) {}
      },
      onDone: () {
        _active = false;
        _handlers?.onClose?.call(1000, 'Connection closed');
        if (!_summaryCompleter.isCompleted) {
          _summaryCompleter.completeError(
            Exception('Connection closed before session summary'),
          );
        }
      },
      onError: (error) {
        _active = false;
        if (!readyCompleter.isCompleted) readyCompleter.completeError(error);
      },
    );

    await readyCompleter.future;
  }

  void sendAudio(Uint8List data) {
    if (!_active || _channel == null) {
      throw StateError('Voice stream is not connected');
    }
    _channel!.sink.add(data);
  }

  void updateConfig(VoiceStreamConfig newConfig) {
    if (!_active || _channel == null) {
      throw StateError('Voice stream is not connected');
    }
    _channel!.sink.add(jsonEncode(newConfig.toJson()));
  }

  Future<VoiceSessionSummaryEvent> end() async {
    if (!_active || _channel == null) {
      throw StateError('Voice stream is not connected');
    }
    _channel!.sink.add(jsonEncode({'type': 'end'}));
    return _summaryCompleter.future;
  }

  void close() {
    _active = false;
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
