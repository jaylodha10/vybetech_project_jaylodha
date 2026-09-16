part of 'tracking_bloc.dart';

abstract class TrackingEvent {}

class TrackingStarted extends TrackingEvent {
  final Trip trip;
  TrackingStarted(this.trip);
}

class TrackingDriverFound extends TrackingEvent {
  final Driver driver;
  TrackingDriverFound(this.driver);
}

class TrackingMoveTick extends TrackingEvent {
  final LatLng position;
  final double bearing;
  final int etaSeconds;
  TrackingMoveTick({
    required this.position,
    required this.bearing,
    required this.etaSeconds,
  });
}

class TrackingDriverArrivedAtPickup extends TrackingEvent {}

class TrackingTripStarted extends TrackingEvent {}

class TrackingTripCompleted extends TrackingEvent {}

class TrackingReset extends TrackingEvent {}
