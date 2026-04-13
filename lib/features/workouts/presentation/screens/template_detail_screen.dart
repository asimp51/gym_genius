import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/workout_providers.dart';
import '../providers/active_workout_provider.dart';

class TemplateDetailScreen extends ConsumerWidget {
  const TemplateDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final template = ref.watch(selectedTemplateProvider);

    if (template == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Template'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('No template selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(template.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => context.push('/template-editor', extra: template),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.padding2XL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                          icon: Icons.fitness_center,
                          value: '${template.exercises.length}',
                          label: 'Exercises'),
                      _SummaryItem(
                          icon: Icons.timer_outlined,
                          value: '~${template.estimatedMinutes}',
                          label: 'Minutes'),
                      _SummaryItem(
                          icon: Icons.local_fire_department,
                          value: '${template.targetMuscles.length}',
                          label: 'Muscles'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Muscle tags
                  Center(
                    child: Wrap(
                      spacing: 6,
                      children: template.targetMuscles
                          .map((m) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusPill),
                                ),
                                child: Text(
                                  m,
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.accent),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Exercises', style: AppTypography.h2),
                  const SizedBox(height: 12),
                  // Exercise list
                  ...List.generate(template.exercises.length, (index) {
                    final ex = template.exercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingMD),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.bgTertiary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.exerciseName,
                                    style: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ex.targetSets} sets x ${ex.targetReps} reps',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.drag_handle,
                                color: AppColors.text3, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Bottom button
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppDimensions.padding2XL,
                AppDimensions.paddingSM,
                AppDimensions.padding2XL,
                AppDimensions.padding2XL),
            child: AppButton(
              label: 'Start Workout',
              icon: Icons.play_arrow_rounded,
              onPressed: () {
                ref.read(activeWorkoutProvider.notifier).startFromTemplate(template);
                context.push('/active-workout');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.stat),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
