import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/social_repository.dart';
import '../../domain/social_models.dart';

// Social feed
final socialFeedProvider = Provider<List<SocialPost>>((ref) {
  return ref.watch(socialRepositoryProvider).getFeed();
});

// Selected leaderboard type
final leaderboardTypeProvider = StateProvider<String>((ref) => 'volume');

// Leaderboard data
final leaderboardProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final type = ref.watch(leaderboardTypeProvider);
  return ref.watch(socialRepositoryProvider).getLeaderboard(type);
});

// Comments for a post
final commentsProvider = Provider.family<List<Comment>, String>((ref, postId) {
  return ref.watch(socialRepositoryProvider).getComments(postId);
});

// Create post action
final createPostProvider = Provider<Function>((ref) {
  final repo = ref.watch(socialRepositoryProvider);
  return ({
    required String userId,
    required String userName,
    required String type,
    String? content,
    PostStats? stats,
  }) {
    repo.createPost(
      userId: userId,
      userName: userName,
      type: type,
      content: content,
      stats: stats,
    );
  };
});

// Toggle like action
final toggleLikeProvider = Provider<Function>((ref) {
  final repo = ref.watch(socialRepositoryProvider);
  return (String postId, String userId) {
    repo.toggleLike(postId, userId);
  };
});
