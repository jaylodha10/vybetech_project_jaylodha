import 'package:latlong2/latlong.dart';
import '../../../../shared/models/driver.dart';
import '../../../history/data/models/ride_history_item.dart';
import '../../../../shared/models/ride_location.dart';
import '../../../../shared/models/vehicle_category.dart';

class MockData {
  // Pickup Point (BKC, Mumbai)
  static const RideLocation defaultPickup = RideLocation(
    id: 'loc_pickup',
    title: 'Current Location (BKC Hub)',
    subtitle: 'Bandra Kurla Complex, Bandra East, Mumbai',
    coordinates: LatLng(19.0660, 72.8687),
    distanceKm: 0.0,
    etaMinutes: 0,
  );

  // 5 Hardcoded Drop Locations as specified
  static const List<RideLocation> dummyLocations = [
    RideLocation(
      id: 'loc_1',
      title: 'Chhatrapati Shivaji Airport (T2)',
      subtitle: 'Terminal 2, Sahar, Andheri East, Mumbai',
      coordinates: LatLng(19.0896, 72.8656),
      distanceKm: 8.5,
      etaMinutes: 18,
    ),
    RideLocation(
      id: 'loc_2',
      title: 'Cyber City Tech Park',
      subtitle: 'Mindspace IT Park, Airoli / Thane Link',
      coordinates: LatLng(19.0760, 72.8777),
      distanceKm: 5.2,
      etaMinutes: 12,
    ),
    RideLocation(
      id: 'loc_3',
      title: 'Grand Central Mall Kurla',
      subtitle: 'LBS Marg, Kurla West, Mumbai',
      coordinates: LatLng(19.0680, 72.8800),
      distanceKm: 3.8,
      etaMinutes: 9,
    ),
    RideLocation(
      id: 'loc_4',
      title: 'Dadar Central Station',
      subtitle: 'Platform 1 Rd, Dadar East, Mumbai',
      coordinates: LatLng(19.0178, 72.8478),
      distanceKm: 9.1,
      etaMinutes: 22,
    ),
    RideLocation(
      id: 'loc_5',
      title: 'Juhu Beachfront Heights',
      subtitle: 'Juhu Tara Road, Vile Parle West, Mumbai',
      coordinates: LatLng(19.1075, 72.8263),
      distanceKm: 11.4,
      etaMinutes: 28,
    ),
  ];

  // 4 Vehicle Categories with distinct pickup ETAs
  static const List<VehicleCategory> vehicleCategories = [
    VehicleCategory(
      id: 'v_go',
      name: 'Vybe Go',
      tagLine: 'Affordable, compact everyday rides',
      basePrice: 50.0,
      pricePerKm: 14.0,
      capacity: 4,
      iconAsset: 'assets/icons/car_hatchback.png',
      etaMinutes: 2,
    ),
    VehicleCategory(
      id: 'v_sedan',
      name: 'Vybe Sedan',
      tagLine: 'Top-rated drivers, comfortable sedans',
      basePrice: 80.0,
      pricePerKm: 18.0,
      capacity: 4,
      iconAsset: 'assets/icons/car_sedan.png',
      etaMinutes: 4,
    ),
    VehicleCategory(
      id: 'v_xl',
      name: 'Vybe XL',
      tagLine: 'Spacious SUVs for groups & extra luggage',
      basePrice: 130.0,
      pricePerKm: 25.0,
      capacity: 6,
      iconAsset: 'assets/icons/car_suv.png',
      etaMinutes: 6,
    ),
    VehicleCategory(
      id: 'v_premier',
      name: 'Vybe Premier',
      tagLine: 'Luxury rides with premium amenities',
      basePrice: 200.0,
      pricePerKm: 35.0,
      capacity: 4,
      iconAsset: 'assets/icons/car_luxury.png',
      etaMinutes: 5,
    ),
  ];

  // Dummy Driver assigned upon booking match
  static const Driver dummyDriver = Driver(
    id: 'driver_101',
    name: 'Rajesh Kumar',
    photoUrl: 'https://i.pravatar.cc/150?img=68',
    rating: 4.9,
    totalTrips: 1420,
    carModel: 'White Swift Dzire',
    carColor: 'Pearl White',
    carNumber: 'MH 02 CZ 4892',
    phoneNumber: '+91 98765 43210',
  );

  // Path 1: Driver approaching pickup location (BKC Hub)
  static const List<LatLng> driverToPickupRoute = [
    LatLng(19.0600, 72.8620),
    LatLng(19.0620, 72.8640),
    LatLng(19.0640, 72.8660),
    LatLng(19.0650, 72.8675),
    LatLng(19.0660, 72.8687), // Pickup point
  ];

  // Path 2: Pickup location to Drop location (Airport T2)
  static const List<LatLng> pickupToDropRoute = [
    LatLng(19.0660, 72.8687), // Pickup point
    LatLng(19.0710, 72.8680),
    LatLng(19.0750, 72.8670),
    LatLng(19.0800, 72.8665),
    LatLng(19.0850, 72.8660),
    LatLng(19.0896, 72.8656), // Airport T2
  ];

  // 6 Past Rides for History Screen
  static const List<RideHistoryItem> dummyRideHistory = [
    RideHistoryItem(
      id: 'TRIP-8841',
      pickupAddress: 'Bandra Kurla Complex, Mumbai',
      dropAddress: 'Chhatrapati Shivaji Airport (T2)',
      dateString: '15 Sep 2026',
      timeString: '09:30 AM',
      fare: 248.0,
      vehicleName: 'Vybe Sedan',
      driverName: 'Rajesh Kumar',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: 'TRIP-7729',
      pickupAddress: 'Grand Central Mall, Kurla',
      dropAddress: 'Lower Parel IT Park, Mumbai',
      dateString: '12 Sep 2026',
      timeString: '06:15 PM',
      fare: 185.0,
      vehicleName: 'Vybe Go',
      driverName: 'Vikram Singh',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: 'TRIP-6612',
      pickupAddress: 'Juhu Beachfront Heights',
      dropAddress: 'Bandra Station West',
      dateString: '08 Sep 2026',
      timeString: '02:45 PM',
      fare: 160.0,
      vehicleName: 'Vybe Go',
      driverName: 'Priya Sharma',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: 'TRIP-5540',
      pickupAddress: 'Dadar Station Platform 1',
      dropAddress: 'Marine Drive, Churchgate',
      dateString: '03 Sep 2026',
      timeString: '08:20 PM',
      fare: 310.0,
      vehicleName: 'Vybe XL',
      driverName: 'Amit Patel',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: 'TRIP-4409',
      pickupAddress: 'Cyber City Tech Park',
      dropAddress: 'Powai Lake Promenade',
      dateString: '28 Aug 2026',
      timeString: '11:10 AM',
      fare: 420.0,
      vehicleName: 'Vybe Premier',
      driverName: 'Sanjay Dutt',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: 'TRIP-3390',
      pickupAddress: 'Andheri East Metro Station',
      dropAddress: 'BKC Trident Hotel',
      dateString: '21 Aug 2026',
      timeString: '05:00 PM',
      fare: 215.0,
      vehicleName: 'Vybe Sedan',
      driverName: 'Anil Verma',
      status: 'Completed',
    ),
  ];
}
