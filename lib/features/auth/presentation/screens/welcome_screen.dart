import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.padding2XL),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'GG',
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.gradient.createShader(bounds),
                child: Text(
                  'GymGenius',
                  style: AppTypography.h1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
              ),
              const Spacer(),
              // Feature rows
              _FeatureRow(
                icon: Icons.fitness_center,
                title: 'Smart Workouts',
                subtitle: 'AI-powered routines tailored to your goals',
              ),
              const SizedBox(height: 24),
              _FeatureRow(
                icon: Icons.insights,
                title: 'Track Progress',
                subtitle: 'Visualize your gains with detailed analytics',
              ),
              const SizedBox(height: 24),
              _FeatureRow(
                icon: Icons.emoji_events,
                title: 'Stay Motivated',
                subtitle: 'Achievements, streaks, and social challenges',
              ),
              const Spacer(),
              // Buttons
              AppButton(
                label: 'Get Started',
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: 12),
              AppButton.secondary(
                label: 'Join Your Organization',
                icon: Icons.business_outlined,
                onPressed: () => context.push('/b2b-join'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/login'),
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.body.copyWith(color: AppColors.text2),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log In',
                        style: AppTypography.button
                            .copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => context.push('/b2b-onboarding'),
                child: Text(
                  'For Business',
                  style: AppTypography.button
                      .copyWith(color: AppColors.text3),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h3),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
