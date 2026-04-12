import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

// Revenue streams for GymGenius:
// 1. Premium subscription: $9.99/mo or $59.99/yr
// 2. Banner ads (free tier): ~$1-3 CPM
// 3. Interstitial ads (every 3rd workout): ~$5-15 CPM
// 4. Rewarded ads (unlock AI/premium features): ~$10-30 CPM
// 5. Native ads (in feed/exercise list): ~$3-8 CPM
// 6. B2B subscriptions: $49-499/mo per organization
// 7. Affiliate commissions: grocery delivery, supplement brands

/// Ad placement types in the app
enum AdPlacement {
  homeBanner, // Bottom of home screen
  exerciseListBanner, // Between exercise cards
  workoutSummaryBanner, // After workout completion
  progressBanner, // On progress dashboard
  recipeBanner, // In recipe library
  interstitialWorkout, // Full screen after every 3rd workout
  interstitialFeature, // When tapping premium feature
  rewardedAi, // Watch ad for free AI generation
  rewardedRecipe, // Watch ad to unlock premium recipe
  nativeExercise, // Native ad between exercises
  nativeFeed, // Native ad in social feed
}

class AdService {
  bool _adsEnabled = true;
  int _workoutCount = 0;

  /// Check if ads should be shown (only for free tier)
  bool shouldShowAd(String subscriptionTier) {
    return subscriptionTier == 'free' && _adsEnabled;
  }

  /// Track workout completion for interstitial frequency
  void onWorkoutCompleted() {
    _workoutCount++;
  }

  /// Should show interstitial ad? (every 3rd workout)
  bool shouldShowInterstitial() {
    return _workoutCount > 0 && _workoutCount % 3 == 0;
  }

  /// Show banner ad placeholder widget
  Widget getBannerAd(AdPlacement placement) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2636),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: const Center(
        child: Text(
          'Ad Space \u2014 Google AdMob',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ),
    );
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    // Will be replaced with real AdMob interstitial
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Show rewarded ad (returns true if watched completely)
  Future<bool> showRewardedAd() async {
    // Will be replaced with real AdMob rewarded
    await Future.delayed(const Duration(seconds: 2));
    return true; // simulated: user watched the ad
  }

  /// Disable ads (called when user subscribes to premium)
  void disableAds() {
    _adsEnabled = false;
  }

  /// Re-enable ads (called when subscription expires)
  void enableAds() {
    _adsEnabled = true;
  }
}

final adServiceProvider = Provider<AdService>((ref) => AdService());

/// Whether to show ads based on user subscription
final showAdsProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final adService = ref.watch(adServiceProvider);
  if (user == null) return false;
  return adService.shouldShowAd(user.subscription.tier);
});
