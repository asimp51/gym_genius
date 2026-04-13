import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../b2b/presentation/providers/b2b_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final level = ref.watch(currentLevelProvider);
    final totalWorkouts = ref.watch(totalWorkoutsCountProvider);
    final personalRecords = ref.watch(personalRecordsProvider);

    final isB2B = ref.watch(isB2BUserProvider);
    final b2bRole = ref.watch(currentB2BRoleProvider);

    final name = user?.displayName ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final streak = user?.stats.currentStreak ?? 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.padding2XL,
            AppDimensions.padding3XL,
            AppDimensions.padding2XL,
            AppDimensions.bottomNavHeight + 24,
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: AppTypography.display.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(name, style: AppTypography.h1),
              const SizedBox(height: 4),
              Text(
                user != null
                    ? 'Member since ${_formatDate(user.createdAt)}'
                    : '',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 24),

              // Mini stat tiles
              Row(
                children: [
                  _MiniStat(label: 'Workouts', value: '$totalWorkouts'),
                  const SizedBox(width: 6),
                  _MiniStat(label: 'Streak', value: '$streak'),
                  const SizedBox(width: 6),
                  _MiniStat(label: 'PRs', value: '${personalRecords.length}'),
                  const SizedBox(width: 6),
                  _MiniStat(label: 'Level', value: '$level'),
                ],
              ),
              const SizedBox(height: 24),

              // Menu items
              _MenuSection(
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _MenuItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Achievements',
                    onTap: () => context.push('/achievements'),
                  ),
                  _MenuItem(
                    icon: Icons.restaurant_outlined,
                    label: 'Nutrition',
                    onTap: () => context.push('/nutrition'),
                  ),
                  _MenuItem(
                    icon: Icons.menu_book_outlined,
                    label: 'Meal Planner',
                    onTap: () => context.push('/meal-planner'),
                  ),
                  _MenuItem(
                    icon: Icons.people_outline,
                    label: 'Social',
                    onTap: () => context.push('/social-feed'),
                  ),
                  _MenuItem(
                    icon: Icons.leaderboard_outlined,
                    label: 'Leaderboard',
                    onTap: () => context.push('/leaderboard'),
                  ),
                  if (isB2B && b2bRole == 'admin')
                    _MenuItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Business Dashboard',
                      onTap: () => context.push('/b2b-admin'),
                    ),
                  if (isB2B && b2bRole == 'trainer')
                    _MenuItem(
                      icon: Icons.sports_outlined,
                      label: 'My Clients',
                      onTap: () => context.push('/b2b-trainer'),
                    ),
                  if (!isB2B)
                    _MenuItem(
                      icon: Icons.business_center_outlined,
                      label: 'For Business',
                      onTap: () => context.push('/b2b-onboarding'),
                    ),
                  if (!isB2B)
                    _MenuItem(
                      icon: Icons.group_add_outlined,
                      label: 'Join Organization',
                      onTap: () => context.push('/b2b-join'),
                    ),
                  _MenuItem(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Subscription',
                    onTap: () => context.push('/subscription'),
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                  _MenuItem(
                    icon: Icons.logout,
                    label: 'Log Out',
                    isDestructive: true,
                    onTap: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/welcome');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTypography.stat.copyWith(fontSize: 18)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: index == 0
                      ? const Radius.circular(AppDimensions.radiusCard)
                      : Radius.zero,
                  bottom: index == items.length - 1
                      ? const Radius.circular(AppDimensions.radiusCard)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: item.isDestructive
                            ? AppColors.error
                            : AppColors.text2,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTypography.body.copyWith(
                            color: item.isDestructive
                                ? AppColors.error
                                : AppColors.text1,
                          ),
                        ),
                      ),
                      if (!item.isDestructive)
                        const Icon(Icons.chevron_right,
                            size: 20, color: AppColors.text3),
                    ],
                  ),
                ),
              ),
              if (index < items.length - 1)
                const Divider(
                  height: 1,
                  color: AppColors.border,
                  indent: 52,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}
