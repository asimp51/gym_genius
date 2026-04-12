import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI model quality tiers:
/// - Free users: Claude Haiku (fast, cheaper, still good) — 3 calls/month
/// - Premium users: Claude Sonnet (best quality) — 100 calls/month
/// - B2B Starter: 20 calls/member/month
/// - B2B Pro: 50 calls/member/month
/// - B2B Enterprise: 200 calls/member/month
enum AiModelTier {
  haiku,  // Free users
  sonnet, // Premium users
}

// Revenue streams for GymGenius:
// 1. Premium subscription: $9.99/mo or $79.99/yr
// 2. Banner ads (free tier): ~$1-3 CPM
// 3. Interstitial ads (every 3rd workout): ~$5-15 CPM
// 4. Rewarded ads (unlock AI/premium features): ~$10-30 CPM
// 5. Native ads (in feed/exercise list): ~$3-8 CPM
// 6. B2B subscriptions: $49-499/mo + per-member
// 7. Affiliate commissions: grocery delivery, supplement brands

class AiUsageService {
  int _monthlyUsageCount = 0;
  int _bonusCredits = 0;
  DateTime _resetDate = _nextResetDate();

  static DateTime _nextResetDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1);
  }

  void _checkReset() {
    if (DateTime.now().isAfter(_resetDate)) {
      _monthlyUsageCount = 0;
      _bonusCredits = 0;
      _resetDate = _nextResetDate();
    }
  }

  /// Current usage count this month
  int get usageCount {
    _checkReset();
    return _monthlyUsageCount;
  }

  /// Get limit based on subscription tier
  /// Everyone has a limit — no unlimited for anyone
  int getLimit(String tier) {
    switch (tier) {
      case 'premium':
        return 100; // 100 calls/month — generous but capped
      case 'free':
      default:
        return 3;   // 3 calls/month — enough to try
    }
  }

  /// Display-friendly limit text
  String getLimitDisplay(String tier) {
    return getLimit(tier).toString();
  }

  /// Remaining calls
  int remaining(String tier) {
    final effectiveLimit = getLimit(tier) + _bonusCredits;
    return (effectiveLimit - usageCount).clamp(0, effectiveLimit);
  }

  /// Check if user can make an AI call
  bool canUseAi(String tier) {
    _checkReset();
    final effectiveLimit = getLimit(tier) + _bonusCredits;
    return usageCount < effectiveLimit;
  }

  /// Get AI model tier based on subscription
  /// Free = Haiku (cheaper), Premium = Sonnet (best quality)
  AiModelTier getModelTier(String tier) {
    return tier == 'premium' ? AiModelTier.sonnet : AiModelTier.haiku;
  }

  /// Get model name for display
  String getModelName(String tier) {
    return tier == 'premium' ? 'GymGenius AI Pro' : 'GymGenius AI';
  }

  /// Record an AI usage
  void recordUsage() {
    _checkReset();
    _monthlyUsageCount++;
  }

  /// Days until reset
  int get daysUntilReset {
    return _resetDate.difference(DateTime.now()).inDays;
  }

  /// Grant bonus usage (from watching rewarded ad) — free users only
  void grantBonusUsage(int count) {
    _bonusCredits += count;
  }

  /// Usage percentage (0.0 to 1.0)
  double usagePercent(String tier) {
    final limit = getLimit(tier) + _bonusCredits;
    if (limit <= 0) return 1.0;
    return (usageCount / limit).clamp(0.0, 1.0);
  }

  /// Cost estimate per call (for internal tracking)
  double estimatedCostPerCall(String tier) {
    return tier == 'premium' ? 0.05 : 0.015;
  }
}

final aiUsageServiceProvider =
    Provider<AiUsageService>((ref) => AiUsageService());

// Convenience providers
final aiUsageCountProvider = Provider<int>((ref) {
  return ref.watch(aiUsageServiceProvider).usageCount;
});

final aiUsageLimitProvider = Provider.family<int, String>((ref, tier) {
  return ref.watch(aiUsageServiceProvider).getLimit(tier);
});

final aiRemainingProvider = Provider.family<int, String>((ref, tier) {
  return ref.watch(aiUsageServiceProvider).remaining(tier);
});

final canUseAiProvider = Provider.family<bool, String>((ref, tier) {
  return ref.watch(aiUsageServiceProvider).canUseAi(tier);
});

final aiModelTierProvider = Provider.family<AiModelTier, String>((ref, tier) {
  return ref.watch(aiUsageServiceProvider).getModelTier(tier);
});
