import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/driver.dart';
import 'vybe_widgets.dart';

class DriverInfoCard extends StatelessWidget {
  final Driver driver;
  final String statusText;
  final VoidCallback? onCallPressed;

  const DriverInfoCard({
    super.key,
    required this.driver,
    required this.statusText,
    this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return VybeCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.navigation_outlined,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: isDark ? AppColors.primary : AppColors.uberBlack,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.starGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.starGold,
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      driver.rating.toString(),
                      style: const TextStyle(
                        color: AppColors.starGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isDark
                    ? AppColors.primary
                    : AppColors.uberBlack,
                child: Text(
                  driver.name.substring(0, 1),
                  style: TextStyle(
                    color: isDark ? AppColors.uberBlack : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${driver.carModel} · ${driver.carColor}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDarkElevated
                            : AppColors.cardLightElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        driver.carNumber,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.primary
                              : AppColors.uberBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: onCallPressed,
                style: IconButton.styleFrom(backgroundColor: AppColors.success),
                icon: const Icon(Icons.phone, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
