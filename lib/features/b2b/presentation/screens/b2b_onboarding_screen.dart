import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../../data/b2b_repository.dart';
import '../providers/b2b_providers.dart';

class B2bOnboardingScreen extends ConsumerStatefulWidget {
  const B2bOnboardingScreen({super.key});

  @override
  ConsumerState<B2bOnboardingScreen> createState() =>
      _B2bOnboardingScreenState();
}

class _B2bOnboardingScreenState
    extends ConsumerState<B2bOnboardingScreen> {
  int _step = 0; // 0 = plans, 1 = form
  String _selectedTier = 'professional';
  String _orgType = 'gym';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isCreating = false;

  final _orgTypes = [
    {
      'value': 'gym',
      'label': 'Gym / Studio',
      'icon': Icons.fitness_center
    },
    {
      'value': 'corporate',
      'label': 'Corporate Wellness',
      'icon': Icons.business
    },
    {
      'value': 'trainer',
      'label': 'Personal Trainer',
      'icon': Icons.sports
    },
    {
      'value': 'insurance',
      'label': 'Health Insurance',
      'icon': Icons.health_and_safety
    },
    {
      'value': 'clinic',
      'label': 'Health Clinic',
      'icon': Icons.local_hospital
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: _step == 0 ? _buildPlansStep() : _buildFormStep(),
      ),
    );
  }

  Widget _buildPlansStep() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.bgPrimary,
          floating: true,
          title: const SizedBox.shrink(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text1),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.padding2XL),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.2),
                      AppColors.accentSecondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.business_center,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text('GymGenius for Business',
                        style: AppTypography.h1),
                    const SizedBox(height: 8),
                    Text(
                      'White-label the app for your gym, corporate wellness program, or training business.',
                      style: AppTypography.body
                          .copyWith(color: AppColors.text2),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Plans
              _PlanCard(
                tier: 'starter',
                name: 'Starter',
                basePrice: '\$49',
                perMember: '+ \$1.00/active member/mo',
                bestFor: 'Best for: Personal trainers, small studios',
                features: const [
                  'Up to 50 members',
                  'Basic analytics dashboard',
                  '1 trainer account',
                  '20 AI calls/member/month',
                  'Email support',
                ],
                isSelected: _selectedTier == 'starter',
                onSelect: () =>
                    setState(() => _selectedTier = 'starter'),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                tier: 'professional',
                name: 'Professional',
                basePrice: '\$149',
                perMember: '+ \$0.75/active member/mo',
                bestFor: 'Best for: Gyms, fitness studios',
                features: const [
                  'Up to 500 members',
                  'Full analytics & reporting',
                  '10 trainer accounts',
                  'Custom branding (logo, colors, tagline)',
                  'Program builder',
                  '50 AI calls/member/month',
                  'Member messaging',
                  'Priority support',
                ],
                isSelected: _selectedTier == 'professional',
                isPopular: true,
                onSelect: () =>
                    setState(() => _selectedTier = 'professional'),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                tier: 'enterprise',
                name: 'Enterprise',
                basePrice: '\$499',
                perMember: '+ \$0.50/active member/mo',
                bestFor:
                    'Best for: Gym chains, corporate wellness, insurance',
                features: const [
                  'Unlimited members',
                  'Everything in Professional',
                  'Full white-label (remove "Powered by GymGenius")',
                  'API access',
                  '200 AI calls/member/month',
                  'Dedicated account manager',
                  'Custom integrations',
                  'SLA guarantee',
                ],
                isSelected: _selectedTier == 'enterprise',
                onSelect: () =>
                    setState(() => _selectedTier = 'enterprise'),
              ),
              const SizedBox(height: 24),

              // Pricing examples
              Text('Pricing Examples', style: AppTypography.h3),
              const SizedBox(height: 12),
              _PricingExample(
                label: 'Starter with 30 members',
                calculation: '\$49 + \$30 = \$79/mo',
              ),
              const SizedBox(height: 6),
              _PricingExample(
                label: 'Pro with 200 members',
                calculation: '\$149 + \$150 = \$299/mo',
              ),
              const SizedBox(height: 6),
              _PricingExample(
                label: 'Enterprise with 1000 members',
                calculation: '\$499 + \$500 = \$999/mo',
              ),
              const SizedBox(height: 24),

              // Comparison table
              Text('Feature Comparison', style: AppTypography.h3),
              const SizedBox(height: 12),
              _ComparisonTable(),
              const SizedBox(height: 24),

              // CTA
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusButton),
                  ),
                  child: ElevatedButton(
                    onPressed: () => setState(() => _step = 1),
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
                    child: Text('Start 30-Day Free Trial',
                        style: AppTypography.button
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildFormStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.padding2XL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.text1),
                onPressed: () => setState(() => _step = 0),
              ),
              const SizedBox(width: 8),
              Text('Create Organization', style: AppTypography.h2),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              '${_selectedTier[0].toUpperCase()}${_selectedTier.substring(1)} plan - 30 day free trial',
              style: AppTypography.caption
                  .copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 32),

          // Organization Type
          Text('Organization Type', style: AppTypography.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _orgTypes.map((type) {
              final selected = _orgType == type['value'];
              return InkWell(
                onTap: () => setState(
                    () => _orgType = type['value'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.accent
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type['icon'] as IconData,
                          size: 18,
                          color: selected
                              ? AppColors.accent
                              : AppColors.text3),
                      const SizedBox(width: 8),
                      Text(type['label'] as String,
                          style: AppTypography.body.copyWith(
                            fontSize: 13,
                            color: selected
                                ? AppColors.accent
                                : AppColors.text2,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Organization Name
          Text('Organization Name', style: AppTypography.h3),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: 'e.g., FitZone Gym',
              hintStyle:
                  AppTypography.body.copyWith(color: AppColors.text3),
              filled: true,
              fillColor: AppColors.bgSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    AppDimensions.radiusButton),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.business,
                  color: AppColors.text3, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // Admin Email
          Text('Admin Email', style: AppTypography.h3),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            style: AppTypography.body,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'admin@yourorg.com',
              hintStyle:
                  AppTypography.body.copyWith(color: AppColors.text3),
              filled: true,
              fillColor: AppColors.bgSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    AppDimensions.radiusButton),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.email_outlined,
                  color: AppColors.text3, size: 20),
            ),
          ),
          const SizedBox(height: 32),

          // Create button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createOrganization,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppDimensions.radiusButton),
                ),
                disabledBackgroundColor:
                    AppColors.accent.withValues(alpha: 0.5),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Create Organization',
                      style: AppTypography.button
                          .copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No credit card required for the free trial',
              style: AppTypography.caption.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _createOrganization() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an organization name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    final plan = _selectedTier == 'starter'
        ? OrganizationPlan.starter
        : _selectedTier == 'professional'
            ? OrganizationPlan.professional
            : OrganizationPlan.enterprise;

    final repo = ref.read(b2bRepositoryProvider);
    await repo.createOrganization(
      name: name,
      type: _orgType,
      plan: plan,
      adminUserId: 'current_user',
    );

    ref.invalidate(currentOrganizationProvider);
    ref.invalidate(isB2BUserProvider);
    ref.invalidate(currentB2BRoleProvider);

    if (mounted) {
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/b2b-admin');
    }
  }
}

class _PlanCard extends StatelessWidget {
  final String tier;
  final String name;
  final String basePrice;
  final String perMember;
  final String bestFor;
  final List<String> features;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.tier,
    required this.name,
    required this.basePrice,
    required this.perMember,
    required this.bestFor,
    required this.features,
    required this.isSelected,
    this.isPopular = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius:
          BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.bgSecondary,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: AppTypography.h3),
                if (isPopular) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('MOST POPULAR',
                        style: AppTypography.caption.copyWith(
                            color: Colors.white, fontSize: 10)),
                  ),
                ],
                const Spacer(),
                Text(basePrice,
                    style: AppTypography.statLarge
                        .copyWith(fontSize: 24)),
                Text('/mo',
                    style: AppTypography.caption
                        .copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              perMember,
              style: AppTypography.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(f,
                            style: AppTypography.body
                                .copyWith(fontSize: 13)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                bestFor,
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.text2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingExample extends StatelessWidget {
  final String label;
  final String calculation;

  const _PricingExample({
    required this.label,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.caption.copyWith(fontSize: 12)),
          Text(calculation,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              )),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature('Members', '50', '500', '5,000'),
      _Feature('Base Price', '\$49/mo', '\$149/mo', '\$499/mo'),
      _Feature('Per Member', '\$1.00/mo', '\$0.75/mo', '\$0.50/mo'),
      _Feature('Analytics', 'Basic', 'Full', 'Full'),
      _Feature('Custom Branding', '-', 'Yes', 'Yes'),
      _Feature('Trainer Accounts', '1', '10', '50'),
      _Feature('AI Calls/Member', '20/mo', '50/mo', '200/mo'),
      _Feature('Program Builder', '-', 'Yes', 'Yes'),
      _Feature('Member Messaging', '-', 'Yes', 'Yes'),
      _Feature('White-Label', '-', '-', 'Full'),
      _Feature('API Access', '-', '-', 'Yes'),
      _Feature('Dedicated Manager', '-', '-', 'Yes'),
      _Feature('SLA Guarantee', '-', '-', 'Yes'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius:
            BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusCard)),
            ),
            child: Row(
              children: [
                const Expanded(
                    flex: 3, child: SizedBox.shrink()),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: Text('Starter',
                            style: AppTypography.caption.copyWith(
                                fontWeight:
                                    FontWeight.w600)))),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: Text('Pro',
                            style:
                                AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent)))),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: Text('Enterprise',
                            style: AppTypography.caption.copyWith(
                                fontWeight:
                                    FontWeight.w600)))),
              ],
            ),
          ),
          ...features.map((f) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(f.name,
                            style: AppTypography.caption
                                .copyWith(fontSize: 11))),
                    Expanded(
                        flex: 2,
                        child: Center(
                            child: Text(f.starter,
                                style: AppTypography.caption
                                    .copyWith(
                                        fontSize: 11,
                                        color: f.starter == '-'
                                            ? AppColors.text3
                                            : AppColors
                                                .text1)))),
                    Expanded(
                        flex: 2,
                        child: Center(
                            child: Text(f.pro,
                                style: AppTypography.caption
                                    .copyWith(
                                        fontSize: 11,
                                        color: f.pro == '-'
                                            ? AppColors.text3
                                            : AppColors
                                                .accent)))),
                    Expanded(
                        flex: 2,
                        child: Center(
                            child: Text(f.enterprise,
                                style: AppTypography.caption
                                    .copyWith(
                                        fontSize: 11,
                                        color: f.enterprise ==
                                                '-'
                                            ? AppColors.text3
                                            : AppColors
                                                .text1)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Feature {
  final String name;
  final String starter;
  final String pro;
  final String enterprise;
  const _Feature(
      this.name, this.starter, this.pro, this.enterprise);
}
