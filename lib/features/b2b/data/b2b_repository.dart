import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/b2b_models.dart';

class B2BRepository {
  // In-memory storage for demo
  final Map<String, Organization> _organizations = {};
  final Map<String, List<OrganizationMember>> _members = {};
  final Map<String, List<TrainerProfile>> _trainers = {};
  final Map<String, List<OrganizationProgram>> _programs = {};
  final Map<String, OrganizationAnalytics> _analytics = {};

  // Current user's B2B state
  String? _currentUserOrgId;
  String? _currentUserRole; // 'admin', 'trainer', 'member'
  String _currentUserId = 'current_user';

  B2BRepository() {
    _seedDemoData();
  }

  // ─── Organization CRUD ───

  Future<Organization> createOrganization({
    required String name,
    required String type,
    required OrganizationPlan plan,
    required String adminUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = 'org_${DateTime.now().millisecondsSinceEpoch}';
    final org = Organization(
      id: id,
      name: name,
      type: type,
      branding: OrganizationBranding(
        primaryColorHex: '3B82F6',
        showPoweredByGymGenius: true,
        tagline: '$name - Powered by GymGenius',
      ),
      plan: plan,
      adminUserId: adminUserId,
      memberIds: [adminUserId],
      memberLimit: plan.maxMembers,
      createdAt: DateTime.now(),
      isActive: true,
      settings: const OrganizationSettings(),
      accessCode: _generateCode(),
    );
    _organizations[id] = org;
    _members[id] = [
      OrganizationMember(
        userId: adminUserId,
        orgId: id,
        role: 'admin',
        joinedAt: DateTime.now(),
        isActive: true,
        displayName: 'Admin',
        lastActiveAt: DateTime.now(),
      ),
    ];
    _trainers[id] = [];
    _programs[id] = [];
    _analytics[id] = const OrganizationAnalytics(
      totalMembers: 1,
      activeMembers: 1,
      avgWorkoutsPerWeek: 0,
      avgCompletionRate: 0,
      totalWorkoutsThisMonth: 0,
      totalVolumeThisMonth: 0,
      topMembers: [],
      workoutsByDay: {
        'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0,
        'Fri': 0, 'Sat': 0, 'Sun': 0,
      },
      retentionRate: 100,
      newMembersThisMonth: 1,
    );
    _currentUserOrgId = id;
    _currentUserRole = 'admin';
    _currentUserId = adminUserId;
    return org;
  }

  Future<Organization?> getOrganization(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _organizations[orgId];
  }

  Future<Organization?> getCurrentOrganization() async {
    if (_currentUserOrgId == null) return null;
    return _organizations[_currentUserOrgId];
  }

  Future<Organization> updateOrganization(Organization org) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _organizations[org.id] = org;
    return org;
  }

  Future<void> deleteOrganization(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _organizations.remove(orgId);
    _members.remove(orgId);
    _trainers.remove(orgId);
    _programs.remove(orgId);
    _analytics.remove(orgId);
    if (_currentUserOrgId == orgId) {
      _currentUserOrgId = null;
      _currentUserRole = null;
    }
  }

  // ─── Member Management ───

  Future<List<OrganizationMember>> getMembers(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _members[orgId] ?? [];
  }

  Future<OrganizationMember?> getMemberById(String orgId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final members = _members[orgId] ?? [];
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (_) {
      return null;
    }
  }

  Future<OrganizationMember> addMember({
    required String orgId,
    required String userId,
    required String displayName,
    String role = 'member',
    String? assignedTrainerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final member = OrganizationMember(
      userId: userId,
      orgId: orgId,
      role: role,
      joinedAt: DateTime.now(),
      isActive: true,
      displayName: displayName,
      lastActiveAt: DateTime.now(),
      assignedTrainerId: assignedTrainerId,
    );
    _members[orgId] = [...(_members[orgId] ?? []), member];
    final org = _organizations[orgId];
    if (org != null) {
      _organizations[orgId] = org.copyWith(
        memberIds: [...org.memberIds, userId],
      );
    }
    return member;
  }

  Future<void> removeMember(String orgId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _members[orgId] = (_members[orgId] ?? [])
        .where((m) => m.userId != userId)
        .toList();
    final org = _organizations[orgId];
    if (org != null) {
      _organizations[orgId] = org.copyWith(
        memberIds: org.memberIds.where((id) => id != userId).toList(),
      );
    }
  }

  Future<OrganizationMember> updateMember(OrganizationMember member) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final members = _members[member.orgId] ?? [];
    final index = members.indexWhere((m) => m.userId == member.userId);
    if (index >= 0) {
      members[index] = member;
      _members[member.orgId] = members;
    }
    return member;
  }

  Future<void> assignTrainerToMember(
      String orgId, String memberId, String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final members = _members[orgId] ?? [];
    final index = members.indexWhere((m) => m.userId == memberId);
    if (index >= 0) {
      members[index] = members[index].copyWith(assignedTrainerId: trainerId);
      _members[orgId] = members;
    }
  }

  Future<void> assignProgramToMember(
      String orgId, String memberId, String programId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final members = _members[orgId] ?? [];
    final index = members.indexWhere((m) => m.userId == memberId);
    if (index >= 0) {
      members[index] = members[index].copyWith(assignedProgramId: programId);
      _members[orgId] = members;
    }
  }

  // ─── Trainer Management ───

  Future<List<TrainerProfile>> getTrainers(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _trainers[orgId] ?? [];
  }

  Future<TrainerProfile> createTrainerProfile({
    required String orgId,
    required String userId,
    required String name,
    String? bio,
    List<String> certifications = const [],
    List<String> specialties = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final trainer = TrainerProfile(
      userId: userId,
      orgId: orgId,
      name: name,
      bio: bio,
      certifications: certifications,
      specialties: specialties,
      clientCount: 0,
      rating: 0,
      reviewCount: 0,
    );
    _trainers[orgId] = [...(_trainers[orgId] ?? []), trainer];
    return trainer;
  }

  Future<List<OrganizationMember>> getTrainerClients(
      String orgId, String trainerId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return (_members[orgId] ?? [])
        .where((m) => m.assignedTrainerId == trainerId && m.role == 'member')
        .toList();
  }

  // ─── Program Management ───

  Future<List<OrganizationProgram>> getPrograms(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _programs[orgId] ?? [];
  }

  Future<OrganizationProgram?> getProgramById(
      String orgId, String programId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final programs = _programs[orgId] ?? [];
    try {
      return programs.firstWhere((p) => p.id == programId);
    } catch (_) {
      return null;
    }
  }

  Future<OrganizationProgram> createProgram(OrganizationProgram program) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _programs[program.orgId] = [
      ...(_programs[program.orgId] ?? []),
      program,
    ];
    return program;
  }

  Future<OrganizationProgram> updateProgram(
      OrganizationProgram program) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final programs = _programs[program.orgId] ?? [];
    final index = programs.indexWhere((p) => p.id == program.id);
    if (index >= 0) {
      programs[index] = program;
      _programs[program.orgId] = programs;
    }
    return program;
  }

  Future<OrganizationProgram> publishProgram(
      String orgId, String programId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final programs = _programs[orgId] ?? [];
    final index = programs.indexWhere((p) => p.id == programId);
    if (index >= 0) {
      programs[index] = programs[index].copyWith(isPublished: true);
      _programs[orgId] = programs;
      return programs[index];
    }
    throw Exception('Program not found');
  }

  Future<void> deleteProgram(String orgId, String programId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _programs[orgId] =
        (_programs[orgId] ?? []).where((p) => p.id != programId).toList();
  }

  // ─── Analytics ───

  Future<OrganizationAnalytics> getAnalytics(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _analytics[orgId] ??
        const OrganizationAnalytics(
          totalMembers: 0,
          activeMembers: 0,
          avgWorkoutsPerWeek: 0,
          avgCompletionRate: 0,
          totalWorkoutsThisMonth: 0,
          totalVolumeThisMonth: 0,
          topMembers: [],
          workoutsByDay: {},
          retentionRate: 0,
          newMembersThisMonth: 0,
        );
  }

  Future<List<MemberActivity>> getMemberActivities(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _analytics[orgId]?.topMembers ?? [];
  }

  // ─── Branding ───

  Future<OrganizationBranding> updateBranding(
      String orgId, OrganizationBranding branding) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final org = _organizations[orgId];
    if (org != null) {
      _organizations[orgId] = org.copyWith(branding: branding);
    }
    return branding;
  }

  // ─── Billing ───

  Future<OrganizationPlan> getPlan(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _organizations[orgId]?.plan ?? OrganizationPlan.starter;
  }

  Future<OrganizationPlan> upgradePlan(
      String orgId, OrganizationPlan newPlan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final org = _organizations[orgId];
    if (org != null) {
      _organizations[orgId] = org.copyWith(
        plan: newPlan,
        memberLimit: newPlan.maxMembers,
      );
    }
    return newPlan;
  }

  int getMemberCount(String orgId) {
    return _members[orgId]?.length ?? 0;
  }

  // ─── Join / B2B User State ───

  Future<Organization?> findByAccessCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _organizations.values
          .firstWhere((o) => o.accessCode.toUpperCase() == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  Future<void> joinOrganization(String orgId, String userId, String name) async {
    await addMember(orgId: orgId, userId: userId, displayName: name);
    _currentUserOrgId = orgId;
    _currentUserRole = 'member';
    _currentUserId = userId;
  }

  bool get isB2BUser => _currentUserOrgId != null;
  String? get currentOrgId => _currentUserOrgId;
  String? get currentUserRole => _currentUserRole;
  String get currentUserId => _currentUserId;

  void setCurrentB2BUser(String orgId, String role) {
    _currentUserOrgId = orgId;
    _currentUserRole = role;
  }

  Future<List<RecentActivityItem>> getRecentActivity(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return [
      RecentActivityItem(
        userId: 'member_1',
        userName: 'Sarah Johnson',
        action: 'completed_workout',
        description: 'Completed "Upper Body Strength" workout',
        timestamp: now.subtract(const Duration(minutes: 12)),
      ),
      RecentActivityItem(
        userId: 'member_2',
        userName: 'Mike Chen',
        action: 'new_pr',
        description: 'New PR: Bench Press 225 lbs',
        timestamp: now.subtract(const Duration(minutes: 34)),
      ),
      RecentActivityItem(
        userId: 'member_3',
        userName: 'Emma Davis',
        action: 'streak',
        description: 'Reached a 30-day workout streak!',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      RecentActivityItem(
        userId: 'member_4',
        userName: 'James Wilson',
        action: 'completed_workout',
        description: 'Completed "HIIT Cardio Blast" workout',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      RecentActivityItem(
        userId: 'member_5',
        userName: 'Lisa Anderson',
        action: 'joined',
        description: 'Joined FitZone Gym',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      RecentActivityItem(
        userId: 'member_6',
        userName: 'David Park',
        action: 'completed_workout',
        description: 'Completed "Leg Day Destroyer" workout',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      RecentActivityItem(
        userId: 'member_2',
        userName: 'Mike Chen',
        action: 'completed_workout',
        description: 'Completed "Full Body Circuit" workout',
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      RecentActivityItem(
        userId: 'member_7',
        userName: 'Rachel Kim',
        action: 'new_pr',
        description: 'New PR: Deadlift 315 lbs',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
      RecentActivityItem(
        userId: 'member_1',
        userName: 'Sarah Johnson',
        action: 'streak',
        description: 'Reached a 14-day workout streak!',
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
      RecentActivityItem(
        userId: 'member_8',
        userName: 'Tom Martinez',
        action: 'completed_workout',
        description: 'Completed "Core & Abs" workout',
        timestamp: now.subtract(const Duration(hours: 10)),
      ),
    ];
  }

  // ─── Settings ───

  Future<OrganizationSettings> updateSettings(
      String orgId, OrganizationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final org = _organizations[orgId];
    if (org != null) {
      _organizations[orgId] = org.copyWith(settings: settings);
    }
    return settings;
  }

  Future<String> regenerateAccessCode(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final code = _generateCode();
    final org = _organizations[orgId];
    if (org != null) {
      _organizations[orgId] = org.copyWith(accessCode: code);
    }
    return code;
  }

  Future<void> deactivateOrganization(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final org = _organizations[orgId];
    if (org != null) {
      _organizations[orgId] = org.copyWith(isActive: false);
    }
    _currentUserOrgId = null;
    _currentUserRole = null;
  }

  // ─── Helpers ───

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final buffer = StringBuffer();
    final now = DateTime.now().microsecondsSinceEpoch;
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[(now + i * 7) % chars.length]);
    }
    return buffer.toString();
  }

  // ─── Demo Data ───

  void _seedDemoData() {
    const orgId = 'org_demo_fitzone';
    const adminId = 'current_user';
    const trainerId1 = 'trainer_1';
    const trainerId2 = 'trainer_2';

    _currentUserOrgId = orgId;
    _currentUserRole = 'admin';
    _currentUserId = adminId;

    _organizations[orgId] = Organization(
      id: orgId,
      name: 'FitZone Gym',
      type: 'gym',
      branding: const OrganizationBranding(
        primaryColorHex: 'EF4444',
        secondaryColorHex: 'F97316',
        tagline: 'Transform Your Body, Transform Your Life',
        welcomeMessage:
            'Welcome to FitZone Gym! Track your workouts, follow programs, and crush your goals.',
        showPoweredByGymGenius: true,
      ),
      plan: OrganizationPlan.professional,
      adminUserId: adminId,
      memberIds: [
        adminId,
        trainerId1,
        trainerId2,
        'member_1',
        'member_2',
        'member_3',
        'member_4',
        'member_5',
        'member_6',
        'member_7',
        'member_8',
      ],
      memberLimit: 500,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      isActive: true,
      settings: const OrganizationSettings(
        requireWorkoutApproval: false,
        allowMemberSocial: true,
        showLeaderboard: true,
      ),
      accessCode: 'FITZ24',
    );

    final now = DateTime.now();

    _members[orgId] = [
      OrganizationMember(
        userId: adminId,
        orgId: orgId,
        role: 'admin',
        joinedAt: now.subtract(const Duration(days: 120)),
        isActive: true,
        displayName: 'Alex Rivera',
        lastActiveAt: now,
        workoutsThisWeek: 4,
        currentStreak: 22,
      ),
      OrganizationMember(
        userId: trainerId1,
        orgId: orgId,
        role: 'trainer',
        joinedAt: now.subtract(const Duration(days: 110)),
        isActive: true,
        displayName: 'Coach Marcus',
        lastActiveAt: now.subtract(const Duration(hours: 1)),
        workoutsThisWeek: 6,
        currentStreak: 45,
      ),
      OrganizationMember(
        userId: trainerId2,
        orgId: orgId,
        role: 'trainer',
        joinedAt: now.subtract(const Duration(days: 95)),
        isActive: true,
        displayName: 'Coach Priya',
        lastActiveAt: now.subtract(const Duration(hours: 2)),
        workoutsThisWeek: 5,
        currentStreak: 38,
      ),
      OrganizationMember(
        userId: 'member_1',
        orgId: orgId,
        role: 'member',
        joinedAt: now.subtract(const Duration(days: 90)),
        isActive: true,
        displayName: 'Sarah Johnson',
        lastActiveAt: now.subtract(const Duration(minutes: 12)),
        workoutsThisWeek: 5,
        currentStreak: 14,
        assignedTrainerId: trainerId1,
        assignedProgramId: 'prog_1',
      ),
      OrganizationMember(
        userId: 'member_2',
        orgId: orgId,
        role: 'member',
        joinedAt: now.subtract(const Duration(days: 75)),
        isActive: true,
        displayName: 'Mike Chen',
        lastActiveAt: now.subtract(const Duration(minutes: 34)),
        workoutsThisWeek: 6,
        currentStreak: 21,
        assignedTrainerId: trainerId1,
        assignedProgramId: 'prog_1',
      ),
      OrganizationMember(
        userId: 'member_3',
        orgId: orgId,
        role: 'member',
        joinedAt: now.subtract(const Duration(days: 60)),
        isActive: true,
        displayName: 'Emma Davis',
        lastActiveAt: now.subtract(const Duration(hours: 1)),
        workoutsThisWeek: 4,
        currentStreak: 30,
        assignedTrainerId: trainerId2,
        assignedProgramId: 'prog_2',
      ),
      OrganizationMember(
        userId: 'member_4',
        orgId: orgId,
        role: 'member',
        joinedAt: now.subtract(const Duration(days: 45)),
        isActive: true,
        displayName: 'James Wilson',
        lastActiveAt: now.subtract(const Duration(hours: 2)),
        workoutsThisWeek: 3,
        currentStreak: 7,
        assignedTrainerId: trainerId1,
        assignedProgramId: 'prog_1',
      ),
      OrganizationMember(
        userId: 'member_5',
        orgId: orgId,
        role: 'member',
        joinedAt: now.subtract(const Duration(days: 3)),
        isActive: true,
        displayName: 'Lisa Anderson',
        lastActiveAt: now.subtract(const Duration(hours: 3)),
        workoutsThisWeek: 1,
        currentStreak: 3,
        assignedTrainerId: trainerId2,
      ),
      OrganizationMember(
        userId: 'member_6',
        orgId: orgId,
        role: 'member',
        joinedAt: now.subtract(const Duration(days: 30)),
        isActive: true,
        displayName: 'David Park',
        lastActiveAt: now.subtract(const Duration(hours: 4)),
        workoutsThisWeek: 4,
        currentStreak: 12,
        assignedTrainerId: trainerId2,
        assignedProgramId: 'prog_2',
      ),
      OrganizationMember(
        userId: 'member_7',
        orgId: orgId,
        role: 'member',
        joinedAt: now.subtract(const Duration(days: 20)),
        isActive: false,
        displayName: 'Rachel Kim',
        lastActiveAt: now.subtract(const Duration(days: 8)),
        workoutsThisWeek: 0,
        currentStreak: 0,
        assignedTrainerId: trainerId1,
      ),
      OrganizationMember(
        userId: 'member_8',
        orgId: orgId,
        role: 'member',
        joinedAt: now.subtract(const Duration(days: 15)),
        isActive: true,
        displayName: 'Tom Martinez',
        lastActiveAt: now.subtract(const Duration(hours: 10)),
        workoutsThisWeek: 3,
        currentStreak: 9,
        assignedTrainerId: trainerId2,
        assignedProgramId: 'prog_1',
      ),
    ];

    _trainers[orgId] = [
      const TrainerProfile(
        userId: trainerId1,
        orgId: orgId,
        name: 'Coach Marcus',
        bio:
            'NASM Certified Personal Trainer with 8 years of experience specializing in strength training and bodybuilding.',
        certifications: ['NASM-CPT', 'CSCS', 'FMS Level 2'],
        specialties: [
          'Strength Training',
          'Bodybuilding',
          'Sports Performance'
        ],
        clientCount: 4,
        rating: 4.9,
        reviewCount: 47,
      ),
      const TrainerProfile(
        userId: trainerId2,
        orgId: orgId,
        name: 'Coach Priya',
        bio:
            'ACE Certified with a focus on functional fitness, HIIT, and helping beginners build sustainable habits.',
        certifications: ['ACE-CPT', 'Precision Nutrition L1', 'TRX Certified'],
        specialties: [
          'Functional Fitness',
          'HIIT',
          'Weight Loss',
          'Beginner Programs'
        ],
        clientCount: 4,
        rating: 4.8,
        reviewCount: 35,
      ),
    ];

    _programs[orgId] = [
      OrganizationProgram(
        id: 'prog_1',
        orgId: orgId,
        createdBy: trainerId1,
        name: 'Strength Foundation',
        description:
            'A 4-week program designed to build a solid strength base. Focuses on compound movements with progressive overload.',
        difficulty: 'Intermediate',
        durationWeeks: 4,
        targetGoals: ['Build Strength', 'Muscle Growth', 'Improve Form'],
        weeks: [
          ProgramWeek(
            weekNumber: 1,
            focus: 'Foundation & Assessment',
            days: [
              const ProgramDay(
                  dayNumber: 1,
                  templateName: 'Upper Body Push',
                  notes: 'Focus on form, moderate weight'),
              const ProgramDay(
                  dayNumber: 2,
                  templateName: 'Lower Body',
                  notes: 'Squat focus day'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4,
                  templateName: 'Upper Body Pull',
                  notes: 'Row and pull-up variations'),
              const ProgramDay(
                  dayNumber: 5,
                  templateName: 'Full Body',
                  notes: 'Compound movements'),
              const ProgramDay(dayNumber: 6, isRestDay: true),
              const ProgramDay(
                  dayNumber: 7,
                  templateName: 'Active Recovery',
                  notes: 'Light cardio + mobility'),
            ],
          ),
          ProgramWeek(
            weekNumber: 2,
            focus: 'Volume Increase',
            days: [
              const ProgramDay(
                  dayNumber: 1,
                  templateName: 'Upper Body Push',
                  notes: 'Add 1 set per exercise'),
              const ProgramDay(
                  dayNumber: 2,
                  templateName: 'Lower Body',
                  notes: 'Increase weight 5%'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4,
                  templateName: 'Upper Body Pull',
                  notes: 'Add 1 set per exercise'),
              const ProgramDay(
                  dayNumber: 5,
                  templateName: 'Full Body',
                  notes: 'Increase weight 5%'),
              const ProgramDay(dayNumber: 6, isRestDay: true),
              const ProgramDay(
                  dayNumber: 7,
                  templateName: 'Active Recovery',
                  notes: 'Yoga or swimming'),
            ],
          ),
          ProgramWeek(
            weekNumber: 3,
            focus: 'Intensity Phase',
            days: [
              const ProgramDay(
                  dayNumber: 1,
                  templateName: 'Upper Body Push',
                  notes: 'Heavy sets, lower reps'),
              const ProgramDay(
                  dayNumber: 2,
                  templateName: 'Lower Body',
                  notes: 'Heavy squats and deadlifts'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4,
                  templateName: 'Upper Body Pull',
                  notes: 'Weighted pull-ups'),
              const ProgramDay(
                  dayNumber: 5,
                  templateName: 'Full Body Power',
                  notes: 'Explosive movements'),
              const ProgramDay(dayNumber: 6, isRestDay: true),
              const ProgramDay(
                  dayNumber: 7,
                  templateName: 'Active Recovery',
                  notes: 'Foam rolling + stretching'),
            ],
          ),
          ProgramWeek(
            weekNumber: 4,
            focus: 'Deload & Test',
            days: [
              const ProgramDay(
                  dayNumber: 1,
                  templateName: 'Upper Body Push',
                  notes: 'Deload - 60% intensity'),
              const ProgramDay(
                  dayNumber: 2,
                  templateName: 'Lower Body',
                  notes: 'Deload - 60% intensity'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4,
                  templateName: 'Max Testing',
                  notes: 'Test new 1RMs'),
              const ProgramDay(dayNumber: 5, isRestDay: true),
              const ProgramDay(dayNumber: 6, isRestDay: true),
              const ProgramDay(
                  dayNumber: 7,
                  templateName: 'Active Recovery',
                  notes: 'Celebrate progress!'),
            ],
          ),
        ],
        isPublished: true,
        enrolledCount: 5,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      OrganizationProgram(
        id: 'prog_2',
        orgId: orgId,
        createdBy: trainerId2,
        name: 'Lean & Fit 6-Week',
        description:
            'A 6-week fat loss and conditioning program combining HIIT, strength circuits, and active recovery for maximum results.',
        difficulty: 'Beginner',
        durationWeeks: 6,
        targetGoals: ['Fat Loss', 'Endurance', 'Toning'],
        weeks: [
          ProgramWeek(
            weekNumber: 1,
            focus: 'Getting Started',
            days: [
              const ProgramDay(
                  dayNumber: 1,
                  templateName: 'Full Body Circuit',
                  notes: 'Light weight, learn the moves'),
              const ProgramDay(
                  dayNumber: 2,
                  templateName: 'Cardio HIIT',
                  notes: '20 min intervals'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4,
                  templateName: 'Upper Body Circuit',
                  notes: 'Moderate intensity'),
              const ProgramDay(
                  dayNumber: 5,
                  templateName: 'Lower Body Circuit',
                  notes: 'Moderate intensity'),
              const ProgramDay(
                  dayNumber: 6,
                  templateName: 'Steady State Cardio',
                  notes: '30 min walk/jog'),
              const ProgramDay(dayNumber: 7, isRestDay: true),
            ],
          ),
          ProgramWeek(
            weekNumber: 2,
            focus: 'Building Momentum',
            days: [
              const ProgramDay(
                  dayNumber: 1, templateName: 'Full Body Circuit'),
              const ProgramDay(
                  dayNumber: 2,
                  templateName: 'Cardio HIIT',
                  notes: '25 min intervals'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4, templateName: 'Upper Body Circuit'),
              const ProgramDay(
                  dayNumber: 5, templateName: 'Lower Body Circuit'),
              const ProgramDay(
                  dayNumber: 6, templateName: 'Steady State Cardio'),
              const ProgramDay(dayNumber: 7, isRestDay: true),
            ],
          ),
          ProgramWeek(
            weekNumber: 3,
            focus: 'Pushing Limits',
            days: [
              const ProgramDay(
                  dayNumber: 1,
                  templateName: 'Full Body HIIT',
                  notes: 'Increase tempo'),
              const ProgramDay(
                  dayNumber: 2, templateName: 'Cardio Tabata'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4, templateName: 'Strength Circuit'),
              const ProgramDay(
                  dayNumber: 5, templateName: 'Lower Body Power'),
              const ProgramDay(
                  dayNumber: 6, templateName: 'Active Recovery'),
              const ProgramDay(dayNumber: 7, isRestDay: true),
            ],
          ),
          ProgramWeek(
            weekNumber: 4,
            focus: 'Peak Performance',
            days: [
              const ProgramDay(
                  dayNumber: 1, templateName: 'Full Body HIIT'),
              const ProgramDay(
                  dayNumber: 2, templateName: 'Cardio Tabata'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4, templateName: 'Strength Circuit'),
              const ProgramDay(
                  dayNumber: 5, templateName: 'Lower Body Power'),
              const ProgramDay(
                  dayNumber: 6, templateName: 'Steady State Cardio'),
              const ProgramDay(dayNumber: 7, isRestDay: true),
            ],
          ),
          ProgramWeek(
            weekNumber: 5,
            focus: 'Advanced Circuits',
            days: [
              const ProgramDay(
                  dayNumber: 1,
                  templateName: 'Advanced Full Body',
                  notes: 'Supersets'),
              const ProgramDay(
                  dayNumber: 2, templateName: 'Sprint Intervals'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4,
                  templateName: 'Upper Body Burnout'),
              const ProgramDay(
                  dayNumber: 5,
                  templateName: 'Lower Body Burnout'),
              const ProgramDay(
                  dayNumber: 6, templateName: 'Active Recovery'),
              const ProgramDay(dayNumber: 7, isRestDay: true),
            ],
          ),
          ProgramWeek(
            weekNumber: 6,
            focus: 'Final Push',
            days: [
              const ProgramDay(
                  dayNumber: 1,
                  templateName: 'Full Body Max Effort'),
              const ProgramDay(
                  dayNumber: 2, templateName: 'Cardio Challenge'),
              const ProgramDay(dayNumber: 3, isRestDay: true),
              const ProgramDay(
                  dayNumber: 4,
                  templateName: 'Total Body Circuit'),
              const ProgramDay(
                  dayNumber: 5,
                  templateName: 'Progress Test',
                  notes: 'Measure improvements'),
              const ProgramDay(dayNumber: 6, isRestDay: true),
              const ProgramDay(
                  dayNumber: 7,
                  templateName: 'Celebration Workout',
                  notes: 'Fun workout to end the program!'),
            ],
          ),
        ],
        isPublished: true,
        enrolledCount: 3,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];

    _analytics[orgId] = const OrganizationAnalytics(
      totalMembers: 11,
      activeMembers: 9,
      avgWorkoutsPerWeek: 3.8,
      avgCompletionRate: 82.5,
      totalWorkoutsThisMonth: 142,
      totalVolumeThisMonth: 285400,
      topMembers: [
        MemberActivity(
          userId: 'member_2',
          name: 'Mike Chen',
          workoutsThisWeek: 6,
          volumeThisWeek: 18500,
          currentStreak: 21,
        ),
        MemberActivity(
          userId: 'member_1',
          name: 'Sarah Johnson',
          workoutsThisWeek: 5,
          volumeThisWeek: 14200,
          currentStreak: 14,
        ),
        MemberActivity(
          userId: 'member_3',
          name: 'Emma Davis',
          workoutsThisWeek: 4,
          volumeThisWeek: 11800,
          currentStreak: 30,
        ),
        MemberActivity(
          userId: 'member_6',
          name: 'David Park',
          workoutsThisWeek: 4,
          volumeThisWeek: 13100,
          currentStreak: 12,
        ),
        MemberActivity(
          userId: 'member_4',
          name: 'James Wilson',
          workoutsThisWeek: 3,
          volumeThisWeek: 9800,
          currentStreak: 7,
        ),
      ],
      workoutsByDay: {
        'Mon': 45,
        'Tue': 38,
        'Wed': 22,
        'Thu': 41,
        'Fri': 35,
        'Sat': 28,
        'Sun': 15,
      },
      retentionRate: 91.2,
      newMembersThisMonth: 3,
    );
  }
}

final b2bRepositoryProvider = Provider<B2BRepository>((ref) => B2BRepository());
