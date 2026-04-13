import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/template_repository.dart';
import '../../domain/workout_template_model.dart';
import '../../../exercises/presentation/providers/exercise_provider.dart';

class TemplateEditorScreen extends ConsumerStatefulWidget {
  final WorkoutTemplateModel? template;

  const TemplateEditorScreen({super.key, this.template});

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _minutesCtrl;
  late List<TemplateExercise> _exercises;
  late Set<String> _targetMuscles;
  bool _isSaving = false;

  bool get _isEditing => widget.template != null;

  static const _muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Core',
    'Full Body',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _minutesCtrl =
        TextEditingController(text: t != null ? '${t.estimatedMinutes}' : '45');
    _exercises = t != null ? List.from(t.exercises) : [];
    _targetMuscles = t != null ? Set.from(t.targetMuscles) : {};
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template name is required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = ref.read(templateRepositoryProvider);
    final template = WorkoutTemplateModel(
      id: widget.template?.id ?? '',
      userId: widget.template?.userId,
      name: name,
      description: _descCtrl.text.trim(),
      targetMuscles: _targetMuscles.toList(),
      estimatedMinutes: int.tryParse(_minutesCtrl.text) ?? 45,
      exercises: _exercises,
      createdAt: widget.template?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      repo.updateTemplate(template);
    } else {
      repo.createTemplate(template);
    }

    Navigator.pop(context);
  }

  void _showExercisePicker() {
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Consumer(
          builder: (context, ref, _) {
            final allExercises = ref.watch(allExercisesProvider);

            return StatefulBuilder(
              builder: (context, setSheetState) {
                final query = searchCtrl.text.toLowerCase();
                final filtered = query.isEmpty
                    ? allExercises
                    : allExercises
                        .where((e) =>
                            e.name.toLowerCase().contains(query) ||
                            e.primaryMuscles.any((m) => m.toLowerCase().contains(query)))
                        .toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.padding2XL),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.text3,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Add Exercise', style: AppTypography.h3),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: searchCtrl,
                            hint: 'Search exercises...',
                            prefixIcon: Icons.search,
                            onChanged: (_) => setSheetState(() {}),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final exercise = filtered[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.accent.withValues(alpha: 0.15),
                              child: const Icon(Icons.fitness_center,
                                  color: AppColors.accent, size: 18),
                            ),
                            title: Text(exercise.name,
                                style: AppTypography.body),
                            subtitle: Text(exercise.primaryMuscles.join(', '),
                                style: AppTypography.caption),
                            onTap: () {
                              setState(() {
                                _exercises.add(TemplateExercise(
                                  exerciseId: exercise.id,
                                  exerciseName: exercise.name,
                                  order: _exercises.length,
                                  targetSets: 3,
                                  targetReps: '8-12',
                                ));
                              });
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Template' : 'Create Template'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              'Save',
              style: AppTypography.button.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _nameCtrl,
              label: 'Template Name',
              hint: 'e.g. Push Day',
              prefixIcon: Icons.edit_outlined,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _descCtrl,
              label: 'Description',
              hint: 'What is this workout about?',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _minutesCtrl,
              label: 'Estimated Duration (min)',
              hint: '45',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.timer_outlined,
            ),
            const SizedBox(height: 20),

            // Target muscles
            Text('Target Muscles', style: AppTypography.caption),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleGroups.map((muscle) {
                final selected = _targetMuscles.contains(muscle);
                return FilterChip(
                  label: Text(muscle,
                      style: AppTypography.caption.copyWith(
                        color: selected ? Colors.white : AppColors.text2,
                      )),
                  selected: selected,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.bgTertiary,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: selected ? AppColors.accent : AppColors.border,
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _targetMuscles.add(muscle);
                      } else {
                        _targetMuscles.remove(muscle);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Exercises
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exercises', style: AppTypography.h3),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.accent),
                  onPressed: _showExercisePicker,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_exercises.isEmpty)
              AppCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.fitness_center,
                            color: AppColors.text3, size: 40),
                        const SizedBox(height: 8),
                        Text('No exercises yet',
                            style: AppTypography.caption),
                        const SizedBox(height: 8),
                        AppButton.ghost(
                          label: 'Add Exercise',
                          icon: Icons.add,
                          onPressed: _showExercisePicker,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (newIdx > oldIdx) newIdx -= 1;
                    final item = _exercises.removeAt(oldIdx);
                    _exercises.insert(newIdx, item);
                    // Update order indices
                    for (int i = 0; i < _exercises.length; i++) {
                      _exercises[i] = _exercises[i].copyWith(order: i);
                    }
                  });
                },
                itemBuilder: (_, i) {
                  final ex = _exercises[i];
                  return _ExerciseTile(
                    key: ValueKey('${ex.exerciseId}_$i'),
                    exercise: ex,
                    onUpdate: (updated) {
                      setState(() => _exercises[i] = updated);
                    },
                    onRemove: () {
                      setState(() => _exercises.removeAt(i));
                    },
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final TemplateExercise exercise;
  final ValueChanged<TemplateExercise> onUpdate;
  final VoidCallback onRemove;

  const _ExerciseTile({
    super.key,
    required this.exercise,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.drag_handle,
                    color: AppColors.text3, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(exercise.exerciseName,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.text3, size: 18),
                  onPressed: onRemove,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniField(
                  label: 'Sets',
                  value: '${exercise.targetSets}',
                  onChanged: (v) {
                    final sets = int.tryParse(v) ?? exercise.targetSets;
                    onUpdate(exercise.copyWith(targetSets: sets));
                  },
                ),
                const SizedBox(width: 12),
                _MiniField(
                  label: 'Reps',
                  value: exercise.targetReps,
                  onChanged: (v) {
                    onUpdate(exercise.copyWith(targetReps: v));
                  },
                ),
                const SizedBox(width: 12),
                _MiniField(
                  label: 'Rest (s)',
                  value: '${exercise.restSeconds}',
                  onChanged: (v) {
                    final rest = int.tryParse(v) ?? exercise.restSeconds;
                    onUpdate(exercise.copyWith(restSeconds: rest));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _MiniField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.caption.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          SizedBox(
            height: 36,
            child: TextField(
              controller: TextEditingController(text: value),
              style: AppTypography.body.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                filled: true,
                fillColor: AppColors.bgTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.accent),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
