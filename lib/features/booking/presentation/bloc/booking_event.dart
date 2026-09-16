part of 'booking_bloc.dart';

abstract class BookingEvent {}

class BookingInitialized extends BookingEvent {}

class BookingDropLocationSelected extends BookingEvent {
  final RideLocation location;
  BookingDropLocationSelected(this.location);
}

class BookingDropLocationCleared extends BookingEvent {}

class BookingVehicleSelected extends BookingEvent {
  final VehicleCategory category;
  BookingVehicleSelected(this.category);
}

class BookingRideRequested extends BookingEvent {}
