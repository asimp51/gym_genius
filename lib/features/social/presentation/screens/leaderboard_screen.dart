import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../providers/social_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaders = ref.watch(leaderboardProvider);
    final user = ref.watch(currentUserProvider);
    final currentUserId = user?.id ?? '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding2XL),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
                child: TabBar(
                  onTap: (index) {
                    final types = ['volume', 'streaks', 'xp'];
                    ref.read(leaderboardTypeProvider.notifier).state = types[index];
                  },
                  indicator: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.text3,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Volume'),
                    Tab(text: 'Streaks'),
                    Tab(text: 'XP'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: _LeaderList(leaders: leaders, currentUserId: currentUserId),
      ),
    );
  }
}

class _LeaderList extends StatelessWidget {
  final List<Map<String, dynamic>> leaders;
  final String currentUserId;

  const _LeaderList({required this.leaders, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    if (leaders.isEmpty) {
      return const Center(child: Text('No data yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.padding2XL),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: leaders.length,
      itemBuilder: (context, index) {
        final l = leaders[index];
        final rank = l['rank'] as int? ?? (index + 1);
        final name = l['name'] as String? ?? 'Unknown';
        final value = l['value'] as String? ?? '';
        final userId = l['userId'] as String? ?? '';
        final isUser = userId == currentUserId || name.contains('You');
        final medal = rank <= 3
            ? ['\ud83e\udd47', '\ud83e\udd48', '\ud83e\udd49'][rank - 1]
            : '';

        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: isUser ? AppColors.accent : AppColors.border,
              width: isUser ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: medal.isNotEmpty
                    ? Text(medal, style: const TextStyle(fontSize: 22))
                    : Text(
                        '#$rank',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text3,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundColor: isUser
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.bgTertiary,
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: AppTypography.caption.copyWith(
                    color: isUser ? AppColors.accent : AppColors.text2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isUser ? '$name (You)' : name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isUser ? AppColors.accent : AppColors.text1,
                  ),
                ),
              ),
              Text(
                value,
                style: AppTypography.caption.copyWith(
                  color: AppColors.text1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
