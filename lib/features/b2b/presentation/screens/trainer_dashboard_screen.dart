import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../providers/b2b_providers.dart';
import '../../data/b2b_repository.dart';

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(currentOrganizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text('My Clients', style: AppTypography.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.accent),
            onPressed: () => context.push('/b2b-program-builder'),
            tooltip: 'Create Program',
          ),
        ],
      ),
      body: orgAsync.when(
        data: (org) {
          if (org == null) {
            return const Center(child: Text('No organization'));
          }
          return _TrainerBody(org: org);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _TrainerBody extends ConsumerWidget {
  final Organization org;
  const _TrainerBody({required this.org});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(b2bRepositoryProvider);
    final trainerId = repo.currentUserId;
    final trainersAsync = ref.watch(orgTrainersProvider(org.id));
    final membersAsync = ref.watch(orgMembersProvider(org.id));
    final programsAsync = ref.watch(orgProgramsProvider(org.id));

    return trainersAsync.when(
      data: (trainers) {
        // Find the current user's trainer profile, or use first trainer for demo
        TrainerProfile? currentTrainer;
        for (final t in trainers) {
          if (t.userId == trainerId) {
            currentTrainer = t;
            break;
          }
        }
        currentTrainer ??= trainers.isNotEmpty ? trainers.first : null;

        if (currentTrainer == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_outlined,
                    size: 64, color: AppColors.text3),
                const SizedBox(height: 16),
                Text('No trainer profile found',
                    style: AppTypography.h3),
                const SizedBox(height: 8),
                Text('Contact your organization admin',
                    style: AppTypography.caption),
              ],
            ),
          );
        }

        return membersAsync.when(
          data: (allMembers) {
            final clients = allMembers
                .where((m) =>
                    m.assignedTrainerId == currentTrainer!.userId &&
                    m.role == 'member')
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.padding2XL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trainer stats
                  _TrainerStatsRow(
                    trainer: currentTrainer!,
                    clientCount: clients.length,
                  ),
                  const SizedBox(height: 24),

                  // Client list
                  Text('Clients (${clients.length})',
                      style: AppTypography.h3),
                  const SizedBox(height: 12),
                  if (clients.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusCard),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline,
                              size: 48, color: AppColors.text3),
                          const SizedBox(height: 12),
                          Text('No clients assigned yet',
                              style: AppTypography.body
                                  .copyWith(color: AppColors.text3)),
                        ],
                      ),
                    )
                  else
                    ...clients.map((client) => programsAsync.when(
                          data: (programs) => _ClientCard(
                            client: client,
                            programs: programs,
                            onTap: () => _showClientDetail(
                                context, ref, client, programs),
                          ),
                          loading: () =>
                              _ClientCard(client: client, programs: const [], onTap: () {}),
                          error: (_, __) =>
                              _ClientCard(client: client, programs: const [], onTap: () {}),
                        )),

                  const SizedBox(height: 24),

                  // Messages section
                  Text('Messages', style: AppTypography.h3),
                  const SizedBox(height: 12),
                  _MessagesList(clients: clients),
                  const SizedBox(height: 24),

                  // Create Program button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/b2b-program-builder'),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Create Program'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _showClientDetail(BuildContext context, WidgetRef ref,
      OrganizationMember client, List<OrganizationProgram> programs) {
    final assignedProgram = client.assignedProgramId != null
        ? programs.where((p) => p.id == client.assignedProgramId).firstOrNull
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.accent.withOpacity(0.2),
                  child: Text(client.displayName[0],
                      style: AppTypography.h1
                          .copyWith(color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                  child:
                      Text(client.displayName, style: AppTypography.h2)),
              const SizedBox(height: 20),

              // Progress cards
              Row(
                children: [
                  _ClientStatBox(
                      'Workouts/Week', '${client.workoutsThisWeek}'),
                  const SizedBox(width: 8),
                  _ClientStatBox('Streak', '${client.currentStreak}'),
                  const SizedBox(width: 8),
                  _ClientStatBox(
                      'Status', client.isActive ? 'Active' : 'Away'),
                ],
              ),
              const SizedBox(height: 20),

              // Current program
              Text('Current Program', style: AppTypography.h3),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                ),
                child: assignedProgram != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(assignedProgram.name,
                              style: AppTypography.body
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                              '${assignedProgram.difficulty} | ${assignedProgram.durationWeeks} weeks',
                              style: AppTypography.caption),
                        ],
                      )
                    : Text('No program assigned',
                        style: AppTypography.body
                            .copyWith(color: AppColors.text3)),
              ),
              const SizedBox(height: 20),

              // Simulated progress chart
              Text('Weekly Progress', style: AppTypography.h3),
              const SizedBox(height: 8),
              _SimpleProgressBars(
                  clientName: client.displayName,
                  workouts: client.workoutsThisWeek),
              const SizedBox(height: 20),

              // Assign program button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showAssignProgramDialog(
                        context, ref, client, programs);
                  },
                  icon: const Icon(Icons.assignment, size: 18),
                  label: const Text('Assign Program'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusButton),
                    ),
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

  void _showAssignProgramDialog(BuildContext context, WidgetRef ref,
      OrganizationMember client, List<OrganizationProgram> programs) {
    final published = programs.where((p) => p.isPublished).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: Text('Assign Program', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: published.isEmpty
              ? [
                  Text('No published programs available',
                      style: AppTypography.body
                          .copyWith(color: AppColors.text3)),
                ]
              : published.map((program) {
                  final isAssigned =
                      client.assignedProgramId == program.id;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.assignment,
                          size: 18, color: AppColors.accent),
                    ),
                    title:
                        Text(program.name, style: AppTypography.body),
                    subtitle: Text(
                        '${program.difficulty} | ${program.durationWeeks}w',
                        style: AppTypography.caption),
                    trailing: isAssigned
                        ? const Icon(Icons.check_circle,
                            color: AppColors.success)
                        : null,
                    onTap: () {
                      final repo = ref.read(b2bRepositoryProvider);
                      repo.assignProgramToMember(
                          org.id, client.userId, program.id);
                      ref.invalidate(orgMembersProvider);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${program.name} assigned to ${client.displayName}'),
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
}

class _TrainerStatsRow extends StatelessWidget {
  final TrainerProfile trainer;
  final int clientCount;

  const _TrainerStatsRow({
    required this.trainer,
    required this.clientCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.15),
            AppColors.accentSecondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.success.withOpacity(0.2),
                child: Text(trainer.name[0],
                    style: AppTypography.h3
                        .copyWith(color: AppColors.success)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trainer.name,
                        style: AppTypography.h3),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: AppColors.warning),
                        const SizedBox(width: 3),
                        Text('${trainer.rating}',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.warning)),
                        Text(' (${trainer.reviewCount} reviews)',
                            style: AppTypography.caption
                                .copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TrainerStat('Clients', '$clientCount'),
              _TrainerStat('Rating', '${trainer.rating}'),
              _TrainerStat('Reviews', '${trainer.reviewCount}'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: trainer.certifications
                .map((cert) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(cert,
                          style: AppTypography.caption
                              .copyWith(fontSize: 10)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TrainerStat extends StatelessWidget {
  final String label;
  final String value;
  const _TrainerStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.stat.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final OrganizationMember client;
  final List<OrganizationProgram> programs;
  final VoidCallback onTap;

  const _ClientCard({
    required this.client,
    required this.programs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final programName = client.assignedProgramId != null
        ? programs
            .where((p) => p.id == client.assignedProgramId)
            .map((p) => p.name)
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
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.accent.withOpacity(0.2),
                child: Text(client.displayName[0],
                    style: AppTypography.button
                        .copyWith(color: AppColors.accent)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.displayName,
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${client.workoutsThisWeek}/week',
                          style: AppTypography.caption
                              .copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        if (programName != null) ...[
                          Icon(Icons.assignment,
                              size: 12, color: AppColors.text3),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(programName,
                                style: AppTypography.caption
                                    .copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 2),
                  Text('${client.currentStreak}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.warning)),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientStatBox extends StatelessWidget {
  final String label;
  final String value;
  const _ClientStatBox(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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

class _SimpleProgressBars extends StatelessWidget {
  final String clientName;
  final int workouts;

  const _SimpleProgressBars(
      {required this.clientName, required this.workouts});

  @override
  Widget build(BuildContext context) {
    // Simulated weekly data
    final weekData = [
      {'week': 'W1', 'val': (workouts * 0.6).round()},
      {'week': 'W2', 'val': (workouts * 0.8).round()},
      {'week': 'W3', 'val': (workouts * 0.7).round()},
      {'week': 'W4', 'val': workouts},
    ];
    final maxVal = weekData.fold<int>(
        1, (prev, e) => (e['val'] as int) > prev ? e['val'] as int : prev);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weekData.map((d) {
          final val = d['val'] as int;
          final height = maxVal > 0 ? (val / maxVal) * 60 : 0.0;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$val',
                    style:
                        AppTypography.caption.copyWith(fontSize: 10)),
                const SizedBox(height: 4),
                Container(
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.accent,
                        AppColors.accentSecondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(d['week'] as String,
                    style:
                        AppTypography.caption.copyWith(fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final List<OrganizationMember> clients;
  const _MessagesList({required this.clients});

  @override
  Widget build(BuildContext context) {
    final messages = clients.take(3).map((c) {
      final msgs = [
        'Great workout today! Keep it up.',
        'Remember to log your meals this week.',
        'How are you feeling after the new program?',
      ];
      return _Message(
        name: c.displayName,
        initial: c.displayName[0],
        text: msgs[clients.indexOf(c) % msgs.length],
        time: '${(clients.indexOf(c) + 1) * 2}h ago',
      );
    }).toList();

    if (messages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text('No messages yet',
              style:
                  AppTypography.body.copyWith(color: AppColors.text3)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(messages.length, (index) {
          final msg = messages[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppColors.accent.withOpacity(0.2),
                      child: Text(msg.initial,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.accent)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.name,
                              style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13)),
                          Text(msg.text,
                              style: AppTypography.caption
                                  .copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text(msg.time,
                        style: AppTypography.caption
                            .copyWith(fontSize: 10)),
                  ],
                ),
              ),
              if (index < messages.length - 1)
                const Divider(
                    height: 1, color: AppColors.border, indent: 52),
            ],
          );
        }),
      ),
    );
  }
}

class _Message {
  final String name;
  final String initial;
  final String text;
  final String time;
  const _Message(
      {required this.name,
      required this.initial,
      required this.text,
      required this.time});
}
