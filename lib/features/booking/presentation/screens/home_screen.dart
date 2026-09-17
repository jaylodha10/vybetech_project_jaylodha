import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/map_tile_provider.dart';
import '../../../../main.dart' show themeModeNotifier;
import '../../../../shared/models/ride_location.dart';
import '../../../../shared/widgets/vybe_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/repositories/booking_repository.dart';
import '../bloc/booking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _myLocationEnabled = false;

  bool get _isDark => themeModeNotifier.value == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      if (mounted && status.isGranted) {
        setState(() => _myLocationEnabled = true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingRideCreated) {
          final trackingBloc = TrackingBloc(
            bookingRepository: context.read<BookingRepository>(),
          )..add(TrackingStarted(state.trip));
          context.go(AppRouter.findingDriver, extra: trackingBloc);
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BookingLoading) {
          return Scaffold(
            backgroundColor: _isDark
                ? AppColors.uberDarkSurface
                : AppColors.backgroundLight,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is! BookingInitial) return const SizedBox();
        final pickup = state.pickup;

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
              body: Stack(
                children: [
                  // ── Google Map ──────────────────────────────────────────
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: pickup.coordinates,
                      zoom: AppConstants.defaultZoom,
                    ),
                    onMapCreated: (c) => _mapController = c,
                    markers: _buildMarkers(state),
                    polylines: _buildPolylines(state),
                    myLocationEnabled: _myLocationEnabled,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    tileOverlays: {
                      TileOverlay(
                        tileOverlayId: TileOverlayId(
                          isDark ? 'vybe_dark_tiles' : 'vybe_light_tiles',
                        ),
                        tileProvider: VybeMapTileProvider(isDark: isDark),
                      ),
                    },
                  ),

                  // ── Top Overlay ──────────────────────────────────────────
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        // App chip
                        Flexible(
                          child: VybeCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.local_taxi,
                                    color: AppColors.uberBlack,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    AppConstants.appName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 8),
                        // Action buttons
                        VybeCard(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  themeModeNotifier.value = isDark
                                      ? ThemeMode.light
                                      : ThemeMode.dark;
                                },
                                icon: Icon(
                                  isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    context.push(AppRouter.history),
                                icon: Icon(
                                  Icons.history_rounded,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.uberBlack,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    AuthLogoutRequested(),
                                  );
                                  context.go(AppRouter.auth);
                                },
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Re-center FAB ────────────────────────────────────────
                  Positioned(
                    right: 16,
                    bottom: state.selectedDrop != null ? 360 : 310,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter',
                      backgroundColor: isDark
                          ? AppColors.cardDark
                          : AppColors.cardLight,
                      foregroundColor: isDark
                          ? AppColors.primary
                          : AppColors.uberBlack,
                      onPressed: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(pickup.coordinates, 16.0),
                        );
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),

                  // ── Bottom Sheet ─────────────────────────────────────────
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.58,
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.textMutedDark,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Pickup row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      pickup.title,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (state.selectedDrop == null)
                                _buildDropList(context, state, isDark)
                              else
                                _buildSelectedDropSection(
                                  context,
                                  state,
                                  isDark,
                                ),
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
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  Set<Marker> _buildMarkers(BookingInitial state) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: state.pickup.coordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(title: state.pickup.title),
      ),
    };
    if (state.selectedDrop != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: state.selectedDrop!.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: state.selectedDrop!.title),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines(BookingInitial state) {
    if (state.selectedDrop == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route_preview'),
        points: [state.pickup.coordinates, state.selectedDrop!.coordinates],
        color: AppColors.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  Widget _buildDropList(
    BuildContext context,
    BookingInitial state,
    bool isDark,
  ) {
    final filteredDrops = state.dropLocations.where((loc) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return loc.title.toLowerCase().contains(q) ||
          loc.subtitle.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Where to?" Search Bar
        VybeTextField(
          controller: _searchController,
          hintText: 'Where to? Search destination...',
          labelText: 'Destination',
          prefixIcon: Icons.search_rounded,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          onChanged: (val) {
            setState(() => _searchQuery = val);
          },
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suggested Destinations',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${filteredDrops.length} places',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (filteredDrops.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No matching locations found',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredDrops.length,
            separatorBuilder: (_, _) => Divider(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              height: 1,
            ),
            itemBuilder: (context, index) => _buildLocationTile(
              context,
              state,
              filteredDrops[index],
              isDark,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    BookingInitial state,
    RideLocation loc,
    bool isDark,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDarkElevated
              : AppColors.cardLightElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.location_on_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        loc.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        '${loc.distanceKm} km · ${loc.etaMinutes} mins',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMutedDark),
      onTap: () {
        context.read<BookingBloc>().add(BookingDropLocationSelected(loc));
        // Zoom to show both pickup and drop
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                loc.coordinates.latitude < state.pickup.coordinates.latitude
                    ? loc.coordinates.latitude
                    : state.pickup.coordinates.latitude,
                loc.coordinates.longitude < state.pickup.coordinates.longitude
                    ? loc.coordinates.longitude
                    : state.pickup.coordinates.longitude,
              ),
              northeast: LatLng(
                loc.coordinates.latitude > state.pickup.coordinates.latitude
                    ? loc.coordinates.latitude
                    : state.pickup.coordinates.latitude,
                loc.coordinates.longitude > state.pickup.coordinates.longitude
                    ? loc.coordinates.longitude
                    : state.pickup.coordinates.longitude,
              ),
            ),
            80.0,
          ),
        );
      },
    );
  }

  Widget _buildSelectedDropSection(
    BuildContext context,
    BookingInitial state,
    bool isDark,
  ) {
    final drop = state.selectedDrop!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drop chip
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDarkElevated
                : AppColors.cardLightElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.pin_drop, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drop.title,
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
                      '${drop.distanceKm} km · Drop ETA ${drop.etaMinutes} mins',
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
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMutedDark),
                onPressed: () => context.read<BookingBloc>().add(
                  BookingDropLocationCleared(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Choose Ride',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ETA & Fare',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Vehicle categories
        SizedBox(
          height: 136,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.vehicleCategories.length,
            itemBuilder: (context, index) {
              final cat = state.vehicleCategories[index];
              final isSelected = cat.id == state.selectedVehicle?.id;
              final fare = cat.calculateFare(drop.distanceKm);

              return GestureDetector(
                onTap: () => context.read<BookingBloc>().add(
                  BookingVehicleSelected(cat),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 138,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark
                              ? AppColors.cardDarkElevated
                              : AppColors.cardLightElevated),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondaryDark,
                            size: 22,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.25)
                                  : (isDark
                                        ? Colors.white10
                                        : Colors.black.withValues(alpha: 0.05)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${cat.etaMinutes} min away',
                              style: TextStyle(
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.primary
                                          : AppColors.uberBlack)
                                    : (isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textSecondaryLight),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        cat.name,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${fare.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.uberBlack,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${cat.capacity} seats',
                            style: const TextStyle(
                              color: AppColors.textMutedDark,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        VybeButton(
          text: state.selectedVehicle != null
              ? 'Book ${state.selectedVehicle!.name} · ₹${state.currentFare.toStringAsFixed(0)}'
              : 'Select a Ride Category',
          icon: Icons.local_taxi,
          onPressed: state.selectedVehicle != null
              ? () => context.read<BookingBloc>().add(BookingRideRequested())
              : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
