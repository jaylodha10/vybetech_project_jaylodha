import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/models/ride_location.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/models/vehicle_category.dart';
import '../../data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository})
      : super(
          BookingInitial(
            pickup: bookingRepository.defaultPickup,
            dropLocations: bookingRepository.getDropLocations(),
            vehicleCategories: bookingRepository.getVehicleCategories(),
          ),
        ) {
    on<BookingInitialized>(_onInitialized);
    on<BookingDropLocationSelected>(_onDropSelected);
    on<BookingDropLocationCleared>(_onDropCleared);
    on<BookingVehicleSelected>(_onVehicleSelected);
    on<BookingRideRequested>(_onRideRequested);
  }

  Future<void> _onInitialized(
    BookingInitialized event,
    Emitter<BookingState> emit,
  ) async {
    try {
      final gpsPickup = await bookingRepository.fetchCurrentLocation().timeout(
        const Duration(seconds: 4),
      );
      if (!isClosed && state is BookingInitial) {
        final current = state as BookingInitial;
        final dynamicDrops =
            bookingRepository.getDropLocationsFor(gpsPickup.coordinates);
        emit(current.copyWith(
          pickup: gpsPickup,
          dropLocations: dynamicDrops,
        ));
      }
    } catch (_) {}
  }

  Future<void> _onDropSelected(
    BookingDropLocationSelected event,
    Emitter<BookingState> emit,
  ) async {
    if (state is! BookingInitial) return;
    final current = state as BookingInitial;
    emit(
      current.copyWith(
        selectedDrop: event.location,
        selectedVehicle:
            current.selectedVehicle ?? current.vehicleCategories.first,
      ),
    );

    try {
      final routeResult = await bookingRepository.routingService.getRoadRoute(
        current.pickup.coordinates,
        event.location.coordinates,
      );
      if (!isClosed && state is BookingInitial) {
        final latest = state as BookingInitial;
        if (latest.selectedDrop?.id == event.location.id) {
          emit(latest.copyWith(
            previewRoute: routeResult.coordinates,
            selectedDrop: latest.selectedDrop?.copyWith(
              distanceKm: routeResult.distanceKm > 0
                  ? routeResult.distanceKm
                  : latest.selectedDrop!.distanceKm,
            ),
          ));
        }
      }
    } catch (_) {}
  }

  void _onDropCleared(
    BookingDropLocationCleared event,
    Emitter<BookingState> emit,
  ) {
    if (state is BookingInitial) {
      emit((state as BookingInitial).copyWith(clearDrop: true));
    }
  }

  void _onVehicleSelected(
    BookingVehicleSelected event,
    Emitter<BookingState> emit,
  ) {
    if (state is BookingInitial) {
      emit((state as BookingInitial).copyWith(selectedVehicle: event.category));
    }
  }

  Future<void> _onRideRequested(
    BookingRideRequested event,
    Emitter<BookingState> emit,
  ) async {
    if (state is! BookingInitial) return;
    final current = state as BookingInitial;
    if (current.selectedDrop == null || current.selectedVehicle == null) return;

    final trip = await bookingRepository.createTripAsync(
      pickup: current.pickup,
      drop: current.selectedDrop!,
      vehicleCategory: current.selectedVehicle!,
    );
    emit(BookingRideCreated(trip));
  }
}
