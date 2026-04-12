import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../config/theme/app_dimensions.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final double? delta;
  final bool showDelta;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.showDelta = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = (delta ?? 0) >= 0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.stat),
          if (showDelta && delta != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 2),
                Text(
                  '${isPositive ? '+' : ''}${delta!.toStringAsFixed(1)}%',
                  style: AppTypography.caption.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
