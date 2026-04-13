import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../providers/b2b_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(currentOrganizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: orgAsync.when(
        data: (org) {
          if (org == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined,
                      size: 64, color: AppColors.text3),
                  const SizedBox(height: 16),
                  Text('No organization found',
                      style: AppTypography.h2),
                  const SizedBox(height: 8),
                  Text('Create or join an organization to get started',
                      style: AppTypography.caption),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/b2b-onboarding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusButton),
                      ),
                    ),
                    child:
                        Text('Get Started', style: AppTypography.button),
                  ),
                ],
              ),
            );
          }
          return _DashboardContent(org: org);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final Organization org;
  const _DashboardContent({required this.org});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(orgAnalyticsProvider(org.id));
    final recentAsync = ref.watch(recentActivityProvider(org.id));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgPrimary,
            floating: true,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _hexToColor(org.branding.primaryColorHex),
                        _hexToColor(org.branding.secondaryColorHex ??
                            org.branding.primaryColorHex),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      org.name[0],
                      style: AppTypography.button
                          .copyWith(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(org.name,
                          style: AppTypography.h3, overflow: TextOverflow.ellipsis),
                      Text('Admin Dashboard',
                          style: AppTypography.caption.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: AppColors.text2),
                onPressed: () => context.push('/b2b-settings'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.padding2XL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Overview Cards
                analyticsAsync.when(
                  data: (analytics) =>
                      _OverviewCards(analytics: analytics),
                  loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 24),

                // Workouts by Day Chart
                analyticsAsync.when(
                  data: (analytics) =>
                      _WorkoutsByDayChart(workoutsByDay: analytics.workoutsByDay),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text('Quick Actions', style: AppTypography.h2),
                const SizedBox(height: 12),
                _QuickActionsGrid(org: org),
                const SizedBox(height: 24),

                // Top Performers
                analyticsAsync.when(
                  data: (analytics) =>
                      _TopPerformers(topMembers: analytics.topMembers),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Recent Activity
                Text('Recent Activity', style: AppTypography.h2),
                const SizedBox(height: 12),
                recentAsync.when(
                  data: (activities) =>
                      _RecentActivityList(activities: activities),
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class _OverviewCards extends StatelessWidget {
  final OrganizationAnalytics analytics;
  const _OverviewCards({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Members',
                value: '${analytics.totalMembers}',
                subtitle: '+${analytics.newMembersThisMonth} this month',
                icon: Icons.people,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Active Today',
                value: '${analytics.activeMembers}',
                subtitle:
                    '${((analytics.activeMembers / analytics.totalMembers) * 100).toStringAsFixed(0)}% of total',
                icon: Icons.flash_on,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Workouts/Week',
                value: analytics.avgWorkoutsPerWeek.toStringAsFixed(1),
                subtitle: '${analytics.totalWorkoutsThisMonth} this month',
                icon: Icons.fitness_center,
                color: AppColors.accentSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Completion',
                value: '${analytics.avgCompletionRate.toStringAsFixed(0)}%',
                subtitle:
                    '${analytics.retentionRate.toStringAsFixed(0)}% retention',
                icon: Icons.check_circle_outline,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: AppTypography.caption.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.statLarge.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: AppTypography.caption.copyWith(
                  fontSize: 10, color: AppColors.text3)),
        ],
      ),
    );
  }
}

class _WorkoutsByDayChart extends StatelessWidget {
  final Map<String, int> workoutsByDay;
  const _WorkoutsByDayChart({required this.workoutsByDay});

  @override
  Widget build(BuildContext context) {
    final maxVal = workoutsByDay.values.fold<int>(
        0, (prev, e) => e > prev ? e : prev);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workouts by Day', style: AppTypography.h3),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final val = workoutsByDay[day] ?? 0;
                final height = maxVal > 0 ? (val / maxVal) * 110 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$val',
                            style: AppTypography.caption
                                .copyWith(fontSize: 10)),
                        const SizedBox(height: 4),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.accent,
                                AppColors.accentSecondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(day,
                            style: AppTypography.caption
                                .copyWith(fontSize: 10)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final Organization org;
  const _QuickActionsGrid({required this.org});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
          'Members', Icons.people_outline, AppColors.accent, '/b2b-members'),
      _QuickAction('Programs', Icons.assignment_outlined,
          AppColors.accentSecondary, '/b2b-program-builder'),
      _QuickAction(
          'Trainers', Icons.sports_outlined, AppColors.success, '/b2b-trainer'),
      _QuickAction('Analytics', Icons.analytics_outlined, AppColors.warning,
          '/b2b-analytics'),
      _QuickAction(
          'Branding', Icons.palette_outlined, AppColors.error, '/b2b-branding'),
      _QuickAction('Settings', Icons.tune_outlined, AppColors.text2,
          '/b2b-settings'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () => context.push(action.route),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action.icon, color: action.color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(action.label,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.text1, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickAction(this.label, this.icon, this.color, this.route);
}

class _TopPerformers extends StatelessWidget {
  final List<MemberActivity> topMembers;
  const _TopPerformers({required this.topMembers});

  @override
  Widget build(BuildContext context) {
    if (topMembers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Performers', style: AppTypography.h2),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(topMembers.length, (index) {
              final member = topMembers[index];
              final medal = index == 0
                  ? Icons.emoji_events
                  : index == 1
                      ? Icons.emoji_events
                      : index == 2
                          ? Icons.emoji_events
                          : null;
              final medalColor = index == 0
                  ? const Color(0xFFFFD700)
                  : index == 1
                      ? const Color(0xFFC0C0C0)
                      : index == 2
                          ? const Color(0xFFCD7F32)
                          : null;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: medal != null
                              ? Icon(medal, size: 20, color: medalColor)
                              : Text('${index + 1}',
                                  style: AppTypography.caption,
                                  textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                          child: Text(
                            member.name[0],
                            style: AppTypography.button
                                .copyWith(color: AppColors.accent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member.name,
                                  style: AppTypography.body
                                      .copyWith(fontWeight: FontWeight.w500)),
                              Text(
                                  '${member.workoutsThisWeek} workouts this week',
                                  style: AppTypography.caption
                                      .copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department,
                                    size: 14, color: AppColors.warning),
                                const SizedBox(width: 2),
                                Text('${member.currentStreak}',
                                    style: AppTypography.caption.copyWith(
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Text(
                                '${(member.volumeThisWeek / 1000).toStringAsFixed(1)}k lbs',
                                style: AppTypography.caption
                                    .copyWith(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (index < topMembers.length - 1)
                    const Divider(
                        height: 1, color: AppColors.border, indent: 56),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final List<RecentActivityItem> activities;
  const _RecentActivityList({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(activities.length, (index) {
          final activity = activities[index];
          final icon = _activityIcon(activity.action);
          final color = _activityColor(activity.action);
          final timeAgo = _timeAgo(activity.timestamp);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity.userName,
                              style: AppTypography.body
                                  .copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
                          Text(activity.description,
                              style: AppTypography.caption
                                  .copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(timeAgo,
                        style:
                            AppTypography.caption.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              if (index < activities.length - 1)
                const Divider(
                    height: 1, color: AppColors.border, indent: 60),
            ],
          );
        }),
      ),
    );
  }

  IconData _activityIcon(String action) {
    switch (action) {
      case 'completed_workout':
        return Icons.fitness_center;
      case 'new_pr':
        return Icons.emoji_events;
      case 'streak':
        return Icons.local_fire_department;
      case 'joined':
        return Icons.person_add;
      default:
        return Icons.circle;
    }
  }

  Color _activityColor(String action) {
    switch (action) {
      case 'completed_workout':
        return AppColors.accent;
      case 'new_pr':
        return AppColors.warning;
      case 'streak':
        return AppColors.error;
      case 'joined':
        return AppColors.success;
      default:
        return AppColors.text3;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
