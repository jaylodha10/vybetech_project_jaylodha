import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/ride_location.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/models/vehicle_category.dart';
import '../../data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository}) : super(BookingLoading()) {
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
    emit(BookingLoading());
    final pickup = await bookingRepository.fetchCurrentLocation();
    final drops = bookingRepository.getDropLocations();
    final vehicles = bookingRepository.getVehicleCategories();
    emit(
      BookingInitial(
        pickup: pickup,
        dropLocations: drops,
        vehicleCategories: vehicles,
      ),
    );
  }

  void _onDropSelected(
    BookingDropLocationSelected event,
    Emitter<BookingState> emit,
  ) {
    if (state is! BookingInitial) return;
    final current = state as BookingInitial;
    emit(
      current.copyWith(
        selectedDrop: event.location,
        selectedVehicle:
            current.selectedVehicle ?? current.vehicleCategories.first,
      ),
    );
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

    final trip = bookingRepository.createTrip(
      pickup: current.pickup,
      drop: current.selectedDrop!,
      vehicleCategory: current.selectedVehicle!,
    );
    emit(BookingRideCreated(trip));
  }
}
