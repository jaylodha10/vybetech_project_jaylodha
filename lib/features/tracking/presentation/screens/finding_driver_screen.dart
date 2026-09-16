import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/driver_info_card.dart';
import '../../../../shared/widgets/radar_animation.dart';
import '../../../../shared/widgets/vybe_widgets.dart';
import '../bloc/tracking_bloc.dart';

class FindingDriverScreen extends StatelessWidget {
  const FindingDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<TrackingBloc, TrackingState>(
      listener: (context, state) {
        if (state is TrackingDriverAssigned) {
          // Auto-navigate to live tracking, sharing the same TrackingBloc
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              context.go(
                AppRouter.liveTracking,
                extra: context.read<TrackingBloc>(),
              );
            }
          });
        }
      },
      builder: (context, state) {
        final isSearching = state is TrackingSearching;
        final isFound = state is TrackingDriverAssigned;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.uberDarkSurface
              : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppColors.uberBlack,
              ),
              onPressed: () => context.go(AppRouter.home),
            ),
            title: Text(
              isSearching ? 'Finding Your Driver...' : 'Driver Found! 🎉',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.uberBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: isSearching
                          ? _SearchingView(state: state, isDark: isDark)
                          : isFound
                          ? _FoundView(state: state, isDark: isDark)
                          : const SizedBox(),
                    ),
                  ),
                  if (isSearching)
                    VybeButton(
                      text: 'Cancel',
                      backgroundColor: isDark
                          ? AppColors.cardDarkElevated
                          : AppColors.cardLightElevated,
                      textColor: AppColors.error,
                      onPressed: () => context.go(AppRouter.home),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchingView extends StatelessWidget {
  final TrackingSearching state;
  final bool isDark;
  const _SearchingView({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const RadarAnimation(size: 220),
        const SizedBox(height: 40),
        Text(
          'Searching for nearby drivers...',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Usually takes a few seconds',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        // Trip summary chip
        VybeCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.pin_drop, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.trip.dropLocation.title,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${state.trip.dropLocation.distanceKm} km · ${state.trip.dropLocation.etaMinutes} mins',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${state.trip.fareAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FoundView extends StatelessWidget {
  final TrackingDriverAssigned state;
  final bool isDark;
  const _FoundView({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 52,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Driver Assigned!',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Starting live tracking...',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        DriverInfoCard(
          driver: state.driver,
          statusText: 'ON THE WAY',
          onCallPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Call feature coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }
}
