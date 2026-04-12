import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../config/health_config.dart';
import '../../domain/health_models.dart';
import '../providers/wearable_providers.dart';

class ConnectedDevicesScreen extends ConsumerStatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  ConsumerState<ConnectedDevicesScreen> createState() =>
      _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState
    extends ConsumerState<ConnectedDevicesScreen> {
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    // Initialize watch communication on screen load.
    Future.microtask(() {
      ref.read(wearableConnectionProvider.notifier).initializeWatch();
    });
  }

  Future<void> _connectHealth() async {
    setState(() => _isConnecting = true);
    final success = await ref
        .read(wearableConnectionProvider.notifier)
        .connectHealth();
    setState(() => _isConnecting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Connected to ${HealthConfig.platformName}'
                : 'Could not connect. Please check permissions.',
          ),
          backgroundColor:
              success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _syncNow() async {
    await ref.read(wearableConnectionProvider.notifier).syncNow();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data synced successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(wearableConnectionProvider);
    final healthSummary = ref.watch(todayHealthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Devices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        children: [
          // Health Platform Connection
          _SectionTitle('Health Platform'),
          const SizedBox(height: 8),
          _buildHealthPlatformCard(connectionState),
          const SizedBox(height: 24),

          // Connected Watch
          _SectionTitle('Smartwatch'),
          const SizedBox(height: 8),
          _buildWatchCard(connectionState),
          const SizedBox(height: 24),

          // Synced Data Summary
          connectionState.when(
            data: (state) {
              if (!state.isHealthConnected) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Today\'s Health Data'),
                  const SizedBox(height: 8),
                  _buildHealthDataCard(healthSummary),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Sync Settings
          _SectionTitle('Sync Settings'),
          const SizedBox(height: 8),
          _buildSyncSettingsCard(connectionState),
          const SizedBox(height: 24),

          // Permissions Info
          _SectionTitle('Data Access'),
          const SizedBox(height: 8),
          _buildPermissionsInfoCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHealthPlatformCard(
      AsyncValue<WearableConnectionState> connectionState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: connectionState.when(
        data: (state) => Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: state.isHealthConnected
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.bgTertiary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: state.isHealthConnected
                        ? AppColors.success
                        : AppColors.text3,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(HealthConfig.platformName,
                          style: AppTypography.h3),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: state.isHealthConnected
                                  ? AppColors.success
                                  : AppColors.text3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.isHealthConnected
                                ? 'Connected'
                                : 'Not Connected',
                            style: AppTypography.caption.copyWith(
                              color: state.isHealthConnected
                                  ? AppColors.success
                                  : AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.isHealthConnected)
                  IconButton(
                    onPressed: _syncNow,
                    icon: const Icon(Icons.sync, color: AppColors.accent),
                    tooltip: 'Sync Now',
                  )
                else
                  _ConnectActionButton(
                    isLoading: _isConnecting,
                    onPressed: _connectHealth,
                  ),
              ],
            ),
            if (state.lastSyncTime != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.text3),
                    const SizedBox(width: 6),
                    Text(
                      'Last synced: ${DateFormat('MMM d, h:mm a').format(state.lastSyncTime!)}',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, _) => Text(
          'Error: $e',
          style: AppTypography.caption.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildWatchCard(
      AsyncValue<WearableConnectionState> connectionState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: connectionState.when(
        data: (state) => Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: state.isWatchConnected
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : AppColors.bgTertiary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              ),
              child: Icon(
                Icons.watch,
                color: state.isWatchConnected
                    ? AppColors.accent
                    : AppColors.text3,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.watchModel ?? 'Smartwatch',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isWatchConnected
                              ? AppColors.success
                              : AppColors.text3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.isWatchConnected
                            ? 'Connected'
                            : 'Not Detected',
                        style: AppTypography.caption.copyWith(
                          color: state.isWatchConnected
                              ? AppColors.success
                              : AppColors.text3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!state.isWatchConnected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusPill),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Pair in Settings',
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
              ),
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHealthDataCard(AsyncValue<HealthSummary> summaryAsync) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: summaryAsync.when(
        data: (summary) => Column(
          children: [
            Row(
              children: [
                _DataTile(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: NumberFormat('#,###').format(summary.steps),
                  color: AppColors.accent,
                ),
                _DataTile(
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: '${summary.caloriesBurned.toInt()}',
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _DataTile(
                  icon: Icons.favorite,
                  label: 'Heart Rate',
                  value: summary.currentHeartRate != null
                      ? '${summary.currentHeartRate} bpm'
                      : '--',
                  color: AppColors.error,
                ),
                _DataTile(
                  icon: Icons.timer,
                  label: 'Active Min',
                  value: '${summary.activeMinutes}',
                  color: AppColors.success,
                ),
              ],
            ),
            if (summary.restingHeartRate != null ||
                summary.floorsClimbed != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (summary.restingHeartRate != null)
                    _DataTile(
                      icon: Icons.hotel,
                      label: 'Resting HR',
                      value: '${summary.restingHeartRate} bpm',
                      color: AppColors.accentSecondary,
                    ),
                  if (summary.floorsClimbed != null)
                    _DataTile(
                      icon: Icons.stairs,
                      label: 'Floors',
                      value: '${summary.floorsClimbed}',
                      color: AppColors.accent,
                    ),
                ],
              ),
            ],
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, __) => Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Unable to load health data',
            style:
                AppTypography.caption.copyWith(color: AppColors.text3),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncSettingsCard(
      AsyncValue<WearableConnectionState> connectionState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: connectionState.when(
        data: (state) => Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.sync,
                      size: 22, color: AppColors.text2),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auto-Sync Workouts',
                            style: AppTypography.body),
                        Text(
                          'Automatically save workouts to ${HealthConfig.platformName}',
                          style: AppTypography.caption
                              .copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.autoSync,
                    onChanged: state.isHealthConnected
                        ? (v) => ref
                            .read(wearableConnectionProvider.notifier)
                            .toggleAutoSync(v)
                        : null,
                  ),
                ],
              ),
            ),
            const Divider(
                height: 1, color: AppColors.border, indent: 52),
            InkWell(
              onTap: state.isHealthConnected ? _syncNow : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.refresh,
                        size: 22,
                        color: state.isHealthConnected
                            ? AppColors.text2
                            : AppColors.text3),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Sync Now',
                        style: AppTypography.body.copyWith(
                          color: state.isHealthConnected
                              ? AppColors.text1
                              : AppColors.text3,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 20,
                        color: state.isHealthConnected
                            ? AppColors.text3
                            : AppColors.text3.withValues(alpha: 0.3)),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPermissionsInfoCard() {
    final descriptions = HealthConfig.permissionDescriptions;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GymGenius requests access to the following health data:',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 12),
          ...descriptions.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key,
                              style: AppTypography.body.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          Text(e.value,
                              style: AppTypography.caption
                                  .copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: AppTypography.caption
            .copyWith(fontSize: 13, fontWeight: FontWeight.w600));
  }
}

class _DataTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DataTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTypography.stat.copyWith(
                      fontSize: 14,
                      color: AppColors.text1,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _ConnectActionButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Connect',
                style: AppTypography.button.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}
