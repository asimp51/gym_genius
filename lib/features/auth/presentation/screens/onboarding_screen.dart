import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/user_model.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 1: Goals (multi-select)
  final Set<String> _selectedGoals = {};
  final _goals = [
    ('Build Muscle', '\ud83d\udcaa'),
    ('Lose Weight', '\ud83d\udd25'),
    ('Increase Strength', '\ud83c\udfcb\ufe0f'),
    ('Improve Endurance', '\ud83c\udfc3'),
    ('Stay Active', '\u2764\ufe0f'),
    ('Athletic Performance', '\u26a1'),
  ];

  // Page 2: Experience (single-select)
  int _selectedExperience = -1;
  final _experiences = [
    ('Beginner', 'New to working out or less than 6 months', '\ud83c\udf31'),
    ('Intermediate', '6 months to 2 years of experience', '\ud83d\udcaa'),
    ('Advanced', '2+ years of consistent training', '\ud83d\udd25'),
  ];

  // Page 3: Equipment (multi-select)
  final Set<String> _selectedEquipment = {};
  final _equipment = [
    'Barbell',
    'Dumbbell',
    'Kettlebell',
    'Cable Machine',
    'Bodyweight',
    'Pull-Up Bar',
    'Resistance Bands',
    'Bench',
    'Smith Machine',
    'Medicine Ball',
  ];

  // Page 4: Schedule
  int _daysPerWeek = 4;
  final Set<String> _selectedDays = {'Mon', 'Tue', 'Thu', 'Fri'};
  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    final experienceLevel = _selectedExperience >= 0
        ? _experiences[_selectedExperience].$1.toLowerCase()
        : 'beginner';

    final onboarding = UserOnboarding(
      experienceLevel: experienceLevel,
      goals: _selectedGoals.toList(),
      equipment: _selectedEquipment.toList(),
      daysPerWeek: _daysPerWeek,
      preferredDays: _selectedDays.toList(),
      completedAt: DateTime.now(),
    );

    ref.read(authProvider.notifier).completeOnboarding(onboarding);
    context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppDimensions.padding2XL),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          child: const Icon(Icons.arrow_back_ios, size: 20),
                        )
                      else
                        const SizedBox(width: 20),
                      Text(
                        'Step ${_currentPage + 1} of 4',
                        style: AppTypography.caption,
                      ),
                      TextButton(
                        onPressed: () {
                          _finishOnboarding();
                        },
                        child: Text(
                          'Skip',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.text3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 4,
                      backgroundColor: AppColors.bgTertiary,
                      color: AppColors.accent,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) =>
                    setState(() => _currentPage = page),
                children: [
                  _buildGoalsPage(),
                  _buildExperiencePage(),
                  _buildEquipmentPage(),
                  _buildSchedulePage(),
                ],
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.padding2XL),
              child: AppButton(
                label: _currentPage == 3 ? 'Finish Setup' : 'Continue',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsPage() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.padding2XL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What are your\nfitness goals?", style: AppTypography.display),
          const SizedBox(height: 8),
          Text(
            'Select all that apply',
            style: AppTypography.body.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selectedGoals.contains(goal.$1);
                return AppCard(
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGoals.remove(goal.$1);
                      } else {
                        _selectedGoals.add(goal.$1);
                      }
                    });
                  },
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(goal.$2, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Text(
                        goal.$1,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.text1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencePage() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.padding2XL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's your\nexperience level?",
              style: AppTypography.display),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your workouts',
            style: AppTypography.body.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: 24),
          ...List.generate(_experiences.length, (index) {
            final exp = _experiences[index];
            final isSelected = _selectedExperience == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                isSelected: isSelected,
                onTap: () =>
                    setState(() => _selectedExperience = index),
                child: Row(
                  children: [
                    Text(exp.$3, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.$1,
                            style: AppTypography.h3.copyWith(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.text1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(exp.$2, style: AppTypography.caption),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: AppColors.accent, size: 24),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEquipmentPage() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.padding2XL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What equipment\ndo you have?", style: AppTypography.display),
          const SizedBox(height: 8),
          Text(
            'Select all available equipment',
            style: AppTypography.body.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _equipment.map((item) {
              final isSelected = _selectedEquipment.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedEquipment.add(item);
                    } else {
                      _selectedEquipment.remove(item);
                    }
                  });
                },
                backgroundColor: AppColors.bgTertiary,
                selectedColor: AppColors.accent.withValues(alpha: 0.2),
                checkmarkColor: AppColors.accent,
                labelStyle: AppTypography.body.copyWith(
                  color: isSelected ? AppColors.accent : AppColors.text1,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.accent : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusPill),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePage() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.padding2XL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("How often do\nyou want to train?",
              style: AppTypography.display),
          const SizedBox(height: 8),
          Text(
            'Set your weekly workout schedule',
            style: AppTypography.body.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: 32),
          // Days per week selector
          Text('Days per week', style: AppTypography.h3),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              final count = index + 2;
              final isSelected = _daysPerWeek == count;
              return GestureDetector(
                onTap: () => setState(() => _daysPerWeek = count),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.accent : AppColors.bgTertiary,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: AppTypography.button.copyWith(
                        color: isSelected ? Colors.white : AppColors.text1,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          // Day picker
          Text('Preferred days', style: AppTypography.h3),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _days.map((day) {
              final isSelected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.2)
                        : AppColors.bgTertiary,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Text(
                    day,
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? AppColors.accent : AppColors.text2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
