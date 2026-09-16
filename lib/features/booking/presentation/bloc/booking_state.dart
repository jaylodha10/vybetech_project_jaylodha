part of 'booking_bloc.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {
  final RideLocation pickup;
  final List<RideLocation> dropLocations;
  final List<VehicleCategory> vehicleCategories;
  final RideLocation? selectedDrop;
  final VehicleCategory? selectedVehicle;

  BookingInitial({
    required this.pickup,
    required this.dropLocations,
    required this.vehicleCategories,
    this.selectedDrop,
    this.selectedVehicle,
  });

  double get currentFare {
    if (selectedDrop == null || selectedVehicle == null) return 0.0;
    return selectedVehicle!.calculateFare(selectedDrop!.distanceKm);
  }

  BookingInitial copyWith({
    RideLocation? pickup,
    List<RideLocation>? dropLocations,
    List<VehicleCategory>? vehicleCategories,
    RideLocation? selectedDrop,
    VehicleCategory? selectedVehicle,
    bool clearDrop = false,
  }) {
    return BookingInitial(
      pickup: pickup ?? this.pickup,
      dropLocations: dropLocations ?? this.dropLocations,
      vehicleCategories: vehicleCategories ?? this.vehicleCategories,
      selectedDrop: clearDrop ? null : (selectedDrop ?? this.selectedDrop),
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }
}

class BookingLoading extends BookingState {}

class BookingRideCreated extends BookingState {
  final Trip trip;
  BookingRideCreated(this.trip);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}
