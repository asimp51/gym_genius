import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

/// Service for communicating with native companion watch apps
/// (Apple Watch via WatchConnectivity, Wear OS via DataLayer API).
///
/// Uses platform channels to send/receive data between the Flutter
/// phone app and the native watch app.
class WatchCommunicationService {
  static const _channel =
      MethodChannel('com.gymgenius/watch_communication');
  static const _eventChannel =
      EventChannel('com.gymgenius/watch_events');

  StreamSubscription? _eventSub;
  final _messageController =
      StreamController<WatchMessage>.broadcast();

  bool _isWatchConnected = false;
  bool _isWatchAppInstalled = false;
  String? _watchModel;

  bool get isWatchConnected => _isWatchConnected;
  bool get isWatchAppInstalled => _isWatchAppInstalled;
  String? get watchModel => _watchModel;

  /// Stream of messages received from the watch.
  Stream<WatchMessage> get messages => _messageController.stream;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize the watch communication channel and start listening
  /// for events from the native layer.
  Future<void> initialize() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;

    try {
      final result = await _channel.invokeMethod<Map>('initialize');
      _isWatchConnected = result?['isConnected'] as bool? ?? false;
      _isWatchAppInstalled = result?['isAppInstalled'] as bool? ?? false;
      _watchModel = result?['watchModel'] as String?;
    } on PlatformException {
      _isWatchConnected = false;
    }

    // Listen for events from the watch.
    _eventSub = _eventChannel
        .receiveBroadcastStream()
        .map((event) => WatchMessage.fromMap(
            Map<String, dynamic>.from(event as Map)))
        .listen(
      (message) {
        _handleWatchMessage(message);
        if (!_messageController.isClosed) {
          _messageController.add(message);
        }
      },
      onError: (_) {},
    );
  }

  // ---------------------------------------------------------------------------
  // Send Data to Watch
  // ---------------------------------------------------------------------------

  /// Send the current workout state to the watch for display.
  Future<void> sendWorkoutState({
    required String workoutName,
    required String currentExercise,
    required int currentSet,
    required int totalSets,
    required int elapsedSeconds,
    required bool isResting,
    required int restSecondsRemaining,
  }) async {
    await _sendMessage('workout_state', {
      'workoutName': workoutName,
      'currentExercise': currentExercise,
      'currentSet': currentSet,
      'totalSets': totalSets,
      'elapsedSeconds': elapsedSeconds,
      'isResting': isResting,
      'restSecondsRemaining': restSecondsRemaining,
    });
  }

  /// Send workout template list to the watch for standalone workout selection.
  Future<void> syncTemplates(List<Map<String, dynamic>> templates) async {
    await _sendMessage('sync_templates', {
      'templates': templates,
    });
  }

  /// Notify the watch that a rest timer has started.
  Future<void> startRestTimer(int durationSeconds) async {
    await _sendMessage('rest_timer_start', {
      'duration': durationSeconds,
    });
  }

  /// Notify the watch that the workout has ended.
  Future<void> sendWorkoutComplete({
    required int durationMinutes,
    required int totalSets,
    required double totalVolume,
    required double calories,
  }) async {
    await _sendMessage('workout_complete', {
      'durationMinutes': durationMinutes,
      'totalSets': totalSets,
      'totalVolume': totalVolume,
      'calories': calories,
    });
  }

  // ---------------------------------------------------------------------------
  // Receive Data from Watch
  // ---------------------------------------------------------------------------

  void _handleWatchMessage(WatchMessage message) {
    switch (message.type) {
      case 'set_completed':
        // Watch user tapped "done" on a set.
        break;
      case 'heart_rate_update':
        // Real-time HR from the watch sensor.
        break;
      case 'workout_started_from_watch':
        // User started a workout directly on the watch.
        break;
      case 'connection_status':
        _isWatchConnected = message.data['isConnected'] as bool? ?? false;
        break;
      default:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _sendMessage(
      String type, Map<String, dynamic> data) async {
    if (!_isWatchConnected) return;
    try {
      await _channel.invokeMethod('sendMessage', {
        'type': type,
        'data': jsonEncode(data),
      });
    } on PlatformException {
      // Watch may have disconnected.
    }
  }

  /// Clean up resources.
  void dispose() {
    _eventSub?.cancel();
    _messageController.close();
  }
}

/// A message sent to or received from the companion watch app.
class WatchMessage {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const WatchMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  factory WatchMessage.fromMap(Map<String, dynamic> map) {
    return WatchMessage(
      type: map['type'] as String? ?? 'unknown',
      data: map['data'] is String
          ? Map<String, dynamic>.from(
              jsonDecode(map['data'] as String) as Map)
          : Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
    );
  }
}
