import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
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
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _isDark => themeModeNotifier.value == ThemeMode.dark;

  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingBloc>().add(BookingInitialized());
    });
  }

  Future<void> _locateMe() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Locating you via GPS...'),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final repo = context.read<BookingRepository>();
      final gps = await repo.fetchCurrentLocation();

      if (!mounted) return;
      context.read<BookingBloc>().add(BookingInitialized());
      _centerOnLocation(gps.coordinates, zoom: 16.0);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📍 Location updated: ${gps.subtitle}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not obtain GPS fix. Using default location.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _centerOnLocation(
    LatLng target, {
    double zoom = 15.5,
    bool hasDrop = false,
  }) {
    final latOffset = hasDrop ? 0.002 : 0.0045;
    final viewCenter = LatLng(target.latitude - latOffset, target.longitude);
    _mapController.move(viewCenter, zoom);
  }

  void _fitRoute(LatLng p1, LatLng p2) {
    final south =
        (p1.latitude < p2.latitude ? p1.latitude : p2.latitude) - 0.006;
    final north =
        (p1.latitude > p2.latitude ? p1.latitude : p2.latitude) + 0.003;
    final west =
        (p1.longitude < p2.longitude ? p1.longitude : p2.longitude) - 0.003;
    final east =
        (p1.longitude > p2.longitude ? p1.longitude : p2.longitude) + 0.003;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(LatLng(south, west), LatLng(north, east)),
        padding: const EdgeInsets.fromLTRB(30, 80, 30, 240),
      ),
    );
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
        if (state is BookingInitial && state.selectedDrop == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _centerOnLocation(state.pickup.coordinates, zoom: 15.5);
          });
        } else if (state is BookingInitial && state.selectedDrop != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fitRoute(
              state.pickup.coordinates,
              state.selectedDrop!.coordinates,
            );
          });
        } else if (state is BookingRideCreated) {
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
        if (state is! BookingInitial) {
          return Scaffold(
            backgroundColor: _isDark
                ? AppColors.uberDarkSurface
                : AppColors.backgroundLight,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final pickup = state.pickup;

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;

            return Scaffold(
              body: Stack(
                children: [
                  // ── Map ──────────────────────────────────────────────────
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        pickup.coordinates.latitude - 0.0045,
                        pickup.coordinates.longitude,
                      ),
                      initialZoom: AppConstants.defaultZoom,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.vybetech_project_jaylodha',
                        tileBuilder: isDark
                            ? (context, tileWidget, tile) => ColorFiltered(
                                colorFilter: const ColorFilter.matrix([
                                  -0.75,
                                  0,
                                  0,
                                  0,
                                  255,
                                  0,
                                  -0.75,
                                  0,
                                  0,
                                  255,
                                  0,
                                  0,
                                  -0.75,
                                  0,
                                  255,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                ]),
                                child: tileWidget,
                              )
                            : null,
                      ),
                      if (state.selectedDrop != null)
                        PolylineLayer(polylines: _buildPolylines(state)),
                      MarkerLayer(markers: _buildMarkers(state)),
                    ],
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

                  // ── Locate Me FAB ────────────────────────────────────────
                  Positioned(
                    right: 16,
                    bottom:
                        MediaQuery.of(context).size.height *
                        (state.selectedDrop != null ? 0.46 : 0.40),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(24),
                      color: isDark ? AppColors.cardDark : Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _locateMe,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isLocating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.my_location_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                              const SizedBox(width: 8),
                              Text(
                                'Locate Me',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.uberBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom Sheet ─────────────────────────────────────────
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(context).size.height *
                            (state.selectedDrop != null ? 0.44 : 0.38),
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
                              // Pickup row (Interactive with Locate Me)
                              InkWell(
                                onTap: _locateMe,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.uberDarkSurface
                                        : AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.my_location_rounded,
                                          color: AppColors.primary,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              pickup.title,
                                              style: TextStyle(
                                                color: isDark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors
                                                          .textPrimaryLight,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              pickup.subtitle,
                                              style: TextStyle(
                                                color: isDark
                                                    ? AppColors
                                                          .textSecondaryDark
                                                    : AppColors
                                                          .textSecondaryLight,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Locate Me',
                                          style: TextStyle(
                                            color: AppColors.uberBlack,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

  List<Marker> _buildMarkers(BookingInitial state) {
    final markers = <Marker>[
      // Pickup marker
      Marker(
        point: state.pickup.coordinates,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: AppColors.uberBlack,
            size: 22,
          ),
        ),
      ),
    ];
    if (state.selectedDrop != null) {
      markers.add(
        Marker(
          point: state.selectedDrop!.coordinates,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }
    return markers;
  }

  List<Polyline> _buildPolylines(BookingInitial state) {
    if (state.selectedDrop == null) return [];
    final points =
        (state.previewRoute != null && state.previewRoute!.isNotEmpty)
        ? state.previewRoute!
        : [state.pickup.coordinates, state.selectedDrop!.coordinates];
    return [
      Polyline(points: points, color: AppColors.primary, strokeWidth: 4.5),
    ];
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
    return Material(
      color: Colors.transparent,
      child: ListTile(
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
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textMutedDark,
        ),
        onTap: () {
          context.read<BookingBloc>().add(BookingDropLocationSelected(loc));
          // Zoom to show both pickup and drop
          final bounds = LatLngBounds.fromPoints([
            state.pickup.coordinates,
            loc.coordinates,
          ]);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.only(
                top: 80,
                bottom: 320,
                left: 40,
                right: 40,
              ),
            ),
          );
        },
      ),
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
