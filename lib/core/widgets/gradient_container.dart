import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final bool isBorderOnly;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const GradientContainer({
    super.key,
    required this.child,
    this.isBorderOnly = false,
    this.borderRadius = AppDimensions.radiusCard,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isBorderOnly) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(borderRadius - 1.5),
          ),
          child: child,
        ),
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
