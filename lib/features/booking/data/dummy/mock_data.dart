import 'package:latlong2/latlong.dart';
import '../../../../shared/models/driver.dart';
import '../../../history/data/models/ride_history_item.dart';
import '../../../../shared/models/ride_location.dart';
import '../../../../shared/models/vehicle_category.dart';

class MockData {
  // Pickup Point (Chetak Circle, Udaipur)
  static const RideLocation defaultPickup = RideLocation(
    id: 'loc_pickup',
    title: 'Current Location (Chetak Circle)',
    subtitle: 'Chetak Circle, Madhuban, Udaipur, Rajasthan',
    coordinates: LatLng(24.5854, 73.6879),
    distanceKm: 0.0,
    etaMinutes: 0,
  );

  // 6 Curated Drop Locations in Udaipur
  static const List<RideLocation> dummyLocations = [
    RideLocation(
      id: 'loc_1',
      title: 'Fateh Sagar Lake (Paal)',
      subtitle: 'Fateh Sagar Paal, Rani Road, Udaipur',
      coordinates: LatLng(24.6025, 73.6738),
      distanceKm: 5.5,
      etaMinutes: 14,
    ),
    RideLocation(
      id: 'loc_2',
      title: 'Maharana Pratap Airport (Dabok)',
      subtitle: 'NH 76, Dabok, Udaipur, Rajasthan',
      coordinates: LatLng(24.6177, 73.8961),
      distanceKm: 21.0,
      etaMinutes: 32,
    ),
    RideLocation(
      id: 'loc_3',
      title: 'City Palace & Lake Pichola',
      subtitle: 'Old City, Udaipur, Rajasthan',
      coordinates: LatLng(24.5764, 73.6835),
      distanceKm: 2.8,
      etaMinutes: 9,
    ),
    RideLocation(
      id: 'loc_4',
      title: 'Celebration Mall (Bhuwana)',
      subtitle: 'NH 8, Bhuwana, Udaipur, Rajasthan',
      coordinates: LatLng(24.6142, 73.7078),
      distanceKm: 4.8,
      etaMinutes: 12,
    ),
    RideLocation(
      id: 'loc_5',
      title: 'Saheliyon Ki Bari',
      subtitle: 'Saheli Marg, New Fatehpura, Udaipur',
      coordinates: LatLng(24.6006, 73.6872),
      distanceKm: 3.0,
      etaMinutes: 8,
    ),
    RideLocation(
      id: 'loc_6',
      title: 'Udaipur City Railway Station',
      subtitle: 'Station Rd, Jawahar Nagar, Udaipur',
      coordinates: LatLng(24.5732, 73.6983),
      distanceKm: 2.5,
      etaMinutes: 7,
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
    carNumber: 'RJ 27 CZ 4892',
    phoneNumber: '+91 98765 43210',
  );

  // Path 1: Driver approaching pickup location (Chetak Circle, Udaipur)
  static const List<LatLng> driverToPickupRoute = [
    LatLng(24.5800, 73.6820),
    LatLng(24.5820, 73.6840),
    LatLng(24.5840, 73.6860),
    LatLng(24.5854, 73.6879), // Pickup point
  ];

  // Path 2: Pickup location to Drop location (Fateh Sagar Lake, Udaipur)
  static const List<LatLng> pickupToDropRoute = [
    LatLng(24.5854, 73.6879), // Chetak Circle
    LatLng(24.5890, 73.6850),
    LatLng(24.5930, 73.6810),
    LatLng(24.5970, 73.6780),
    LatLng(24.6025, 73.6738), // Fateh Sagar
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
