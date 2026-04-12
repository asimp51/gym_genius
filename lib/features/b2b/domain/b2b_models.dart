class Organization {
  final String id;
  final String name;
  final String type; // 'gym', 'corporate', 'trainer', 'insurance', 'clinic'
  final OrganizationBranding branding;
  final OrganizationPlan plan;
  final String adminUserId;
  final List<String> memberIds;
  final int memberLimit;
  final DateTime createdAt;
  final bool isActive;
  final OrganizationSettings settings;
  final String accessCode;

  const Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.branding,
    required this.plan,
    required this.adminUserId,
    required this.memberIds,
    required this.memberLimit,
    required this.createdAt,
    required this.isActive,
    required this.settings,
    this.accessCode = '',
  });

  Organization copyWith({
    String? id,
    String? name,
    String? type,
    OrganizationBranding? branding,
    OrganizationPlan? plan,
    String? adminUserId,
    List<String>? memberIds,
    int? memberLimit,
    DateTime? createdAt,
    bool? isActive,
    OrganizationSettings? settings,
    String? accessCode,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      branding: branding ?? this.branding,
      plan: plan ?? this.plan,
      adminUserId: adminUserId ?? this.adminUserId,
      memberIds: memberIds ?? this.memberIds,
      memberLimit: memberLimit ?? this.memberLimit,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
      accessCode: accessCode ?? this.accessCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'branding': branding.toJson(),
        'plan': plan.toJson(),
        'adminUserId': adminUserId,
        'memberIds': memberIds,
        'memberLimit': memberLimit,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'settings': settings.toJson(),
        'accessCode': accessCode,
      };

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        branding: OrganizationBranding.fromJson(
            json['branding'] as Map<String, dynamic>),
        plan: OrganizationPlan.fromJson(json['plan'] as Map<String, dynamic>),
        adminUserId: json['adminUserId'] as String,
        memberIds: List<String>.from(json['memberIds'] as List),
        memberLimit: json['memberLimit'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isActive: json['isActive'] as bool,
        settings: OrganizationSettings.fromJson(
            json['settings'] as Map<String, dynamic>),
        accessCode: json['accessCode'] as String? ?? '',
      );
}

class OrganizationBranding {
  final String? logoUrl;
  final String primaryColorHex;
  final String? secondaryColorHex;
  final String? tagline;
  final String? welcomeMessage;
  final bool showPoweredByGymGenius;

  const OrganizationBranding({
    this.logoUrl,
    required this.primaryColorHex,
    this.secondaryColorHex,
    this.tagline,
    this.welcomeMessage,
    this.showPoweredByGymGenius = true,
  });

  OrganizationBranding copyWith({
    String? logoUrl,
    String? primaryColorHex,
    String? secondaryColorHex,
    String? tagline,
    String? welcomeMessage,
    bool? showPoweredByGymGenius,
  }) {
    return OrganizationBranding(
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      tagline: tagline ?? this.tagline,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      showPoweredByGymGenius:
          showPoweredByGymGenius ?? this.showPoweredByGymGenius,
    );
  }

  Map<String, dynamic> toJson() => {
        'logoUrl': logoUrl,
        'primaryColorHex': primaryColorHex,
        'secondaryColorHex': secondaryColorHex,
        'tagline': tagline,
        'welcomeMessage': welcomeMessage,
        'showPoweredByGymGenius': showPoweredByGymGenius,
      };

  factory OrganizationBranding.fromJson(Map<String, dynamic> json) =>
      OrganizationBranding(
        logoUrl: json['logoUrl'] as String?,
        primaryColorHex: json['primaryColorHex'] as String,
        secondaryColorHex: json['secondaryColorHex'] as String?,
        tagline: json['tagline'] as String?,
        welcomeMessage: json['welcomeMessage'] as String?,
        showPoweredByGymGenius:
            json['showPoweredByGymGenius'] as bool? ?? true,
      );
}

class OrganizationPlan {
  final String tier; // 'starter', 'professional', 'enterprise'
  final int maxMembers;
  final bool customBranding;
  final bool analyticsAccess;
  final bool programCreation;
  final bool memberMessaging;
  final bool apiAccess;
  final double pricePerMonth;
  final double pricePerMember;
  final int aiCallsPerMember; // 20, 50, or 200 per member/month

  const OrganizationPlan({
    required this.tier,
    required this.maxMembers,
    required this.customBranding,
    required this.analyticsAccess,
    required this.programCreation,
    required this.memberMessaging,
    required this.apiAccess,
    required this.pricePerMonth,
    required this.pricePerMember,
    required this.aiCallsPerMember,
  });

  OrganizationPlan copyWith({
    String? tier,
    int? maxMembers,
    bool? customBranding,
    bool? analyticsAccess,
    bool? programCreation,
    bool? memberMessaging,
    bool? apiAccess,
    double? pricePerMonth,
    double? pricePerMember,
    int? aiCallsPerMember,
  }) {
    return OrganizationPlan(
      tier: tier ?? this.tier,
      maxMembers: maxMembers ?? this.maxMembers,
      customBranding: customBranding ?? this.customBranding,
      analyticsAccess: analyticsAccess ?? this.analyticsAccess,
      programCreation: programCreation ?? this.programCreation,
      memberMessaging: memberMessaging ?? this.memberMessaging,
      apiAccess: apiAccess ?? this.apiAccess,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      pricePerMember: pricePerMember ?? this.pricePerMember,
      aiCallsPerMember: aiCallsPerMember ?? this.aiCallsPerMember,
    );
  }

  /// Calculate total monthly cost for a given number of active members
  double totalMonthlyCost(int activeMembers) {
    return pricePerMonth + (pricePerMember * activeMembers);
  }

  Map<String, dynamic> toJson() => {
        'tier': tier,
        'maxMembers': maxMembers,
        'customBranding': customBranding,
        'analyticsAccess': analyticsAccess,
        'programCreation': programCreation,
        'memberMessaging': memberMessaging,
        'apiAccess': apiAccess,
        'pricePerMonth': pricePerMonth,
        'pricePerMember': pricePerMember,
        'aiCallsPerMember': aiCallsPerMember,
      };

  factory OrganizationPlan.fromJson(Map<String, dynamic> json) =>
      OrganizationPlan(
        tier: json['tier'] as String,
        maxMembers: json['maxMembers'] as int,
        customBranding: json['customBranding'] as bool,
        analyticsAccess: json['analyticsAccess'] as bool,
        programCreation: json['programCreation'] as bool,
        memberMessaging: json['memberMessaging'] as bool,
        apiAccess: json['apiAccess'] as bool,
        pricePerMonth: (json['pricePerMonth'] as num).toDouble(),
        pricePerMember: (json['pricePerMember'] as num?)?.toDouble() ?? 0.0,
        aiCallsPerMember: json['aiCallsPerMember'] as int? ?? 0,
      );

  static const OrganizationPlan starter = OrganizationPlan(
    tier: 'starter',
    maxMembers: 50,
    customBranding: false,
    analyticsAccess: true,
    programCreation: false,
    memberMessaging: false,
    apiAccess: false,
    pricePerMonth: 49.0,
    pricePerMember: 1.00,
    aiCallsPerMember: 20,
  );

  static const OrganizationPlan professional = OrganizationPlan(
    tier: 'professional',
    maxMembers: 500,
    customBranding: true,
    analyticsAccess: true,
    programCreation: true,
    memberMessaging: true,
    apiAccess: false,
    pricePerMonth: 149.0,
    pricePerMember: 0.75,
    aiCallsPerMember: 50,
  );

  static const OrganizationPlan enterprise = OrganizationPlan(
    tier: 'enterprise',
    maxMembers: 5000,
    customBranding: true,
    analyticsAccess: true,
    programCreation: true,
    memberMessaging: true,
    apiAccess: true,
    pricePerMonth: 499.0,
    pricePerMember: 0.50,
    aiCallsPerMember: 200,
  );
}

class OrganizationMember {
  final String userId;
  final String orgId;
  final String role; // 'admin', 'trainer', 'member'
  final DateTime joinedAt;
  final bool isActive;
  final String? assignedTrainerId;
  final String? memberNote;
  final String displayName;
  final int workoutsThisWeek;
  final int currentStreak;
  final DateTime lastActiveAt;
  final String? assignedProgramId;

  const OrganizationMember({
    required this.userId,
    required this.orgId,
    required this.role,
    required this.joinedAt,
    required this.isActive,
    this.assignedTrainerId,
    this.memberNote,
    required this.displayName,
    this.workoutsThisWeek = 0,
    this.currentStreak = 0,
    required this.lastActiveAt,
    this.assignedProgramId,
  });

  OrganizationMember copyWith({
    String? userId,
    String? orgId,
    String? role,
    DateTime? joinedAt,
    bool? isActive,
    String? assignedTrainerId,
    String? memberNote,
    String? displayName,
    int? workoutsThisWeek,
    int? currentStreak,
    DateTime? lastActiveAt,
    String? assignedProgramId,
  }) {
    return OrganizationMember(
      userId: userId ?? this.userId,
      orgId: orgId ?? this.orgId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
      memberNote: memberNote ?? this.memberNote,
      displayName: displayName ?? this.displayName,
      workoutsThisWeek: workoutsThisWeek ?? this.workoutsThisWeek,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      assignedProgramId: assignedProgramId ?? this.assignedProgramId,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'orgId': orgId,
        'role': role,
        'joinedAt': joinedAt.toIso8601String(),
        'isActive': isActive,
        'assignedTrainerId': assignedTrainerId,
        'memberNote': memberNote,
        'displayName': displayName,
        'workoutsThisWeek': workoutsThisWeek,
        'currentStreak': currentStreak,
        'lastActiveAt': lastActiveAt.toIso8601String(),
        'assignedProgramId': assignedProgramId,
      };

  factory OrganizationMember.fromJson(Map<String, dynamic> json) =>
      OrganizationMember(
        userId: json['userId'] as String,
        orgId: json['orgId'] as String,
        role: json['role'] as String,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        isActive: json['isActive'] as bool,
        assignedTrainerId: json['assignedTrainerId'] as String?,
        memberNote: json['memberNote'] as String?,
        displayName: json['displayName'] as String,
        workoutsThisWeek: json['workoutsThisWeek'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
        assignedProgramId: json['assignedProgramId'] as String?,
      );
}

class TrainerProfile {
  final String userId;
  final String orgId;
  final String name;
  final String? bio;
  final String? photoUrl;
  final List<String> certifications;
  final List<String> specialties;
  final int clientCount;
  final double rating;
  final int reviewCount;

  const TrainerProfile({
    required this.userId,
    required this.orgId,
    required this.name,
    this.bio,
    this.photoUrl,
    required this.certifications,
    required this.specialties,
    required this.clientCount,
    required this.rating,
    required this.reviewCount,
  });

  TrainerProfile copyWith({
    String? userId,
    String? orgId,
    String? name,
    String? bio,
    String? photoUrl,
    List<String>? certifications,
    List<String>? specialties,
    int? clientCount,
    double? rating,
    int? reviewCount,
  }) {
    return TrainerProfile(
      userId: userId ?? this.userId,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      certifications: certifications ?? this.certifications,
      specialties: specialties ?? this.specialties,
      clientCount: clientCount ?? this.clientCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'orgId': orgId,
        'name': name,
        'bio': bio,
        'photoUrl': photoUrl,
        'certifications': certifications,
        'specialties': specialties,
        'clientCount': clientCount,
        'rating': rating,
        'reviewCount': reviewCount,
      };

  factory TrainerProfile.fromJson(Map<String, dynamic> json) => TrainerProfile(
        userId: json['userId'] as String,
        orgId: json['orgId'] as String,
        name: json['name'] as String,
        bio: json['bio'] as String?,
        photoUrl: json['photoUrl'] as String?,
        certifications: List<String>.from(json['certifications'] as List),
        specialties: List<String>.from(json['specialties'] as List),
        clientCount: json['clientCount'] as int,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
      );
}

class OrganizationProgram {
  final String id;
  final String orgId;
  final String createdBy;
  final String name;
  final String description;
  final String difficulty;
  final int durationWeeks;
  final List<String> targetGoals;
  final List<ProgramWeek> weeks;
  final bool isPublished;
  final int enrolledCount;
  final DateTime createdAt;

  const OrganizationProgram({
    required this.id,
    required this.orgId,
    required this.createdBy,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.durationWeeks,
    required this.targetGoals,
    required this.weeks,
    required this.isPublished,
    required this.enrolledCount,
    required this.createdAt,
  });

  OrganizationProgram copyWith({
    String? id,
    String? orgId,
    String? createdBy,
    String? name,
    String? description,
    String? difficulty,
    int? durationWeeks,
    List<String>? targetGoals,
    List<ProgramWeek>? weeks,
    bool? isPublished,
    int? enrolledCount,
    DateTime? createdAt,
  }) {
    return OrganizationProgram(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      targetGoals: targetGoals ?? this.targetGoals,
      weeks: weeks ?? this.weeks,
      isPublished: isPublished ?? this.isPublished,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orgId': orgId,
        'createdBy': createdBy,
        'name': name,
        'description': description,
        'difficulty': difficulty,
        'durationWeeks': durationWeeks,
        'targetGoals': targetGoals,
        'weeks': weeks.map((w) => w.toJson()).toList(),
        'isPublished': isPublished,
        'enrolledCount': enrolledCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OrganizationProgram.fromJson(Map<String, dynamic> json) =>
      OrganizationProgram(
        id: json['id'] as String,
        orgId: json['orgId'] as String,
        createdBy: json['createdBy'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        difficulty: json['difficulty'] as String,
        durationWeeks: json['durationWeeks'] as int,
        targetGoals: List<String>.from(json['targetGoals'] as List),
        weeks: (json['weeks'] as List)
            .map((w) => ProgramWeek.fromJson(w as Map<String, dynamic>))
            .toList(),
        isPublished: json['isPublished'] as bool,
        enrolledCount: json['enrolledCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ProgramWeek {
  final int weekNumber;
  final String focus;
  final List<ProgramDay> days;

  const ProgramWeek({
    required this.weekNumber,
    required this.focus,
    required this.days,
  });

  ProgramWeek copyWith({
    int? weekNumber,
    String? focus,
    List<ProgramDay>? days,
  }) {
    return ProgramWeek(
      weekNumber: weekNumber ?? this.weekNumber,
      focus: focus ?? this.focus,
      days: days ?? this.days,
    );
  }

  Map<String, dynamic> toJson() => {
        'weekNumber': weekNumber,
        'focus': focus,
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory ProgramWeek.fromJson(Map<String, dynamic> json) => ProgramWeek(
        weekNumber: json['weekNumber'] as int,
        focus: json['focus'] as String,
        days: (json['days'] as List)
            .map((d) => ProgramDay.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}

class ProgramDay {
  final int dayNumber;
  final String? templateId;
  final String? templateName;
  final String? notes;
  final bool isRestDay;

  const ProgramDay({
    required this.dayNumber,
    this.templateId,
    this.templateName,
    this.notes,
    this.isRestDay = false,
  });

  ProgramDay copyWith({
    int? dayNumber,
    String? templateId,
    String? templateName,
    String? notes,
    bool? isRestDay,
  }) {
    return ProgramDay(
      dayNumber: dayNumber ?? this.dayNumber,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      notes: notes ?? this.notes,
      isRestDay: isRestDay ?? this.isRestDay,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'templateId': templateId,
        'templateName': templateName,
        'notes': notes,
        'isRestDay': isRestDay,
      };

  factory ProgramDay.fromJson(Map<String, dynamic> json) => ProgramDay(
        dayNumber: json['dayNumber'] as int,
        templateId: json['templateId'] as String?,
        templateName: json['templateName'] as String?,
        notes: json['notes'] as String?,
        isRestDay: json['isRestDay'] as bool? ?? false,
      );
}

class OrganizationAnalytics {
  final int totalMembers;
  final int activeMembers;
  final double avgWorkoutsPerWeek;
  final double avgCompletionRate;
  final int totalWorkoutsThisMonth;
  final double totalVolumeThisMonth;
  final List<MemberActivity> topMembers;
  final Map<String, int> workoutsByDay;
  final double retentionRate;
  final int newMembersThisMonth;

  const OrganizationAnalytics({
    required this.totalMembers,
    required this.activeMembers,
    required this.avgWorkoutsPerWeek,
    required this.avgCompletionRate,
    required this.totalWorkoutsThisMonth,
    required this.totalVolumeThisMonth,
    required this.topMembers,
    required this.workoutsByDay,
    required this.retentionRate,
    required this.newMembersThisMonth,
  });

  OrganizationAnalytics copyWith({
    int? totalMembers,
    int? activeMembers,
    double? avgWorkoutsPerWeek,
    double? avgCompletionRate,
    int? totalWorkoutsThisMonth,
    double? totalVolumeThisMonth,
    List<MemberActivity>? topMembers,
    Map<String, int>? workoutsByDay,
    double? retentionRate,
    int? newMembersThisMonth,
  }) {
    return OrganizationAnalytics(
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      avgWorkoutsPerWeek: avgWorkoutsPerWeek ?? this.avgWorkoutsPerWeek,
      avgCompletionRate: avgCompletionRate ?? this.avgCompletionRate,
      totalWorkoutsThisMonth:
          totalWorkoutsThisMonth ?? this.totalWorkoutsThisMonth,
      totalVolumeThisMonth: totalVolumeThisMonth ?? this.totalVolumeThisMonth,
      topMembers: topMembers ?? this.topMembers,
      workoutsByDay: workoutsByDay ?? this.workoutsByDay,
      retentionRate: retentionRate ?? this.retentionRate,
      newMembersThisMonth: newMembersThisMonth ?? this.newMembersThisMonth,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalMembers': totalMembers,
        'activeMembers': activeMembers,
        'avgWorkoutsPerWeek': avgWorkoutsPerWeek,
        'avgCompletionRate': avgCompletionRate,
        'totalWorkoutsThisMonth': totalWorkoutsThisMonth,
        'totalVolumeThisMonth': totalVolumeThisMonth,
        'topMembers': topMembers.map((m) => m.toJson()).toList(),
        'workoutsByDay': workoutsByDay,
        'retentionRate': retentionRate,
        'newMembersThisMonth': newMembersThisMonth,
      };

  factory OrganizationAnalytics.fromJson(Map<String, dynamic> json) =>
      OrganizationAnalytics(
        totalMembers: json['totalMembers'] as int,
        activeMembers: json['activeMembers'] as int,
        avgWorkoutsPerWeek: (json['avgWorkoutsPerWeek'] as num).toDouble(),
        avgCompletionRate: (json['avgCompletionRate'] as num).toDouble(),
        totalWorkoutsThisMonth: json['totalWorkoutsThisMonth'] as int,
        totalVolumeThisMonth:
            (json['totalVolumeThisMonth'] as num).toDouble(),
        topMembers: (json['topMembers'] as List)
            .map((m) => MemberActivity.fromJson(m as Map<String, dynamic>))
            .toList(),
        workoutsByDay: Map<String, int>.from(json['workoutsByDay'] as Map),
        retentionRate: (json['retentionRate'] as num).toDouble(),
        newMembersThisMonth: json['newMembersThisMonth'] as int,
      );
}

class MemberActivity {
  final String userId;
  final String name;
  final int workoutsThisWeek;
  final double volumeThisWeek;
  final int currentStreak;

  const MemberActivity({
    required this.userId,
    required this.name,
    required this.workoutsThisWeek,
    required this.volumeThisWeek,
    required this.currentStreak,
  });

  MemberActivity copyWith({
    String? userId,
    String? name,
    int? workoutsThisWeek,
    double? volumeThisWeek,
    int? currentStreak,
  }) {
    return MemberActivity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      workoutsThisWeek: workoutsThisWeek ?? this.workoutsThisWeek,
      volumeThisWeek: volumeThisWeek ?? this.volumeThisWeek,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'workoutsThisWeek': workoutsThisWeek,
        'volumeThisWeek': volumeThisWeek,
        'currentStreak': currentStreak,
      };

  factory MemberActivity.fromJson(Map<String, dynamic> json) =>
      MemberActivity(
        userId: json['userId'] as String,
        name: json['name'] as String,
        workoutsThisWeek: json['workoutsThisWeek'] as int,
        volumeThisWeek: (json['volumeThisWeek'] as num).toDouble(),
        currentStreak: json['currentStreak'] as int,
      );
}

class OrganizationSettings {
  final bool requireWorkoutApproval;
  final bool allowMemberSocial;
  final bool showLeaderboard;
  final List<String> requiredPrograms;
  final String? defaultProgramId;
  final Map<String, String> customLabels;

  const OrganizationSettings({
    this.requireWorkoutApproval = false,
    this.allowMemberSocial = true,
    this.showLeaderboard = true,
    this.requiredPrograms = const [],
    this.defaultProgramId,
    this.customLabels = const {},
  });

  OrganizationSettings copyWith({
    bool? requireWorkoutApproval,
    bool? allowMemberSocial,
    bool? showLeaderboard,
    List<String>? requiredPrograms,
    String? defaultProgramId,
    Map<String, String>? customLabels,
  }) {
    return OrganizationSettings(
      requireWorkoutApproval:
          requireWorkoutApproval ?? this.requireWorkoutApproval,
      allowMemberSocial: allowMemberSocial ?? this.allowMemberSocial,
      showLeaderboard: showLeaderboard ?? this.showLeaderboard,
      requiredPrograms: requiredPrograms ?? this.requiredPrograms,
      defaultProgramId: defaultProgramId ?? this.defaultProgramId,
      customLabels: customLabels ?? this.customLabels,
    );
  }

  Map<String, dynamic> toJson() => {
        'requireWorkoutApproval': requireWorkoutApproval,
        'allowMemberSocial': allowMemberSocial,
        'showLeaderboard': showLeaderboard,
        'requiredPrograms': requiredPrograms,
        'defaultProgramId': defaultProgramId,
        'customLabels': customLabels,
      };

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) =>
      OrganizationSettings(
        requireWorkoutApproval:
            json['requireWorkoutApproval'] as bool? ?? false,
        allowMemberSocial: json['allowMemberSocial'] as bool? ?? true,
        showLeaderboard: json['showLeaderboard'] as bool? ?? true,
        requiredPrograms:
            List<String>.from(json['requiredPrograms'] as List? ?? []),
        defaultProgramId: json['defaultProgramId'] as String?,
        customLabels:
            Map<String, String>.from(json['customLabels'] as Map? ?? {}),
      );
}

class RecentActivityItem {
  final String userId;
  final String userName;
  final String action; // 'completed_workout', 'new_pr', 'joined', 'streak'
  final String description;
  final DateTime timestamp;

  const RecentActivityItem({
    required this.userId,
    required this.userName,
    required this.action,
    required this.description,
    required this.timestamp,
  });
}
