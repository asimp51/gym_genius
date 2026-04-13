import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../providers/b2b_providers.dart';
import '../../data/b2b_repository.dart';

class OrgSettingsScreen extends ConsumerWidget {
  const OrgSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(currentOrganizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text('Organization Settings', style: AppTypography.h2),
      ),
      body: orgAsync.when(
        data: (org) {
          if (org == null) return const Center(child: Text('No org'));
          return _SettingsBody(org: org);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SettingsBody extends ConsumerStatefulWidget {
  final Organization org;
  const _SettingsBody({required this.org});

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  late bool _requireApproval;
  late bool _allowSocial;
  late bool _showLeaderboard;
  late String _accessCode;

  @override
  void initState() {
    super.initState();
    _requireApproval = widget.org.settings.requireWorkoutApproval;
    _allowSocial = widget.org.settings.allowMemberSocial;
    _showLeaderboard = widget.org.settings.showLeaderboard;
    _accessCode = widget.org.accessCode;
  }

  @override
  Widget build(BuildContext context) {
    final org = widget.org;
    final memberCount =
        ref.read(b2bRepositoryProvider).getMemberCount(org.id);
    final programsAsync = ref.watch(orgProgramsProvider(org.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.padding2XL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan & Billing
          _SectionHeader('Plan & Billing'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.12),
                  AppColors.accentSecondary.withOpacity(0.06),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusCard),
              border:
                  Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        org.plan.tier.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${org.plan.pricePerMonth.toStringAsFixed(0)}/mo',
                      style: AppTypography.stat.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Usage bar
                Row(
                  children: [
                    Text('Members: ', style: AppTypography.caption),
                    Text('$memberCount / ${org.plan.maxMembers == 999999 ? "Unlimited" : org.plan.maxMembers}',
                        style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                if (org.plan.maxMembers != 999999)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: memberCount / org.plan.maxMembers,
                      backgroundColor: AppColors.bgTertiary,
                      valueColor: AlwaysStoppedAnimation(
                        memberCount / org.plan.maxMembers > 0.9
                            ? AppColors.error
                            : AppColors.accent,
                      ),
                      minHeight: 6,
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showUpgradeDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                      ),
                    ),
                    child: const Text('Upgrade Plan'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // General
          _SectionHeader('General'),
          const SizedBox(height: 12),
          _InfoTile('Organization Name', org.name),
          _InfoTile('Type', org.type[0].toUpperCase() + org.type.substring(1)),
          _InfoTile('Admin', 'Alex Rivera'),
          const SizedBox(height: 24),

          // Member Policies
          _SectionHeader('Member Policies'),
          const SizedBox(height: 12),
          _ToggleTile(
            'Require Workout Approval',
            'Trainers must approve completed workouts',
            _requireApproval,
            (val) {
              setState(() => _requireApproval = val);
              _saveSettings();
            },
          ),
          _ToggleTile(
            'Allow Member Social',
            'Members can post in the social feed',
            _allowSocial,
            (val) {
              setState(() => _allowSocial = val);
              _saveSettings();
            },
          ),
          _ToggleTile(
            'Show Leaderboard',
            'Display member rankings',
            _showLeaderboard,
            (val) {
              setState(() => _showLeaderboard = val);
              _saveSettings();
            },
          ),
          const SizedBox(height: 24),

          // Default Program
          _SectionHeader('Default Program'),
          const SizedBox(height: 12),
          programsAsync.when(
            data: (programs) {
              final published =
                  programs.where((p) => p.isPublished).toList();
              if (published.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusCard),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('No published programs available',
                      style: AppTypography.body
                          .copyWith(color: AppColors.text3)),
                );
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButton<String>(
                  value: org.settings.defaultProgramId,
                  hint: Text('Select default program',
                      style: AppTypography.body
                          .copyWith(color: AppColors.text3)),
                  isExpanded: true,
                  dropdownColor: AppColors.bgSecondary,
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('None'),
                    ),
                    ...published.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name,
                              style: AppTypography.body),
                        )),
                  ],
                  onChanged: (val) {
                    final repo = ref.read(b2bRepositoryProvider);
                    repo.updateSettings(
                      org.id,
                      org.settings
                          .copyWith(defaultProgramId: val ?? ''),
                    );
                    ref.invalidate(currentOrganizationProvider);
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Invitations
          _SectionHeader('Invitations'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Access Code', style: AppTypography.caption),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bgTertiary,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton),
                        ),
                        child: Text(_accessCode,
                            style: AppTypography.stat.copyWith(
                                fontSize: 20,
                                color: AppColors.accent,
                                letterSpacing: 4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _accessCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy,
                          color: AppColors.accent, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final repo = ref.read(b2bRepositoryProvider);
                      final code =
                          await repo.regenerateAccessCode(org.id);
                      setState(() => _accessCode = code);
                      ref.invalidate(currentOrganizationProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('New access code: $code'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Regenerate Code'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Share this code with members so they can join your organization.',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Danger Zone
          _SectionHeader('Danger Zone'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deactivate Organization',
                    style: AppTypography.body
                        .copyWith(color: AppColors.error)),
                const SizedBox(height: 4),
                Text(
                  'This will remove all members and disable the organization. This action cannot be undone.',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        _showDeactivateDialog(context, ref, org),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                      ),
                    ),
                    child: const Text('Deactivate Organization'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _saveSettings() {
    final repo = ref.read(b2bRepositoryProvider);
    repo.updateSettings(
      widget.org.id,
      widget.org.settings.copyWith(
        requireWorkoutApproval: _requireApproval,
        allowMemberSocial: _allowSocial,
        showLeaderboard: _showLeaderboard,
      ),
    );
    ref.invalidate(currentOrganizationProvider);
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: Text('Upgrade Plan', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PlanOption(
              'Starter',
              '\$49/mo',
              'Up to 50 members',
              widget.org.plan.tier == 'starter',
              () => _doUpgrade(ctx, OrganizationPlan.starter),
            ),
            const SizedBox(height: 8),
            _PlanOption(
              'Professional',
              '\$149/mo',
              'Up to 500 members, custom branding',
              widget.org.plan.tier == 'professional',
              () => _doUpgrade(ctx, OrganizationPlan.professional),
            ),
            const SizedBox(height: 8),
            _PlanOption(
              'Enterprise',
              '\$499/mo',
              'Unlimited members, API access',
              widget.org.plan.tier == 'enterprise',
              () => _doUpgrade(ctx, OrganizationPlan.enterprise),
            ),
          ],
        ),
      ),
    );
  }

  void _doUpgrade(BuildContext dialogContext, OrganizationPlan plan) {
    final repo = ref.read(b2bRepositoryProvider);
    repo.upgradePlan(widget.org.id, plan);
    ref.invalidate(currentOrganizationProvider);
    Navigator.pop(dialogContext);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upgraded to ${plan.tier} plan'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showDeactivateDialog(
      BuildContext context, WidgetRef ref, Organization org) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: Text('Deactivate Organization?',
            style: AppTypography.h3.copyWith(color: AppColors.error)),
        content: Text(
          'This will permanently deactivate ${org.name}. All members will lose access. This cannot be undone.',
          style: AppTypography.body,
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
              final repo = ref.read(b2bRepositoryProvider);
              repo.deactivateOrganization(org.id);
              ref.invalidate(currentOrganizationProvider);
              Navigator.pop(ctx);
              context.go('/profile');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Organization has been deactivated'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              ),
            ),
            child: Text('Deactivate',
                style:
                    AppTypography.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.h3);
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: AppTypography.body)),
          Text(value,
              style:
                  AppTypography.body.copyWith(color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile(
      this.title, this.subtitle, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body),
                Text(subtitle,
                    style:
                        AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final String name;
  final String price;
  final String desc;
  final bool isCurrent;
  final VoidCallback onTap;

  const _PlanOption(
      this.name, this.price, this.desc, this.isCurrent, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isCurrent ? null : onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.accent.withOpacity(0.1)
              : AppColors.bgTertiary,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusButton),
          border: Border.all(
            color: isCurrent ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: AppTypography.body
                              .copyWith(fontWeight: FontWeight.w600)),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Current',
                              style: AppTypography.caption.copyWith(
                                  color: Colors.white, fontSize: 9)),
                        ),
                      ],
                    ],
                  ),
                  Text(desc,
                      style: AppTypography.caption
                          .copyWith(fontSize: 11)),
                ],
              ),
            ),
            Text(price,
                style: AppTypography.stat.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
