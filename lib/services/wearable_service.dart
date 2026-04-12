import 'dart:async';
import '../features/wearables/data/health_repository.dart';
import '../features/wearables/domain/health_models.dart';

/// Platform-agnostic service that sits on top of [HealthRepository] and
/// manages the lifecycle of health data connections, caching, and
/// bidirectional sync.
class WearableService {
  final HealthRepository _healthRepo;

  WearableService({HealthRepository? healthRepository})
      : _healthRepo = healthRepository ?? HealthRepository();

  HealthRepository get healthRepository => _healthRepo;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isConnected = false;
  bool _autoSync = true;
  HealthSummary? _cachedSummary;
  StreamSubscription<int>? _heartRateSub;
  final _heartRateController = StreamController<int>.broadcast();
  final List<int> _workoutHeartRateSamples = [];

  bool get isConnected => _isConnected;
  bool get autoSync => _autoSync;
  set autoSync(bool value) => _autoSync = value;
  HealthSummary? get cachedSummary => _cachedSummary;
  DateTime? get lastSyncTime => _healthRepo.lastSyncTime;

  // ---------------------------------------------------------------------------
  // Connection
  // ---------------------------------------------------------------------------

  /// Initialize: check availability and request permissions.
  Future<bool> connect() async {
    final available = await _healthRepo.isAvailable();
    if (!available) {
      _isConnected = false;
      return false;
    }
    final authorised = await _healthRepo.requestPermissions();
    _isConnected = authorised;
    if (authorised) {
      // Pre-fetch today's summary.
      _cachedSummary = await _healthRepo.getTodaysSummary();
    }
    return authorised;
  }

  /// Disconnect and clean up resources.
  Future<void> disconnect() async {
    _isConnected = false;
    _cachedSummary = null;
    await stopHeartRateMonitoring();
  }

  // ---------------------------------------------------------------------------
  // Read — Summary
  // ---------------------------------------------------------------------------

  /// Refresh today's health summary from the platform.
  Future<HealthSummary> refreshSummary() async {
    if (!_isConnected) return HealthSummary.empty();
    _cachedSummary = await _healthRepo.getTodaysSummary();
    return _cachedSummary!;
  }

  /// Get steps for a specific date.
  Future<int> getSteps({DateTime? date}) => _healthRepo.getSteps(date: date);

  /// Get calories burned for a specific date.
  Future<double> getCalories({DateTime? date}) =>
      _healthRepo.getCaloriesBurned(date: date);

  /// Get resting heart rate.
  Future<int?> getRestingHeartRate() => _healthRepo.getRestingHeartRate();

  /// Get last night's sleep data.
  Future<SleepData?> getSleepData() => _healthRepo.getLastNightSleep();

  /// Get workout history.
  Future<List<HealthWorkout>> getWorkoutHistory({int days = 30}) =>
      _healthRepo.getWorkoutHistory(days: days);

  // ---------------------------------------------------------------------------
  // Heart Rate Monitoring
  // ---------------------------------------------------------------------------

  /// Start real-time heart rate monitoring (e.g. during an active workout).
  /// Returns a broadcast stream of BPM values.
  Stream<int> startHeartRateMonitoring() {
    _workoutHeartRateSamples.clear();

    _heartRateSub?.cancel();
    _heartRateSub = _healthRepo.getHeartRateStream().listen(
      (bpm) {
        _workoutHeartRateSamples.add(bpm);
        if (!_heartRateController.isClosed) {
          _heartRateController.add(bpm);
        }
      },
      onError: (_) {},
    );

    return _heartRateController.stream;
  }

  /// Stop heart rate monitoring and return collected samples.
  Future<List<int>> stopHeartRateMonitoring() async {
    await _heartRateSub?.cancel();
    _heartRateSub = null;
    return List.unmodifiable(_workoutHeartRateSamples);
  }

  /// Heart rate samples collected during the current workout.
  List<int> get currentWorkoutHeartRateSamples =>
      List.unmodifiable(_workoutHeartRateSamples);

  // ---------------------------------------------------------------------------
  // Write — Save Workout
  // ---------------------------------------------------------------------------

  /// Save a completed workout to the health platform and return the
  /// heart rate samples collected during the session.
  Future<List<int>> saveWorkoutAndFinish(WorkoutHealthData data) async {
    if (_isConnected && _autoSync) {
      // Enrich with heart rate data collected during the workout.
      final enrichedData = WorkoutHealthData(
        workoutName: data.workoutName,
        workoutType: data.workoutType,
        startTime: data.startTime,
        endTime: data.endTime,
        totalCalories: data.totalCalories,
        totalVolume: data.totalVolume,
        totalSets: data.totalSets,
        totalReps: data.totalReps,
        heartRateSamples: _workoutHeartRateSamples.isNotEmpty
            ? _workoutHeartRateSamples
            : data.heartRateSamples,
      );
      await _healthRepo.saveWorkout(enrichedData);
    }

    final samples = await stopHeartRateMonitoring();
    return samples;
  }

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  /// Perform a full bidirectional sync.
  Future<void> fullSync() async {
    if (!_isConnected) return;
    _cachedSummary = await _healthRepo.getTodaysSummary();
  }

  /// Dispose of resources.
  void dispose() {
    _heartRateSub?.cancel();
    _heartRateController.close();
  }
}
