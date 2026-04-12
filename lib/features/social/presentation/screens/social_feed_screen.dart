import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/social_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/social_models.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../../../../services/ad_service.dart';

class SocialFeedScreen extends ConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(socialFeedProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (user != null) {
            final createPost = ref.read(createPostProvider);
            createPost(
              userId: user.id,
              userName: user.displayName,
              type: 'photo',
              content: 'Great workout today!',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post shared!')),
            );
          }
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.share_outlined, color: Colors.white),
      ),
      body: posts.isEmpty
          ? const Center(child: Text('No posts yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.padding2XL),
              separatorBuilder: (_, idx) {
                // Show native ad after every 2nd post
                if ((idx + 1) % 2 == 0) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child:
                        AdBannerWidget(placement: AdPlacement.nativeFeed),
                  );
                }
                return const SizedBox(height: 12);
              },
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _PostCard(
                  post: post,
                  onLike: () {
                    if (user != null) {
                      final toggleLike = ref.read(toggleLikeProvider);
                      toggleLike(post.id, user.id);
                    }
                  },
                );
              },
            ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final SocialPost post;
  final VoidCallback onLike;

  const _PostCard({required this.post, required this.onLike});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final initial = post.userName.isNotEmpty ? post.userName[0] : '?';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Text(
                  initial,
                  style: AppTypography.button.copyWith(color: AppColors.accent),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName,
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(_timeAgo(post.createdAt),
                        style: AppTypography.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: AppColors.text3, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          if (post.content != null)
            Text(post.content!, style: AppTypography.body),
          if (post.stats.duration != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    '${post.stats.duration} min  |  ${post.stats.volume?.toStringAsFixed(0) ?? '0'} lbs  |  ${post.stats.exercises ?? 0} exercises',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ],
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined,
                        size: 40, color: AppColors.text3),
                    const SizedBox(height: 4),
                    Text('Workout Photo',
                        style: AppTypography.caption),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likeCount}', style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 20, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: AppTypography.caption),
                ],
              ),
              const Spacer(),
              Icon(Icons.bookmark_border,
                  size: 20, color: AppColors.text3),
            ],
          ),
        ],
      ),
    );
  }
}
