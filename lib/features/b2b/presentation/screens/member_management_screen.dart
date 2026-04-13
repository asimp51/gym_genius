import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../providers/b2b_providers.dart';
import '../../data/b2b_repository.dart';

class MemberManagementScreen extends ConsumerStatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  ConsumerState<MemberManagementScreen> createState() =>
      _MemberManagementScreenState();
}

class _MemberManagementScreenState
    extends ConsumerState<MemberManagementScreen> {
  String _filter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgAsync = ref.watch(currentOrganizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text('Members', style: AppTypography.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined,
                color: AppColors.accent),
            onPressed: () => _showInviteDialog(context),
          ),
        ],
      ),
      body: orgAsync.when(
        data: (org) {
          if (org == null) {
            return const Center(child: Text('No organization'));
          }
          return _buildBody(org);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(Organization org) {
    final membersAsync = ref.watch(orgMembersProvider(org.id));
    final trainersAsync = ref.watch(orgTrainersProvider(org.id));

    return membersAsync.when(
      data: (members) {
        final filtered = _applyFilters(members);
        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding2XL),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.text3),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.text3),
                  filled: true,
                  fillColor: AppColors.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Member count + filter chips
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding2XL),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${members.length} members',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.accent)),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding2XL),
                children: ['All', 'Active', 'Inactive', 'New This Month']
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f,
                                style: AppTypography.caption.copyWith(
                                  color: _filter == f
                                      ? Colors.white
                                      : AppColors.text2,
                                  fontSize: 12,
                                )),
                            selected: _filter == f,
                            onSelected: (_) =>
                                setState(() => _filter = f),
                            backgroundColor: AppColors.bgSecondary,
                            selectedColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _filter == f
                                    ? AppColors.accent
                                    : AppColors.border,
                              ),
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Member list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 48, color: AppColors.text3),
                          const SizedBox(height: 12),
                          Text('No members found',
                              style: AppTypography.body
                                  .copyWith(color: AppColors.text3)),
                        ],
                      ),
                    )
                  : trainersAsync.when(
                      data: (trainers) => ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.padding2XL),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final member = filtered[index];
                          return _MemberTile(
                            member: member,
                            trainers: trainers,
                            onTap: () =>
                                _showMemberDetail(context, member, trainers),
                          );
                        },
                      ),
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  List<OrganizationMember> _applyFilters(List<OrganizationMember> members) {
    var result = members.toList();

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((m) => m.displayName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    switch (_filter) {
      case 'Active':
        result = result.where((m) => m.isActive).toList();
        break;
      case 'Inactive':
        result = result.where((m) => !m.isActive).toList();
        break;
      case 'New This Month':
        final thirtyDaysAgo =
            DateTime.now().subtract(const Duration(days: 30));
        result =
            result.where((m) => m.joinedAt.isAfter(thirtyDaysAgo)).toList();
        break;
    }

    return result;
  }

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: Text('Invite Member', style: AppTypography.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'Email address',
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
            const SizedBox(height: 16),
            Consumer(builder: (context, ref, _) {
              final codeAsync = ref.watch(orgAccessCodeProvider);
              return codeAsync.when(
                data: (code) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  child: Column(
                    children: [
                      Text('Or share this code:',
                          style: AppTypography.caption),
                      const SizedBox(height: 4),
                      Text(code ?? 'N/A',
                          style: AppTypography.stat
                              .copyWith(color: AppColors.accent)),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.button.copyWith(color: AppColors.text2)),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                final repo = ref.read(b2bRepositoryProvider);
                final orgId = repo.currentOrgId;
                if (orgId != null) {
                  repo.addMember(
                    orgId: orgId,
                    userId: 'invited_${DateTime.now().millisecondsSinceEpoch}',
                    displayName: email.split('@').first,
                  );
                  ref.invalidate(orgMembersProvider);
                  ref.invalidate(currentOrganizationProvider);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invitation sent to $email'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              ),
            ),
            child: Text('Send Invite', style: AppTypography.button),
          ),
        ],
      ),
    );
  }

  void _showMemberDetail(BuildContext context, OrganizationMember member,
      List<TrainerProfile> trainers) {
    final repo = ref.read(b2bRepositoryProvider);
    final orgId = repo.currentOrgId ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppDimensions.padding2XL),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.text3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Avatar + name
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Text(member.displayName[0],
                    style: AppTypography.h1
                        .copyWith(color: AppColors.accent)),
              ),
              const SizedBox(height: 12),
              Text(member.displayName, style: AppTypography.h2),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _roleColor(member.role).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  member.role.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: _roleColor(member.role),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  _DetailStat('Workouts/Week',
                      '${member.workoutsThisWeek}'),
                  _DetailStat('Streak', '${member.currentStreak}'),
                  _DetailStat(
                      'Status', member.isActive ? 'Active' : 'Inactive'),
                ],
              ),
              const SizedBox(height: 16),

              // Info rows
              _InfoRow('Joined', _formatDate(member.joinedAt)),
              _InfoRow('Last Active', _timeAgo(member.lastActiveAt)),
              if (member.assignedTrainerId != null)
                _InfoRow(
                  'Trainer',
                  trainers
                      .where((t) => t.userId == member.assignedTrainerId)
                      .map((t) => t.name)
                      .firstOrNull ??
                      'Unknown',
                ),
              if (member.assignedProgramId != null)
                _InfoRow('Program', member.assignedProgramId!),
              if (member.memberNote != null)
                _InfoRow('Note', member.memberNote!),

              const SizedBox(height: 20),

              // Assign Trainer
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showAssignTrainerDialog(
                        context, member, trainers, orgId);
                  },
                  icon: const Icon(Icons.sports, size: 18),
                  label: const Text('Assign Trainer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusButton),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Remove
              if (member.role != 'admin')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      repo.removeMember(orgId, member.userId);
                      ref.invalidate(orgMembersProvider);
                      ref.invalidate(currentOrganizationProvider);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${member.displayName} has been removed'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_remove, size: 18),
                    label: const Text('Remove Member'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignTrainerDialog(BuildContext context,
      OrganizationMember member, List<TrainerProfile> trainers, String orgId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: Text('Assign Trainer', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: trainers.map((trainer) {
            final isAssigned =
                member.assignedTrainerId == trainer.userId;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.success.withValues(alpha: 0.2),
                child: Text(trainer.name[0],
                    style: AppTypography.button
                        .copyWith(color: AppColors.success)),
              ),
              title: Text(trainer.name, style: AppTypography.body),
              subtitle: Text('${trainer.clientCount} clients',
                  style: AppTypography.caption),
              trailing: isAssigned
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : null,
              onTap: () {
                final repo = ref.read(b2bRepositoryProvider);
                repo.assignTrainerToMember(
                    orgId, member.userId, trainer.userId);
                ref.invalidate(orgMembersProvider);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${trainer.name} assigned to ${member.displayName}'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.warning;
      case 'trainer':
        return AppColors.success;
      default:
        return AppColors.accent;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _MemberTile extends StatelessWidget {
  final OrganizationMember member;
  final List<TrainerProfile> trainers;
  final VoidCallback onTap;

  const _MemberTile({
    required this.member,
    required this.trainers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trainerName = member.assignedTrainerId != null
        ? trainers
            .where((t) => t.userId == member.assignedTrainerId)
            .map((t) => t.name)
            .firstOrNull
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _roleColor(member.role).withValues(alpha: 0.2),
                child: Text(
                  member.displayName[0],
                  style: AppTypography.button
                      .copyWith(color: _roleColor(member.role)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(member.displayName,
                            style: AppTypography.body
                                .copyWith(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                _roleColor(member.role).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            member.role,
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              color: _roleColor(member.role),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (trainerName != null) ...[
                          Icon(Icons.sports,
                              size: 12, color: AppColors.text3),
                          const SizedBox(width: 3),
                          Text(trainerName,
                              style: AppTypography.caption
                                  .copyWith(fontSize: 11)),
                          const SizedBox(width: 8),
                        ],
                        if (!member.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Inactive',
                                style: AppTypography.caption.copyWith(
                                    fontSize: 9, color: AppColors.error)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text('${member.currentStreak}',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.warning, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${member.workoutsThisWeek} / week',
                      style:
                          AppTypography.caption.copyWith(fontSize: 10)),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.warning;
      case 'trainer':
        return AppColors.success;
      default:
        return AppColors.accent;
    }
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  const _DetailStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTypography.stat.copyWith(fontSize: 16)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    AppTypography.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTypography.caption),
          ),
          Expanded(
            child: Text(value,
                style: AppTypography.body.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
