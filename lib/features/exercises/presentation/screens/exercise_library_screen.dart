import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../../../../services/ad_service.dart';
import '../providers/exercise_provider.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  Color _difficultyColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.text3;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(availableMuscleGroupsProvider);
    final selectedFilter = ref.watch(selectedMuscleFilterProvider);
    final exercises = ref.watch(filteredExercisesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimensions.padding2XL,
                  AppDimensions.paddingLG,
                  AppDimensions.padding2XL,
                  0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exercises', style: AppTypography.h1),
                  const SizedBox(height: 16),
                  // Search bar
                  TextField(
                    onChanged: (v) {
                      ref.read(exerciseSearchQueryProvider.notifier).state = v;
                    },
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.text3, size: 20),
                      filled: true,
                      fillColor: AppColors.bgTertiary,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding2XL),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = (filter == 'All' && selectedFilter == null) ||
                      filter == selectedFilter;
                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedMuscleFilterProvider.notifier).state =
                          filter == 'All' ? null : filter;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusPill),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: AppTypography.caption.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.text2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Exercise list
            Expanded(
              child: exercises.isEmpty
                  ? Center(
                      child: Text('No exercises found',
                          style: AppTypography.body.copyWith(color: AppColors.text3)),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        AppDimensions.padding2XL,
                        0,
                        AppDimensions.padding2XL,
                        AppDimensions.bottomNavHeight + 24,
                      ),
                      separatorBuilder: (_, idx) {
                        // Show native ad after every 6th exercise
                        if ((idx + 1) % 6 == 0) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: AdBannerWidget(
                                placement: AdPlacement.nativeExercise),
                          );
                        }
                        return const SizedBox(height: 8);
                      },
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        final muscles = exercise.primaryMuscles.join(', ');
                        final difficulty = _capitalize(exercise.difficulty);
                        return AppCard(
                          onTap: () => context.push('/exercise-detail', extra: exercise.id),
                          padding: const EdgeInsets.all(AppDimensions.paddingMD),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(Icons.fitness_center,
                                      color: AppColors.accent, size: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: AppTypography.body.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(muscles, style: AppTypography.caption),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _difficultyColor(exercise.difficulty)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  difficulty,
                                  style: AppTypography.caption.copyWith(
                                    color: _difficultyColor(exercise.difficulty),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
