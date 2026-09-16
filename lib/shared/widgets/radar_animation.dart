import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RadarAnimation extends StatefulWidget {
  final double size;

  const RadarAnimation({super.key, this.size = 220});

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primary : AppColors.uberBlack;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _buildPulseRing(0.0, primaryColor),
              _buildPulseRing(0.33, primaryColor),
              _buildPulseRing(0.66, primaryColor),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: isDark ? AppColors.uberBlack : Colors.white,
                  size: 38,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPulseRing(double delayFraction, Color color) {
    final progress = (_controller.value + delayFraction) % 1.0;
    final size = widget.size * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity * 0.8),
          width: 2,
        ),
        color: color.withValues(alpha: opacity * 0.1),
      ),
    );
  }
}
