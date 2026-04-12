import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../services/ad_service.dart';
import '../../../../services/ai_usage_service.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
  }

  void _ensureGreeting(String userName) {
    if (_messages.isEmpty) {
      _messages.add(_ChatMessage(
        text:
            "Hey $userName! I'm your GymGenius AI trainer. I've analyzed your recent workouts and I'm ready to help you optimize your training. What can I help you with today?",
        isUser: false,
      ));
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    final tier = user?.subscription.tier ?? 'free';
    final aiUsage = ref.read(aiUsageServiceProvider);

    // Check AI usage limit before sending
    if (!aiUsage.canUseAi(tier)) {
      _showUsageLimitDialog(tier);
      return;
    }

    // Record the usage
    aiUsage.recordUsage();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text:
                "That's a great question! Based on your training history and goals, I'd recommend focusing on progressive overload this week. Try adding 5 lbs to your working sets and see how it feels.",
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    });

    _scrollToBottom();
  }

  void _showUsageLimitDialog(String tier) {
    final aiUsage = ref.read(aiUsageServiceProvider);
    final daysLeft = aiUsage.daysUntilReset;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text("You've used all your AI credits this month",
            style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve used all ${aiUsage.getLimit(tier)} AI credits for this month. '
              'Credits reset in $daysLeft days.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            if (tier == 'free')
              Text(
                'Upgrade to Premium for 100 AI credits/month with Pro quality!',
                style: AppTypography.caption
                    .copyWith(color: AppColors.accent),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final adService = ref.read(adServiceProvider);
              final watched = await adService.showRewardedAd();
              if (watched) {
                ref.read(aiUsageServiceProvider).grantBonusUsage(1);
                if (mounted) setState(() {});
              }
            },
            child: Text('Watch Ad for 1 Free Credit',
                style: AppTypography.button
                    .copyWith(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/subscription');
            },
            child: Text('Upgrade to Premium',
                style: AppTypography.button
                    .copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.displayName.split(' ').first ?? 'there';
    final tier = user?.subscription.tier ?? 'free';
    final aiUsage = ref.watch(aiUsageServiceProvider);
    final used = aiUsage.usageCount;
    final limit = aiUsage.getLimit(tier);
    final remaining = aiUsage.remaining(tier);

    _ensureGreeting(userName);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child:
                    Text('\ud83e\udd16', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('GymGenius AI'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // AI Credits bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLG, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt,
                    size: 16,
                    color: remaining > 0
                        ? AppColors.accent
                        : AppColors.error),
                const SizedBox(width: 6),
                Text(
                  'AI Credits: $used/$limit used this month',
                  style: AppTypography.caption.copyWith(
                    color: remaining > 0
                        ? AppColors.text2
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$remaining remaining',
                  style: AppTypography.caption.copyWith(
                    color: remaining > 0
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.all(AppDimensions.padding2XL),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.paddingLG,
              AppDimensions.paddingSM,
              AppDimensions.paddingSM,
              MediaQuery.paddingOf(context).bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Ask your AI trainer...',
                      filled: true,
                      fillColor: AppColors.bgTertiary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusPill),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('\ud83e\udd16',
                    style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.accent
                    : AppColors.bgTertiary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(message.isUser ? 16 : 4),
                  bottomRight:
                      Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: AppTypography.body.copyWith(
                  color: message.isUser
                      ? Colors.white
                      : AppColors.text1,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
