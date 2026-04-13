import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../providers/workout_providers.dart';
import '../providers/active_workout_provider.dart';

class WorkoutTemplatesScreen extends ConsumerWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTemplates = ref.watch(userTemplatesProvider);
    final recommended = ref.watch(systemTemplatesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.padding2XL,
            AppDimensions.paddingLG,
            AppDimensions.padding2XL,
            AppDimensions.bottomNavHeight + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workouts', style: AppTypography.h1),
              const SizedBox(height: 20),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add_rounded,
                      label: 'Create New',
                      onTap: () => context.push('/template-editor'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Start Empty',
                      onTap: () {
                        ref.read(activeWorkoutProvider.notifier).startEmpty('Quick Workout');
                        context.push('/active-workout');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // My Templates
              const SectionHeader(title: 'My Templates'),
              const SizedBox(height: 12),
              if (myTemplates.isEmpty)
                AppCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No templates yet', style: AppTypography.caption),
                    ),
                  ),
                )
              else
                ...myTemplates.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        onTap: () {
                          ref.read(selectedTemplateProvider.notifier).state = t;
                          context.push('/template-detail');
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.name,
                                  style: AppTypography.h3,
                                ),
                                Icon(Icons.chevron_right,
                                    color: AppColors.text3),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children:
                                  t.targetMuscles.map((m) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgTertiary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(m,
                                      style: AppTypography.caption
                                          .copyWith(fontSize: 10)),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.fitness_center,
                                    size: 14, color: AppColors.text3),
                                const SizedBox(width: 4),
                                Text('${t.exercises.length} exercises',
                                    style: AppTypography.caption),
                                const SizedBox(width: 16),
                                Icon(Icons.timer_outlined,
                                    size: 14, color: AppColors.text3),
                                const SizedBox(width: 4),
                                Text('~${t.estimatedMinutes} min',
                                    style: AppTypography.caption),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              const SizedBox(height: 24),
              // Recommended
              const SectionHeader(title: 'Recommended Programs'),
              const SizedBox(height: 12),
              if (recommended.isEmpty)
                AppCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No recommendations yet', style: AppTypography.caption),
                    ),
                  ),
                )
              else
                ...recommended.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        onTap: () {
                          ref.read(selectedTemplateProvider.notifier).state = r;
                          context.push('/template-detail');
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Icons.fitness_center,
                                    color: Colors.white, size: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.name,
                                    style: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.description ?? '${r.exercises.length} exercises',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.button.copyWith(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
