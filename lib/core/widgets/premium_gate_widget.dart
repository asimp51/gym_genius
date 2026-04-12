import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../config/theme/app_dimensions.dart';
import '../../services/ad_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class PremiumGateWidget extends ConsumerWidget {
  final Widget child;
  final String featureName;
  final bool allowRewardedAd;

  const PremiumGateWidget({
    super.key,
    required this.child,
    required this.featureName,
    this.allowRewardedAd = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = user?.subscription.tier == 'premium';

    if (isPremium) return child;

    return Stack(
      children: [
        Opacity(opacity: 0.3, child: IgnorePointer(child: child)),
        Positioned.fill(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded,
                      color: AppColors.accent, size: 48),
                  const SizedBox(height: 12),
                  Text('$featureName is Premium',
                      style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text('Upgrade to unlock this feature',
                      style: AppTypography.caption),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/subscription'),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton),
                          child: Center(
                            child: Text(
                              'Upgrade to Premium',
                              style: AppTypography.button
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (allowRewardedAd) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final adService = ref.read(adServiceProvider);
                        await adService.showRewardedAd();
                        // Grant temporary access handled by caller
                      },
                      child: Text(
                        'Watch Ad to Unlock',
                        style: AppTypography.button
                            .copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
