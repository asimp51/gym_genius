import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/b2b_repository.dart';
import '../../domain/b2b_models.dart';

final currentOrganizationProvider = FutureProvider<Organization?>((ref) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getCurrentOrganization();
});

final orgMembersProvider =
    FutureProvider.family<List<OrganizationMember>, String>(
        (ref, orgId) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getMembers(orgId);
});

final orgTrainersProvider =
    FutureProvider.family<List<TrainerProfile>, String>((ref, orgId) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getTrainers(orgId);
});

final orgProgramsProvider =
    FutureProvider.family<List<OrganizationProgram>, String>(
        (ref, orgId) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getPrograms(orgId);
});

final orgAnalyticsProvider =
    FutureProvider.family<OrganizationAnalytics, String>((ref, orgId) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getAnalytics(orgId);
});

final memberByIdProvider =
    FutureProvider.family<OrganizationMember?, ({String orgId, String userId})>(
        (ref, params) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getMemberById(params.orgId, params.userId);
});

final isB2BUserProvider = Provider<bool>((ref) {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.isB2BUser;
});

final currentB2BRoleProvider = Provider<String?>((ref) {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.currentUserRole;
});

final orgBrandingProvider =
    FutureProvider<OrganizationBranding?>((ref) async {
  final org = await ref.watch(currentOrganizationProvider.future);
  return org?.branding;
});

final trainerClientsProvider =
    FutureProvider.family<List<OrganizationMember>, String>(
        (ref, trainerId) async {
  final repo = ref.watch(b2bRepositoryProvider);
  final orgId = repo.currentOrgId;
  if (orgId == null) return [];
  return repo.getTrainerClients(orgId, trainerId);
});

final programByIdProvider = FutureProvider.family<OrganizationProgram?,
    ({String orgId, String programId})>((ref, params) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getProgramById(params.orgId, params.programId);
});

final memberActivityProvider =
    FutureProvider.family<List<MemberActivity>, String>((ref, orgId) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getMemberActivities(orgId);
});

final recentActivityProvider =
    FutureProvider.family<List<RecentActivityItem>, String>(
        (ref, orgId) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getRecentActivity(orgId);
});

final orgAccessCodeProvider =
    FutureProvider<String?>((ref) async {
  final org = await ref.watch(currentOrganizationProvider.future);
  return org?.accessCode;
});
