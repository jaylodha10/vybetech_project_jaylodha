import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/services/road_routing_service.dart';
import '../../../../shared/models/driver.dart';
import '../../../../shared/models/ride_location.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/models/vehicle_category.dart';
import '../dummy/mock_data.dart';

class BookingRepository {
  final RoadRoutingService routingService = RoadRoutingService();

  List<RideLocation> getDropLocations() => MockData.dummyLocations;
  List<VehicleCategory> getVehicleCategories() => MockData.vehicleCategories;
  RideLocation get defaultPickup => MockData.defaultPickup;

  /// Recalculates distances and ETAs for all drop locations based on the current pickup location
  List<RideLocation> getDropLocationsFor(LatLng pickupCoord) {
    const distanceCalc = Distance();
    return MockData.dummyLocations.map((loc) {
      final distKm = double.parse(
        distanceCalc
            .as(LengthUnit.Kilometer, pickupCoord, loc.coordinates)
            .toStringAsFixed(1),
      );
      final etaMins = (distKm * 2.2).round().clamp(5, 60);
      return loc.copyWith(
        distanceKm: distKm > 0 ? distKm : 1.0,
        etaMinutes: etaMins,
      );
    }).toList();
  }

  /// Attempt to fetch GPS location; falls back to defaultPickup on error
  Future<RideLocation> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return defaultPickup;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return defaultPickup;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        LatLng? resolvedCoord;

        // 1. Instant check: last known position from Android location cache
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          resolvedCoord = LatLng(lastKnown.latitude, lastKnown.longitude);
        } else {
          // 2. Active fix with strict 4-second limit
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 4),
            ),
          );
          resolvedCoord = LatLng(position.latitude, position.longitude);
        }

        final address = await routingService.reverseGeocode(resolvedCoord);
        return RideLocation(
          id: 'current_gps',
          title: 'Current Location',
          subtitle: address ??
              '${resolvedCoord.latitude.toStringAsFixed(4)}, ${resolvedCoord.longitude.toStringAsFixed(4)}',
          coordinates: resolvedCoord,
          distanceKm: 0.0,
          etaMinutes: 0,
        );
      }
    } catch (_) {}
    return defaultPickup;
  }

  /// Synchronous fallback for test compatibility
  Trip createTrip({
    required RideLocation pickup,
    required RideLocation drop,
    required VehicleCategory vehicleCategory,
    List<LatLng>? pathDriverToPickup,
    List<LatLng>? pathPickupToDrop,
  }) {
    final fare = vehicleCategory.calculateFare(drop.distanceKm);
    return Trip(
      tripId:
          'TRIP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      pickupLocation: pickup,
      dropLocation: drop,
      vehicleCategory: vehicleCategory,
      fareAmount: double.parse(fare.toStringAsFixed(2)),
      status: TripStatus.searching,
      createdAt: DateTime.now(),
      pathDriverToPickup: pathDriverToPickup ?? MockData.driverToPickupRoute,
      pathPickupToDrop: pathPickupToDrop ?? MockData.pickupToDropRoute,
    );
  }

  /// Asynchronous creation that queries OSRM for real road routes
  Future<Trip> createTripAsync({
    required RideLocation pickup,
    required RideLocation drop,
    required VehicleCategory vehicleCategory,
  }) async {
    try {
      final futures = await Future.wait([
        routingService.getDriverApproachRoute(pickup.coordinates),
        routingService.getRoadRoute(pickup.coordinates, drop.coordinates),
      ]);
      final approachResult = futures[0];
      final dropResult = futures[1];

      final distKm = dropResult.distanceKm > 0
          ? dropResult.distanceKm
          : drop.distanceKm;
      final fare = vehicleCategory.calculateFare(distKm);

      return Trip(
        tripId:
            'TRIP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        pickupLocation: pickup,
        dropLocation: drop.copyWith(distanceKm: distKm),
        vehicleCategory: vehicleCategory,
        fareAmount: double.parse(fare.toStringAsFixed(2)),
        status: TripStatus.searching,
        createdAt: DateTime.now(),
        pathDriverToPickup: approachResult.coordinates,
        pathPickupToDrop: dropResult.coordinates,
      );
    } catch (_) {
      return createTrip(
        pickup: pickup,
        drop: drop,
        vehicleCategory: vehicleCategory,
      );
    }
  }

  Future<Driver> findDriver() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    return MockData.dummyDriver;
  }
}
