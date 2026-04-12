import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../config/theme/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool isFullWidth;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final enabled = !isDisabled && !isLoading;

    if (variant == AppButtonVariant.ghost) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: TextButton(
          onPressed: enabled ? onPressed : null,
          child: _buildChild(AppColors.accent),
        ),
      );
    }

    if (variant == AppButtonVariant.secondary) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: 50,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
          ),
          child: _buildChild(AppColors.text1),
        ),
      );
    }

    // Primary - gradient
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.gradient : null,
          color: enabled ? null : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            child: Center(child: _buildChild(Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.button.copyWith(color: color)),
        ],
      );
    }

    return Text(label, style: AppTypography.button.copyWith(color: color));
  }
}
