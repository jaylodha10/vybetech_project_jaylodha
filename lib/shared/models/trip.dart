import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'driver.dart';
import 'ride_location.dart';
import 'vehicle_category.dart';

enum TripStatus {
  searching,
  driverAssigned,
  driverOnTheWay,
  driverArrived,
  inProgress,
  completed,
  cancelled,
}

class Trip extends Equatable {
  final String tripId;
  final RideLocation pickupLocation;
  final RideLocation dropLocation;
  final VehicleCategory vehicleCategory;
  final double fareAmount;
  final Driver? assignedDriver;
  final TripStatus status;
  final DateTime createdAt;
  final List<LatLng> pathPickupToDrop;
  final List<LatLng> pathDriverToPickup;

  const Trip({
    required this.tripId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicleCategory,
    required this.fareAmount,
    this.assignedDriver,
    this.status = TripStatus.searching,
    required this.createdAt,
    this.pathPickupToDrop = const [],
    this.pathDriverToPickup = const [],
  });

  Trip copyWith({
    String? tripId,
    RideLocation? pickupLocation,
    RideLocation? dropLocation,
    VehicleCategory? vehicleCategory,
    double? fareAmount,
    Driver? assignedDriver,
    TripStatus? status,
    DateTime? createdAt,
    List<LatLng>? pathPickupToDrop,
    List<LatLng>? pathDriverToPickup,
  }) {
    return Trip(
      tripId: tripId ?? this.tripId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      fareAmount: fareAmount ?? this.fareAmount,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pathPickupToDrop: pathPickupToDrop ?? this.pathPickupToDrop,
      pathDriverToPickup: pathDriverToPickup ?? this.pathDriverToPickup,
    );
  }

  @override
  List<Object?> get props => [
    tripId,
    pickupLocation,
    dropLocation,
    vehicleCategory,
    fareAmount,
    assignedDriver,
    status,
    createdAt,
    pathPickupToDrop,
    pathDriverToPickup,
  ];
}
