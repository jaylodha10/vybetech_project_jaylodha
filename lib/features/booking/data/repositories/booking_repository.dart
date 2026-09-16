import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/models/driver.dart';
import '../../../../shared/models/ride_location.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/models/vehicle_category.dart';
import '../dummy/mock_data.dart';

class BookingRepository {
  List<RideLocation> getDropLocations() => MockData.dummyLocations;
  List<VehicleCategory> getVehicleCategories() => MockData.vehicleCategories;
  RideLocation get defaultPickup => MockData.defaultPickup;

  /// Attempt to fetch GPS location; falls back to defaultPickup on error
  Future<RideLocation> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return defaultPickup;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        return RideLocation(
          id: 'current_gps',
          title: 'Current Location',
          subtitle:
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          coordinates: LatLng(position.latitude, position.longitude),
          distanceKm: 0.0,
          etaMinutes: 0,
        );
      }
    } catch (_) {}
    return defaultPickup;
  }

  Trip createTrip({
    required RideLocation pickup,
    required RideLocation drop,
    required VehicleCategory vehicleCategory,
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
      pathDriverToPickup: MockData.driverToPickupRoute,
      pathPickupToDrop: MockData.pickupToDropRoute,
    );
  }

  Future<Driver> findDriver() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    return MockData.dummyDriver;
  }
}
