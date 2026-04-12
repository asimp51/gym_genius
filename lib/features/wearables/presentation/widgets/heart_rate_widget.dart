import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/health_models.dart';
import '../providers/wearable_providers.dart';

/// Circular heart rate display with pulsing animation and zone indicator.
/// Designed to be embedded inside the active workout screen.
class HeartRateWidget extends ConsumerStatefulWidget {
  /// If true, shows a compact inline version. Otherwise full circle.
  final bool compact;

  /// User age for heart rate zone calculation. Defaults to 30.
  final int userAge;

  const HeartRateWidget({
    super.key,
    this.compact = false,
    this.userAge = 30,
  });

  @override
  ConsumerState<HeartRateWidget> createState() => _HeartRateWidgetState();
}

class _HeartRateWidgetState extends ConsumerState<HeartRateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _zoneColor(HeartRateZoneType zone) {
    switch (zone) {
      case HeartRateZoneType.rest:
        return AppColors.text3;
      case HeartRateZoneType.warmup:
        return AppColors.success;
      case HeartRateZoneType.fatBurn:
        return AppColors.accentSecondary;
      case HeartRateZoneType.cardio:
        return AppColors.warning;
      case HeartRateZoneType.peak:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final heartRateAsync = ref.watch(heartRateStreamProvider);

    return heartRateAsync.when(
      data: (bpm) => _buildWidget(bpm),
      loading: () => _buildWidget(null),
      error: (_, __) => _buildWidget(null),
    );
  }

  Widget _buildWidget(int? bpm) {
    if (widget.compact) {
      return _buildCompact(bpm);
    }
    return _buildFull(bpm);
  }

  Widget _buildCompact(int? bpm) {
    final zone = bpm != null
        ? HeartRateZone.currentZone(bpm, widget.userAge)
        : null;
    final color = zone != null ? _zoneColor(zone.zone) : AppColors.text3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bpm != null)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              ),
              child: Icon(Icons.favorite, size: 14, color: color),
            )
          else
            Icon(Icons.favorite_border, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            bpm != null ? '$bpm' : '--',
            style: AppTypography.stat.copyWith(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            'BPM',
            style: AppTypography.caption.copyWith(
              fontSize: 9,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(int? bpm) {
    final zone = bpm != null
        ? HeartRateZone.currentZone(bpm, widget.userAge)
        : null;
    final color = zone != null ? _zoneColor(zone.zone) : AppColors.text3;
    final maxHr = 220 - widget.userAge;
    final progress = bpm != null ? (bpm / maxHr).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring.
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _HeartRateRingPainter(
                    progress: progress,
                    color: color,
                    backgroundColor: AppColors.bgTertiary,
                  ),
                ),
              ),
              // Pulsing heart and BPM.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bpm != null)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      ),
                      child: Icon(Icons.favorite, size: 24, color: color),
                    )
                  else
                    Icon(Icons.favorite_border,
                        size: 24, color: AppColors.text3),
                  const SizedBox(height: 2),
                  Text(
                    bpm != null ? '$bpm' : '--',
                    style: AppTypography.statLarge.copyWith(
                      color: color,
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    'BPM',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Zone label.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          child: Text(
            zone?.label ?? 'No Signal',
            style: AppTypography.caption.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter that draws a circular progress ring for heart rate.
class _HeartRateRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _HeartRateRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    // Background ring.
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc.
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start at top.
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeartRateRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
