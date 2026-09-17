import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/polyline_utils.dart';
import '../../../../shared/models/driver.dart';
import '../../../../shared/models/trip.dart';
import '../../../booking/data/repositories/booking_repository.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final BookingRepository bookingRepository;
  Timer? _movementTimer;
  Timer? _autoStartTimer;

  TrackingBloc({required this.bookingRepository}) : super(TrackingInitial()) {
    on<TrackingStarted>(_onStarted);
    on<TrackingDriverFound>(_onDriverFound);
    on<TrackingMoveTick>(_onMoveTick);
    on<TrackingDriverArrivedAtPickup>(_onDriverArrived);
    on<TrackingTripStarted>(_onTripStarted);
    on<TrackingTripCompleted>(_onTripCompleted);
    on<TrackingReset>(_onReset);
  }

  Future<void> _onStarted(
    TrackingStarted event,
    Emitter<TrackingState> emit,
  ) async {
    _cancelAllTimers();
    emit(TrackingSearching(event.trip));

    // Simulate driver search delay (3.5s)
    await Future.delayed(const Duration(milliseconds: 3500));
    if (isClosed) return;

    final driver = await bookingRepository.findDriver();
    if (isClosed) return;
    add(TrackingDriverFound(driver));
  }

  void _onDriverFound(TrackingDriverFound event, Emitter<TrackingState> emit) {
    if (state is! TrackingSearching) return;
    final trip = (state as TrackingSearching).trip;
    emit(TrackingDriverAssigned(trip: trip, driver: event.driver));

    // Auto-start driver-to-pickup animation after 1.8s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!isClosed) _startDriverToPickupAnimation(trip, event.driver);
    });
  }

  List<LatLng> _generateNavigationSteps(List<LatLng> waypoints, int targetCount) {
    if (waypoints.isEmpty) return [];
    if (waypoints.length == 1) return waypoints;

    if (waypoints.length >= targetCount) {
      final sampled = <LatLng>[];
      final stepSize = (waypoints.length - 1) / (targetCount - 1);
      for (int i = 0; i < targetCount; i++) {
        final index = (i * stepSize).round().clamp(0, waypoints.length - 1);
        sampled.add(waypoints[index]);
      }
      return sampled;
    } else {
      final subPointsPerSegment =
          (targetCount / (waypoints.length - 1)).ceil().clamp(1, 10);
      return PolylineUtils.generateSubPoints(waypoints, subPointsPerSegment);
    }
  }

  void _startDriverToPickupAnimation(Trip trip, Driver driver) {
    _cancelMovementTimer();
    final waypoints = trip.pathDriverToPickup;
    final smoothSteps = _generateNavigationSteps(waypoints, 14);
    int step = 0;

    _movementTimer = Timer.periodic(const Duration(milliseconds: 800), (
      timer,
    ) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (step < smoothSteps.length) {
        final pos = smoothSteps[step];
        final nextPos = (step + 1 < smoothSteps.length)
            ? smoothSteps[step + 1]
            : pos;
        final bearing = PolylineUtils.getBearing(pos, nextPos);
        add(
          TrackingMoveTick(
            position: pos,
            bearing: bearing,
            etaSeconds: (smoothSteps.length - step) * 2,
          ),
        );
        step++;
      } else {
        timer.cancel();
        add(TrackingDriverArrivedAtPickup());
      }
    });
  }

  void _onMoveTick(TrackingMoveTick event, Emitter<TrackingState> emit) {
    final s = state;
    if (s is TrackingDriverAssigned) {
      emit(
        TrackingDriverOnTheWay(
          trip: s.trip,
          driver: s.driver,
          carPosition: event.position,
          carBearing: event.bearing,
          etaSeconds: event.etaSeconds,
        ),
      );
    } else if (s is TrackingDriverOnTheWay) {
      emit(
        TrackingDriverOnTheWay(
          trip: s.trip,
          driver: s.driver,
          carPosition: event.position,
          carBearing: event.bearing,
          etaSeconds: event.etaSeconds,
        ),
      );
    } else if (s is TrackingInProgress) {
      emit(
        TrackingInProgress(
          trip: s.trip,
          driver: s.driver,
          carPosition: event.position,
          carBearing: event.bearing,
          etaSeconds: event.etaSeconds,
          statusMessage: 'Trip in progress to destination...',
        ),
      );
    }
  }

  void _onDriverArrived(
    TrackingDriverArrivedAtPickup event,
    Emitter<TrackingState> emit,
  ) {
    final s = state;
    if (s is TrackingDriverOnTheWay) {
      emit(TrackingDriverArrived(trip: s.trip, driver: s.driver));

      // Auto-start trip toward drop location after 2.5s
      _autoStartTimer?.cancel();
      _autoStartTimer = Timer(const Duration(milliseconds: 2500), () {
        if (!isClosed && state is TrackingDriverArrived) {
          add(TrackingTripStarted());
        }
      });
    }
  }

  void _onTripStarted(TrackingTripStarted event, Emitter<TrackingState> emit) {
    final s = state;
    if (s is! TrackingDriverArrived) return;
    _cancelAllTimers();

    final waypoints = s.trip.pathPickupToDrop;
    final smoothSteps = _generateNavigationSteps(waypoints, 28);
    int step = 0;

    // Emit initial in-progress state
    emit(
      TrackingInProgress(
        trip: s.trip,
        driver: s.driver,
        carPosition: s.trip.pickupLocation.coordinates,
        carBearing: 0,
        etaSeconds: smoothSteps.length * 2,
      ),
    );

    _movementTimer = Timer.periodic(const Duration(milliseconds: 750), (
      timer,
    ) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (step < smoothSteps.length) {
        final pos = smoothSteps[step];
        final nextPos = (step + 1 < smoothSteps.length)
            ? smoothSteps[step + 1]
            : pos;
        add(
          TrackingMoveTick(
            position: pos,
            bearing: PolylineUtils.getBearing(pos, nextPos),
            etaSeconds: (smoothSteps.length - step) * 2,
          ),
        );
        step++;
      } else {
        timer.cancel();
        add(TrackingTripCompleted());
      }
    });
  }

  void _onTripCompleted(
    TrackingTripCompleted event,
    Emitter<TrackingState> emit,
  ) {
    final s = state;
    if (s is TrackingInProgress) {
      emit(TrackingCompleted(trip: s.trip, driver: s.driver));
    }
  }

  void _onReset(TrackingReset event, Emitter<TrackingState> emit) {
    _cancelAllTimers();
    emit(TrackingInitial());
  }

  void _cancelMovementTimer() {
    _movementTimer?.cancel();
    _movementTimer = null;
  }

  void _cancelAllTimers() {
    _cancelMovementTimer();
    _autoStartTimer?.cancel();
    _autoStartTimer = null;
  }

  @override
  Future<void> close() {
    _cancelAllTimers();
    return super.close();
  }
}
