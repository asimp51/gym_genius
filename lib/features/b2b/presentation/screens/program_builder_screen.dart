import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../providers/b2b_providers.dart';
import '../../data/b2b_repository.dart';

class ProgramBuilderScreen extends ConsumerStatefulWidget {
  const ProgramBuilderScreen({super.key});

  @override
  ConsumerState<ProgramBuilderScreen> createState() =>
      _ProgramBuilderScreenState();
}

class _ProgramBuilderScreenState extends ConsumerState<ProgramBuilderScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _difficulty = 'Beginner';
  int _durationWeeks = 4;
  final List<String> _targetGoals = [];
  late List<ProgramWeek> _weeks;
  int _currentWeek = 0;
  bool _isEditing = false;
  String? _editingProgramId;

  final _availableGoals = [
    'Build Strength',
    'Muscle Growth',
    'Fat Loss',
    'Endurance',
    'Flexibility',
    'Sports Performance',
    'General Fitness',
    'Toning',
    'Improve Form',
    'Rehabilitation',
  ];

  final _templateOptions = [
    'Upper Body Push',
    'Upper Body Pull',
    'Lower Body',
    'Full Body',
    'Full Body Circuit',
    'HIIT Cardio',
    'Core & Abs',
    'Active Recovery',
    'Yoga & Mobility',
    'Sprint Intervals',
    'Strength Circuit',
    'Steady State Cardio',
  ];

  @override
  void initState() {
    super.initState();
    _initWeeks();
  }

  void _initWeeks() {
    _weeks = List.generate(
      _durationWeeks,
      (w) => ProgramWeek(
        weekNumber: w + 1,
        focus: 'Week ${w + 1}',
        days: List.generate(
          7,
          (d) => ProgramDay(dayNumber: d + 1),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgAsync = ref.watch(currentOrganizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text(
            _isEditing ? 'Edit Program' : 'Program Builder',
            style: AppTypography.h2),
        actions: [
          TextButton(
            onPressed: _saveProgram,
            child: Text('Save',
                style: AppTypography.button.copyWith(color: AppColors.accent)),
          ),
          TextButton(
            onPressed: _publishProgram,
            child: Text('Publish',
                style:
                    AppTypography.button.copyWith(color: AppColors.success)),
          ),
        ],
      ),
      body: orgAsync.when(
        data: (org) {
          if (org == null) return const Center(child: Text('No org'));
          return _buildBody(org);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(Organization org) {
    final programsAsync = ref.watch(orgProgramsProvider(org.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.padding2XL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing programs list
          if (!_isEditing) ...[
            programsAsync.when(
              data: (programs) {
                if (programs.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Existing Programs', style: AppTypography.h3),
                    const SizedBox(height: 12),
                    ...programs.map((p) => _ProgramCard(
                          program: p,
                          onEdit: () => _editProgram(p),
                          onPreview: () => _showPreview(p),
                        )),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),
                    Text('Create New Program', style: AppTypography.h3),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],

          // Program name
          TextField(
            controller: _nameController,
            style: AppTypography.h3,
            decoration: InputDecoration(
              hintText: 'Program Name',
              hintStyle: AppTypography.h3.copyWith(color: AppColors.text3),
              filled: true,
              fillColor: AppColors.bgSecondary,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descController,
            style: AppTypography.body,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Description',
              hintStyle:
                  AppTypography.body.copyWith(color: AppColors.text3),
              filled: true,
              fillColor: AppColors.bgSecondary,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Difficulty
          Text('Difficulty', style: AppTypography.caption),
          const SizedBox(height: 8),
          Row(
            children: ['Beginner', 'Intermediate', 'Advanced'].map((d) {
              final selected = _difficulty == d;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: d != 'Advanced' ? 8 : 0),
                  child: InkWell(
                    onTap: () => setState(() => _difficulty = d),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent.withOpacity(0.15)
                            : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(d,
                            style: AppTypography.caption.copyWith(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.text2,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            )),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Duration
          Row(
            children: [
              Text('Duration:', style: AppTypography.body),
              const Spacer(),
              IconButton(
                onPressed: _durationWeeks > 1
                    ? () {
                        setState(() {
                          _durationWeeks--;
                          if (_currentWeek >= _durationWeeks) {
                            _currentWeek = _durationWeeks - 1;
                          }
                          _initWeeks();
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                color: AppColors.accent,
              ),
              Text('$_durationWeeks weeks',
                  style: AppTypography.stat.copyWith(fontSize: 16)),
              IconButton(
                onPressed: _durationWeeks < 16
                    ? () {
                        setState(() {
                          _durationWeeks++;
                          _initWeeks();
                        });
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline, size: 22),
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target Goals
          Text('Target Goals', style: AppTypography.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableGoals.map((goal) {
              final selected = _targetGoals.contains(goal);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _targetGoals.remove(goal);
                    } else {
                      _targetGoals.add(goal);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent.withOpacity(0.15)
                        : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          selected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Text(goal,
                      style: AppTypography.caption.copyWith(
                        color: selected
                            ? AppColors.accent
                            : AppColors.text2,
                        fontSize: 12,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Week tabs
          Text('Schedule', style: AppTypography.h3),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _durationWeeks,
              itemBuilder: (context, index) {
                final selected = _currentWeek == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _currentWeek = index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent
                            : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                      child: Text('Week ${index + 1}',
                          style: AppTypography.caption.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.text2,
                          )),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Week focus input
          if (_currentWeek < _weeks.length) ...[
            TextField(
              key: ValueKey('focus_$_currentWeek'),
              onChanged: (val) {
                setState(() {
                  _weeks[_currentWeek] =
                      _weeks[_currentWeek].copyWith(focus: val);
                });
              },
              controller: TextEditingController(
                  text: _weeks[_currentWeek].focus)
                ..selection = TextSelection.collapsed(
                    offset: _weeks[_currentWeek].focus.length),
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'Week focus (e.g., "Strength Building")',
                hintStyle:
                    AppTypography.body.copyWith(color: AppColors.text3),
                filled: true,
                fillColor: AppColors.bgSecondary,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Day cards
            ...List.generate(7, (dayIndex) {
              final day = _weeks[_currentWeek].days[dayIndex];
              final dayNames = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: day.isRestDay
                        ? AppColors.bgTertiary.withOpacity(0.5)
                        : AppColors.bgSecondary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                    border: Border.all(
                      color: day.isRestDay
                          ? AppColors.border
                          : day.templateName != null
                              ? AppColors.accent.withOpacity(0.3)
                              : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(dayNames[dayIndex],
                              style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13)),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                final days = List<ProgramDay>.from(
                                    _weeks[_currentWeek].days);
                                days[dayIndex] = days[dayIndex].copyWith(
                                  isRestDay: !day.isRestDay,
                                  templateName:
                                      !day.isRestDay ? null : day.templateName,
                                  templateId:
                                      !day.isRestDay ? null : day.templateId,
                                );
                                _weeks[_currentWeek] = _weeks[_currentWeek]
                                    .copyWith(days: days);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: day.isRestDay
                                    ? AppColors.accent.withOpacity(0.1)
                                    : AppColors.bgTertiary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                day.isRestDay ? 'Rest Day' : 'Training',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10,
                                  color: day.isRestDay
                                      ? AppColors.accent
                                      : AppColors.text3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!day.isRestDay) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () =>
                              _showTemplateSelector(dayIndex),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  day.templateName != null
                                      ? Icons.fitness_center
                                      : Icons.add,
                                  size: 16,
                                  color: day.templateName != null
                                      ? AppColors.accent
                                      : AppColors.text3,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  day.templateName ?? 'Select workout',
                                  style: AppTypography.body.copyWith(
                                    fontSize: 13,
                                    color: day.templateName != null
                                        ? AppColors.text1
                                        : AppColors.text3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (day.notes != null && day.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(day.notes!,
                              style: AppTypography.caption
                                  .copyWith(fontSize: 11)),
                        ],
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () =>
                              _showNotesDialog(dayIndex),
                          child: Row(
                            children: [
                              Icon(Icons.note_add_outlined,
                                  size: 14, color: AppColors.text3),
                              const SizedBox(width: 4),
                              Text(
                                day.notes != null && day.notes!.isNotEmpty
                                    ? 'Edit notes'
                                    : 'Add notes',
                                style: AppTypography.caption
                                    .copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 24),

          // Preview button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showFullPreview(),
              icon: const Icon(Icons.preview, size: 18),
              label: const Text('Preview Program'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showTemplateSelector(int dayIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.text3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Select Workout', style: AppTypography.h3),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: _templateOptions.map((template) {
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fitness_center,
                        size: 18, color: AppColors.accent),
                  ),
                  title: Text(template, style: AppTypography.body),
                  onTap: () {
                    setState(() {
                      final days = List<ProgramDay>.from(
                          _weeks[_currentWeek].days);
                      days[dayIndex] = days[dayIndex].copyWith(
                        templateName: template,
                        isRestDay: false,
                      );
                      _weeks[_currentWeek] =
                          _weeks[_currentWeek].copyWith(days: days);
                    });
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showNotesDialog(int dayIndex) {
    final controller = TextEditingController(
        text: _weeks[_currentWeek].days[dayIndex].notes ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: Text('Day Notes', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          style: AppTypography.body,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Notes for this day...',
            hintStyle:
                AppTypography.body.copyWith(color: AppColors.text3),
            filled: true,
            fillColor: AppColors.bgTertiary,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusButton),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    AppTypography.button.copyWith(color: AppColors.text2)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final days =
                    List<ProgramDay>.from(_weeks[_currentWeek].days);
                days[dayIndex] =
                    days[dayIndex].copyWith(notes: controller.text);
                _weeks[_currentWeek] =
                    _weeks[_currentWeek].copyWith(days: days);
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              ),
            ),
            child: Text('Save', style: AppTypography.button),
          ),
        ],
      ),
    );
  }

  void _saveProgram() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a program name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final repo = ref.read(b2bRepositoryProvider);
    final orgId = repo.currentOrgId;
    if (orgId == null) return;

    final program = OrganizationProgram(
      id: _editingProgramId ??
          'prog_${DateTime.now().millisecondsSinceEpoch}',
      orgId: orgId,
      createdBy: repo.currentUserId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      difficulty: _difficulty,
      durationWeeks: _durationWeeks,
      targetGoals: _targetGoals,
      weeks: _weeks,
      isPublished: false,
      enrolledCount: 0,
      createdAt: DateTime.now(),
    );

    if (_editingProgramId != null) {
      repo.updateProgram(program);
    } else {
      repo.createProgram(program);
    }
    ref.invalidate(orgProgramsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Program saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );

    if (_isEditing) {
      setState(() {
        _isEditing = false;
        _editingProgramId = null;
        _nameController.clear();
        _descController.clear();
        _targetGoals.clear();
        _durationWeeks = 4;
        _currentWeek = 0;
        _initWeeks();
      });
    }
  }

  void _publishProgram() {
    _saveProgram();
    final repo = ref.read(b2bRepositoryProvider);
    final orgId = repo.currentOrgId;
    if (orgId == null) return;

    final id = _editingProgramId ??
        'prog_${DateTime.now().millisecondsSinceEpoch}';
    repo.publishProgram(orgId, id);
    ref.invalidate(orgProgramsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Program published and available to members'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _editProgram(OrganizationProgram program) {
    setState(() {
      _isEditing = true;
      _editingProgramId = program.id;
      _nameController.text = program.name;
      _descController.text = program.description;
      _difficulty = program.difficulty;
      _durationWeeks = program.durationWeeks;
      _targetGoals.clear();
      _targetGoals.addAll(program.targetGoals);
      _weeks = List.from(program.weeks);
      _currentWeek = 0;
    });
  }

  void _showPreview(OrganizationProgram program) {
    _showProgramPreviewSheet(program);
  }

  void _showFullPreview() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a program name to preview'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final program = OrganizationProgram(
      id: 'preview',
      orgId: '',
      createdBy: '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      difficulty: _difficulty,
      durationWeeks: _durationWeeks,
      targetGoals: _targetGoals,
      weeks: _weeks,
      isPublished: false,
      enrolledCount: 0,
      createdAt: DateTime.now(),
    );
    _showProgramPreviewSheet(program);
  }

  void _showProgramPreviewSheet(OrganizationProgram program) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppDimensions.padding2XL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 20),
              Text(program.name, style: AppTypography.h1),
              const SizedBox(height: 8),
              Text(program.description,
                  style: AppTypography.body
                      .copyWith(color: AppColors.text2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PreviewChip(program.difficulty, AppColors.warning),
                  const SizedBox(width: 8),
                  _PreviewChip(
                      '${program.durationWeeks} weeks', AppColors.accent),
                  if (program.isPublished) ...[
                    const SizedBox(width: 8),
                    _PreviewChip('Published', AppColors.success),
                  ],
                  if (program.enrolledCount > 0) ...[
                    const SizedBox(width: 8),
                    _PreviewChip(
                        '${program.enrolledCount} enrolled', AppColors.accentSecondary),
                  ],
                ],
              ),
              if (program.targetGoals.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: program.targetGoals
                      .map((g) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(g,
                                style: AppTypography.caption
                                    .copyWith(fontSize: 11)),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              ...program.weeks.map((week) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withOpacity(0.2),
                              AppColors.accentSecondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Week ${week.weekNumber}: ${week.focus}',
                          style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...week.days.map((day) {
                        final dayNames = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        return Padding(
                          padding:
                              const EdgeInsets.only(left: 12, bottom: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 36,
                                child: Text(dayNames[day.dayNumber - 1],
                                    style: AppTypography.caption
                                        .copyWith(fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  day.isRestDay
                                      ? 'Rest Day'
                                      : day.templateName ?? 'Unassigned',
                                  style: AppTypography.body.copyWith(
                                    fontSize: 13,
                                    color: day.isRestDay
                                        ? AppColors.text3
                                        : AppColors.text1,
                                    fontStyle: day.isRestDay
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final OrganizationProgram program;
  final VoidCallback onEdit;
  final VoidCallback onPreview;

  const _ProgramCard({
    required this.program,
    required this.onEdit,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
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
                Expanded(
                  child: Text(program.name,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                if (program.isPublished)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Published',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.success, fontSize: 10)),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Draft',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.warning, fontSize: 10)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(program.description,
                style: AppTypography.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                    '${program.difficulty} | ${program.durationWeeks} weeks | ${program.enrolledCount} enrolled',
                    style:
                        AppTypography.caption.copyWith(fontSize: 11)),
                const Spacer(),
                InkWell(
                  onTap: onPreview,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.preview,
                        size: 18, color: AppColors.accent),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit,
                        size: 18, color: AppColors.text2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PreviewChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: AppTypography.caption
              .copyWith(color: color, fontSize: 11)),
    );
  }
}
