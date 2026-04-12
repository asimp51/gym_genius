import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ad_service.dart';

class AdBannerWidget extends ConsumerWidget {
  final AdPlacement placement;

  const AdBannerWidget({super.key, required this.placement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAds = ref.watch(showAdsProvider);
    if (!showAds) return const SizedBox.shrink();

    return ref.watch(adServiceProvider).getBannerAd(placement);
  }
}
