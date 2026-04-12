import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/social_models.dart';

class SocialRepository {
  final List<SocialPost> _posts = [];
  final Map<String, List<Comment>> _comments = {};
  final Set<String> _likedPostIds = {};

  SocialRepository() {
    _seedMockData();
  }

  List<SocialPost> getFeed() {
    return List.from(_posts)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  SocialPost? getPostById(String postId) {
    try {
      return _posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      return null;
    }
  }

  SocialPost createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String type,
    String? workoutId,
    String? content,
    PostStats? stats,
    String? imageUrl,
  }) {
    final post = SocialPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: type,
      workoutId: workoutId,
      content: content,
      stats: stats ?? const PostStats(),
      imageUrl: imageUrl,
      likeCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
      isLikedByMe: false,
    );
    _posts.insert(0, post);
    return post;
  }

  void toggleLike(String postId, String userId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final key = '${userId}_$postId';

    if (_likedPostIds.contains(key)) {
      _likedPostIds.remove(key);
      _posts[index] = post.copyWith(
        likeCount: post.likeCount - 1,
        isLikedByMe: false,
      );
    } else {
      _likedPostIds.add(key);
      _posts[index] = post.copyWith(
        likeCount: post.likeCount + 1,
        isLikedByMe: true,
      );
    }
  }

  Comment addComment(String postId, String userId, String userName, String text) {
    final comment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      text: text,
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(postId, () => []);
    _comments[postId]!.add(comment);

    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        commentCount: _posts[index].commentCount + 1,
      );
    }

    return comment;
  }

  List<Comment> getComments(String postId) {
    return _comments[postId] ?? [];
  }

  List<Map<String, dynamic>> getLeaderboard(String type) {
    switch (type) {
      case 'volume':
        return [
          {'rank': 1, 'name': 'Mike T.', 'value': '52,400 kg', 'avatar': 'M'},
          {'rank': 2, 'name': 'Sarah K.', 'value': '48,200 kg', 'avatar': 'S'},
          {'rank': 3, 'name': 'David R.', 'value': '45,100 kg', 'avatar': 'D'},
          {'rank': 4, 'name': 'Alex J.', 'value': '42,800 kg', 'avatar': 'A', 'isCurrentUser': true},
          {'rank': 5, 'name': 'Emma L.', 'value': '39,500 kg', 'avatar': 'E'},
          {'rank': 6, 'name': 'Chris P.', 'value': '37,200 kg', 'avatar': 'C'},
          {'rank': 7, 'name': 'Olivia W.', 'value': '35,800 kg', 'avatar': 'O'},
          {'rank': 8, 'name': 'James H.', 'value': '33,400 kg', 'avatar': 'J'},
          {'rank': 9, 'name': 'Sophia M.', 'value': '31,200 kg', 'avatar': 'S'},
          {'rank': 10, 'name': 'Liam B.', 'value': '29,100 kg', 'avatar': 'L'},
        ];
      case 'streaks':
        return [
          {'rank': 1, 'name': 'Sarah K.', 'value': '45 days', 'avatar': 'S'},
          {'rank': 2, 'name': 'James H.', 'value': '38 days', 'avatar': 'J'},
          {'rank': 3, 'name': 'Emma L.', 'value': '30 days', 'avatar': 'E'},
          {'rank': 4, 'name': 'Alex J.', 'value': '12 days', 'avatar': 'A', 'isCurrentUser': true},
          {'rank': 5, 'name': 'Mike T.', 'value': '10 days', 'avatar': 'M'},
          {'rank': 6, 'name': 'Olivia W.', 'value': '8 days', 'avatar': 'O'},
          {'rank': 7, 'name': 'Chris P.', 'value': '7 days', 'avatar': 'C'},
          {'rank': 8, 'name': 'Liam B.', 'value': '5 days', 'avatar': 'L'},
          {'rank': 9, 'name': 'David R.', 'value': '4 days', 'avatar': 'D'},
          {'rank': 10, 'name': 'Sophia M.', 'value': '3 days', 'avatar': 'S'},
        ];
      case 'xp':
      default:
        return [
          {'rank': 1, 'name': 'Mike T.', 'value': '12,450 XP', 'avatar': 'M'},
          {'rank': 2, 'name': 'Sarah K.', 'value': '10,200 XP', 'avatar': 'S'},
          {'rank': 3, 'name': 'David R.', 'value': '8,800 XP', 'avatar': 'D'},
          {'rank': 4, 'name': 'Alex J.', 'value': '2,450 XP', 'avatar': 'A', 'isCurrentUser': true},
          {'rank': 5, 'name': 'Emma L.', 'value': '2,100 XP', 'avatar': 'E'},
          {'rank': 6, 'name': 'Chris P.', 'value': '1,800 XP', 'avatar': 'C'},
          {'rank': 7, 'name': 'Olivia W.', 'value': '1,500 XP', 'avatar': 'O'},
          {'rank': 8, 'name': 'James H.', 'value': '1,200 XP', 'avatar': 'J'},
          {'rank': 9, 'name': 'Sophia M.', 'value': '900 XP', 'avatar': 'S'},
          {'rank': 10, 'name': 'Liam B.', 'value': '600 XP', 'avatar': 'L'},
        ];
    }
  }

  void _seedMockData() {
    final now = DateTime.now();
    _posts.addAll([
      SocialPost(
        id: 'post_1',
        userId: 'user_mike',
        userName: 'Mike T.',
        type: 'workout_summary',
        content: 'Crushed push day! New bench PR 🔥',
        stats: const PostStats(duration: 62, exercises: 6, volume: 9200, prs: 1),
        likeCount: 24,
        commentCount: 5,
        createdAt: now.subtract(const Duration(hours: 2)),
        isLikedByMe: false,
      ),
      SocialPost(
        id: 'post_2',
        userId: 'user_sarah',
        userName: 'Sarah K.',
        type: 'badge',
        content: '💪 Just earned the "100 Workouts" badge! What a journey!',
        likeCount: 48,
        commentCount: 12,
        createdAt: now.subtract(const Duration(hours: 8)),
        isLikedByMe: true,
      ),
      SocialPost(
        id: 'post_3',
        userId: 'user_david',
        userName: 'David R.',
        type: 'pr',
        content: 'New deadlift PR: 180kg! 🏆 Been chasing this for months.',
        stats: const PostStats(duration: 55, exercises: 5, volume: 8400, prs: 2),
        likeCount: 67,
        commentCount: 18,
        createdAt: now.subtract(const Duration(days: 1)),
        isLikedByMe: false,
      ),
      SocialPost(
        id: 'post_4',
        userId: 'user_emma',
        userName: 'Emma L.',
        type: 'streak',
        content: '🔥 30-day streak! Consistency is key.',
        likeCount: 35,
        commentCount: 7,
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        isLikedByMe: true,
      ),
      SocialPost(
        id: 'post_5',
        userId: 'user_chris',
        userName: 'Chris P.',
        type: 'workout_summary',
        content: 'Leg day never gets easier, you just get stronger 🦵',
        stats: const PostStats(duration: 70, exercises: 7, volume: 14200, prs: 0),
        likeCount: 19,
        commentCount: 3,
        createdAt: now.subtract(const Duration(days: 2)),
        isLikedByMe: false,
      ),
    ]);

    _comments['post_1'] = [
      Comment(id: 'c1', userId: 'user_sarah', userName: 'Sarah K.', text: 'Nice work! 💪', createdAt: now.subtract(const Duration(hours: 1))),
      Comment(id: 'c2', userId: 'user_david', userName: 'David R.', text: 'What weight did you hit?', createdAt: now.subtract(const Duration(minutes: 45))),
    ];
  }
}

final socialRepositoryProvider = Provider<SocialRepository>((ref) => SocialRepository());
