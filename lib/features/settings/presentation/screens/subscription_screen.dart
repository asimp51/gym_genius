import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../services/ai_usage_service.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isAnnual = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final currentTier = user?.subscription.tier ?? 'free';
    final tierLabel = currentTier == 'premium' ? 'Premium' : 'Free Plan';
    final aiUsage = ref.watch(aiUsageServiceProvider);
    final aiRemaining = aiUsage.remaining(currentTier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          children: [
            // Title
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.gradient.createShader(bounds),
              child: Text(
                'GymGenius Premium',
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                'Current: $tierLabel',
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: 8),
            // AI usage indicator
            Text(
              '🤖 AI Credits: ${aiUsage.usageCount}/${aiUsage.getLimitDisplay(currentTier)} used this month ($aiRemaining remaining)',
              style: AppTypography.caption.copyWith(
                color: currentTier == 'premium' ? AppColors.accent : AppColors.text3,
              ),
            ),
            const SizedBox(height: 28),

            // Feature comparison header
            Row(
              children: [
                const Expanded(flex: 3, child: SizedBox.shrink()),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text('Free',
                        style: AppTypography.caption
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.gradient.createShader(bounds),
                      child: Text('Premium',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Feature comparison
            AppCard(
              child: Column(
                children: [
                  _FeatureRow(
                      feature: 'Workout Tracking',
                      free: 'Basic',
                      premium: '\u2714'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Exercise Library',
                      free: '1,121',
                      premium: '1,121'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'AI Calls/Month',
                      free: '3',
                      premium: '100'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'AI Quality',
                      free: 'Standard',
                      premium: 'Pro (Best)'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Progress Charts',
                      free: 'Basic',
                      premium: 'Advanced'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Smart Meal Planner',
                      free: '\u2716',
                      premium: '201 recipes'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'AI Post-Workout Analysis',
                      free: '\u2716',
                      premium: '\u2714'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Progress Photos',
                      free: '\u2716',
                      premium: '\u2714'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Social Feed',
                      free: 'Read Only',
                      premium: 'Post, Like, Comment'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Grocery List Generator',
                      free: '\u2716',
                      premium: '\u2714'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Community Access',
                      free: 'Read Only',
                      premium: 'Full'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Ads',
                      free: 'Shown',
                      premium: 'No Ads'),
                  const Divider(color: AppColors.border),
                  _FeatureRow(
                      feature: 'Priority Support',
                      free: '\u2716',
                      premium: '\u2714'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monthly / Annual toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAnnual = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient:
                              !_isAnnual ? AppColors.gradient : null,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton - 4),
                        ),
                        child: Center(
                          child: Text(
                            'Monthly',
                            style: AppTypography.caption.copyWith(
                              color: !_isAnnual
                                  ? Colors.white
                                  : AppColors.text2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAnnual = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient:
                              _isAnnual ? AppColors.gradient : null,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton - 4),
                        ),
                        child: Center(
                          child: Text(
                            'Annual',
                            style: AppTypography.caption.copyWith(
                              color: _isAnnual
                                  ? Colors.white
                                  : AppColors.text2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pricing cards
            Row(
              children: [
                Expanded(
                  child: _PricingCard(
                    title: 'Monthly',
                    price: '\$9.99',
                    period: '/month',
                    isSelected: !_isAnnual,
                    badge: null,
                    onTap: () => setState(() => _isAnnual = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PricingCard(
                    title: 'Annual',
                    price: '\$79.99',
                    period: '/year',
                    isSelected: _isAnnual,
                    badge: 'BEST VALUE',
                    subtitle: '\$6.67/mo - Save 33%',
                    onTap: () => setState(() => _isAnnual = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // CTA button with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: currentTier == 'premium'
                    ? null
                    : AppColors.gradient,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              ),
              child: currentTier == 'premium'
                  ? AppButton(
                      label: 'Current Plan',
                      onPressed: null,
                    )
                  : ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Payment integration coming soon')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton),
                        ),
                      ),
                      child: Text(
                        'Start 7-Day Free Trial',
                        style: AppTypography.button
                            .copyWith(color: Colors.white),
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Checking for purchases...')),
                );
              },
              child: Text(
                'Restore Purchase',
                style: AppTypography.caption
                    .copyWith(color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Frequently Asked Questions',
                  style: AppTypography.h3),
            ),
            const SizedBox(height: 12),
            _FaqItem(
              question: 'Can I cancel anytime?',
              answer:
                  'Yes, you can cancel your subscription at any time. Your premium features will remain active until the end of your current billing period.',
            ),
            const SizedBox(height: 8),
            _FaqItem(
              question: 'What happens when trial ends?',
              answer:
                  'After your 7-day free trial ends, you will be automatically charged the subscription price for your selected plan (monthly or annual). You can cancel before the trial ends to avoid charges.',
            ),
            const SizedBox(height: 8),
            _FaqItem(
              question: 'Will I lose my data if I downgrade?',
              answer:
                  'No, your workout history, progress photos, and all tracked data are always saved. You will simply lose access to premium features until you re-subscribe.',
            ),
            const SizedBox(height: 16),
            Text(
              'Cancel anytime. No commitment required.',
              style: AppTypography.caption.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String feature;
  final String free;
  final String premium;

  const _FeatureRow({
    required this.feature,
    required this.free,
    required this.premium,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(feature, style: AppTypography.body),
          ),
          Expanded(
            flex: 2,
            child: Text(
              free,
              style: AppTypography.caption.copyWith(
                color: free == '\u2716'
                    ? AppColors.error
                    : AppColors.text3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              premium,
              style: AppTypography.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool isSelected;
  final String? badge;
  final String? subtitle;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isSelected,
    this.badge,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color:
                    isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(title, style: AppTypography.caption),
                const SizedBox(height: 8),
                Text(price, style: AppTypography.statLarge),
                Text(period, style: AppTypography.caption),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  const Icon(Icons.check_circle,
                      color: AppColors.accent, size: 20),
                ],
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Text(
                    badge!,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.question,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.text3,
                  size: 20,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(widget.answer,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.text2)),
            ],
          ],
        ),
      ),
    );
  }
}
