part of 'tracking_bloc.dart';

abstract class TrackingState {}

class TrackingInitial extends TrackingState {}

class TrackingSearching extends TrackingState {
  final Trip trip;
  TrackingSearching(this.trip);
}

class TrackingDriverAssigned extends TrackingState {
  final Trip trip;
  final Driver driver;
  TrackingDriverAssigned({required this.trip, required this.driver});
}

class TrackingDriverOnTheWay extends TrackingState {
  final Trip trip;
  final Driver driver;
  final LatLng carPosition;
  final double carBearing;
  final int etaSeconds;
  final String statusMessage;

  TrackingDriverOnTheWay({
    required this.trip,
    required this.driver,
    required this.carPosition,
    required this.carBearing,
    required this.etaSeconds,
    this.statusMessage = 'Driver is on the way to pickup...',
  });
}

class TrackingDriverArrived extends TrackingState {
  final Trip trip;
  final Driver driver;
  TrackingDriverArrived({required this.trip, required this.driver});
}

class TrackingInProgress extends TrackingState {
  final Trip trip;
  final Driver driver;
  final LatLng carPosition;
  final double carBearing;
  final int etaSeconds;
  final String statusMessage;

  TrackingInProgress({
    required this.trip,
    required this.driver,
    required this.carPosition,
    required this.carBearing,
    required this.etaSeconds,
    this.statusMessage = 'Trip in progress...',
  });
}

class TrackingCompleted extends TrackingState {
  final Trip trip;
  final Driver driver;
  TrackingCompleted({required this.trip, required this.driver});
}
