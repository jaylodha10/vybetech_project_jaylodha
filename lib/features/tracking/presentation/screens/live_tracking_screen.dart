import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/driver.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/widgets/driver_info_card.dart';
import '../../../../shared/widgets/vybe_widgets.dart';
import '../bloc/tracking_bloc.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  bool _completionShown = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<TrackingBloc, TrackingState>(
      listenWhen: (previous, current) => current is TrackingCompleted,
      listener: (context, state) {
        if (state is TrackingCompleted && !_completionShown) {
          _completionShown = true;
          _showTripCompletedSheet(context, state, isDark);
        }
      },
      builder: (context, state) {
        if (state is TrackingInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final trip = _getTripFromState(state);
        final driver = _getDriverFromState(state);
        final carPos = _getCarPosition(state);
        final carBearing = _getCarBearing(state);
        final etaSecs = _getEta(state);
        final statusMsg = _getStatusMessage(state);
        final isDriverArrived = state is TrackingDriverArrived;
        final isCompleted = state is TrackingCompleted;

        // Animate camera to car position
        if (carPos != null && _mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(carPos));
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.uberDarkSurface
              : AppColors.backgroundLight,
          body: Stack(
            children: [
              // ── Map ──────────────────────────────────────────────────────
              if (trip != null)
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: trip.pickupLocation.coordinates,
                    zoom: 15.0,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  markers: _buildMarkers(state, trip, carPos, carBearing),
                  polylines: _buildPolylines(state, trip),
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),

              // ── Status pill ───────────────────────────────────────────────
              if (!isCompleted)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 32,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDriverArrived
                                ? Icons.check_circle_rounded
                                : Icons.navigation_rounded,
                            color: isDriverArrived
                                ? AppColors.success
                                : AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              statusMsg,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (etaSecs != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatEta(etaSecs),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Bottom card ───────────────────────────────────────────────
              if (driver != null && trip != null && !isCompleted)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.58,
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: AppColors.textMutedDark,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Fare row
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Fare',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '₹${trip.fareAmount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.primary
                                          : AppColors.uberBlack,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  trip.vehicleCategory.name,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          DriverInfoCard(
                            driver: driver,
                            statusText: _getDriverStatus(state),
                            onCallPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Call feature coming soon!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          if (isDriverArrived) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Driver Arrived! Starting trip automatically...',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            VybeButton(
                              text: 'Start Trip Now 🚗',
                              icon: Icons.play_arrow_rounded,
                              onPressed: () => context.read<TrackingBloc>().add(
                                TrackingTripStarted(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Set<Marker> _buildMarkers(
    TrackingState state,
    Trip? trip,
    LatLng? carPos,
    double carBearing,
  ) {
    final markers = <Marker>{};

    if (trip != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: trip.pickupLocation.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
        ),
      );

      if (state is TrackingInProgress || state is TrackingCompleted) {
        markers.add(
          Marker(
            markerId: const MarkerId('drop'),
            position: trip.dropLocation.coordinates,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'Drop Destination'),
          ),
        );
      }
    }

    if (carPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('car'),
          position: carPos,
          rotation: carBearing,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'Driver Location'),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines(TrackingState state, Trip? trip) {
    if (trip == null) return {};
    final polylines = <Polyline>{};

    if (state is TrackingDriverOnTheWay) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('to_pickup'),
          points: trip.pathDriverToPickup,
          color: AppColors.primary,
          width: 4,
        ),
      );
    } else if (state is TrackingInProgress) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('to_drop'),
          points: trip.pathPickupToDrop,
          color: AppColors.primary,
          width: 4,
        ),
      );
    }
    return polylines;
  }

  Trip? _getTripFromState(TrackingState s) {
    if (s is TrackingSearching) return s.trip;
    if (s is TrackingDriverAssigned) return s.trip;
    if (s is TrackingDriverOnTheWay) return s.trip;
    if (s is TrackingDriverArrived) return s.trip;
    if (s is TrackingInProgress) return s.trip;
    if (s is TrackingCompleted) return s.trip;
    return null;
  }

  Driver? _getDriverFromState(TrackingState s) {
    if (s is TrackingDriverAssigned) return s.driver;
    if (s is TrackingDriverOnTheWay) return s.driver;
    if (s is TrackingDriverArrived) return s.driver;
    if (s is TrackingInProgress) return s.driver;
    if (s is TrackingCompleted) return s.driver;
    return null;
  }

  LatLng? _getCarPosition(TrackingState s) {
    if (s is TrackingDriverOnTheWay) return s.carPosition;
    if (s is TrackingInProgress) return s.carPosition;
    return null;
  }

  double _getCarBearing(TrackingState s) {
    if (s is TrackingDriverOnTheWay) return s.carBearing;
    if (s is TrackingInProgress) return s.carBearing;
    return 0.0;
  }

  int? _getEta(TrackingState s) {
    if (s is TrackingDriverOnTheWay) return s.etaSeconds;
    if (s is TrackingInProgress) return s.etaSeconds;
    return null;
  }

  String _getStatusMessage(TrackingState s) {
    if (s is TrackingSearching) return 'Finding driver...';
    if (s is TrackingDriverAssigned) return 'Driver assigned!';
    if (s is TrackingDriverOnTheWay) return 'Driver on the way';
    if (s is TrackingDriverArrived) return 'Driver has arrived!';
    if (s is TrackingInProgress) return 'Trip in progress';
    if (s is TrackingCompleted) return 'Trip complete';
    return '';
  }

  String _getDriverStatus(TrackingState s) {
    if (s is TrackingDriverOnTheWay) return 'ON THE WAY';
    if (s is TrackingDriverArrived) return 'ARRIVED';
    if (s is TrackingInProgress) return 'IN TRIP';
    return 'ASSIGNED';
  }

  String _formatEta(int seconds) {
    if (seconds < 60) return '$seconds s';
    return '${(seconds / 60).ceil()} min';
  }

  void _showTripCompletedSheet(
    BuildContext context,
    TrackingCompleted state,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.textMutedDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Trip Completed!',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have arrived at ${state.trip.dropLocation.title}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            VybeCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _summaryRow('From', state.trip.pickupLocation.title, isDark),
                  const SizedBox(height: 12),
                  _summaryRow('To', state.trip.dropLocation.title, isDark),
                  const SizedBox(height: 12),
                  _summaryRow('Driver', state.driver.name, isDark),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Fare',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '₹${state.trip.fareAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.primary
                              : AppColors.uberBlack,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        color: AppColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cash · Trip ${state.trip.tripId}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            VybeButton(
              text: 'Back to Home',
              icon: Icons.home_rounded,
              onPressed: () {
                context.read<TrackingBloc>().add(TrackingReset());
                context.go(AppRouter.home);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _summaryRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 55,
          child: Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
