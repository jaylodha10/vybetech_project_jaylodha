import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:vybetech_project_jaylodha/core/utils/polyline_utils.dart';
import 'package:vybetech_project_jaylodha/features/auth/data/repositories/auth_repository.dart';
import 'package:vybetech_project_jaylodha/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vybetech_project_jaylodha/features/booking/data/dummy/mock_data.dart';
import 'package:vybetech_project_jaylodha/features/booking/data/repositories/booking_repository.dart';
import 'package:vybetech_project_jaylodha/features/history/data/repositories/history_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('VybeCabs BLoC, Domain & Polyline Tests', () {
    test('PolylineUtils interpolates correctly between two coordinates', () {
      const from = LatLng(10.0, 10.0);
      const to = LatLng(20.0, 20.0);
      final mid = PolylineUtils.interpolate(from, to, 0.5);

      expect(mid.latitude, closeTo(15.0, 0.001));
      expect(mid.longitude, closeTo(15.0, 0.001));
    });

    test('PolylineUtils generates smooth intermediate subpoints', () {
      const waypoints = [LatLng(0, 0), LatLng(10, 10)];
      final subPoints = PolylineUtils.generateSubPoints(waypoints, 5);
      expect(subPoints.length, equals(6)); // 5 intermediate + last
    });

    test(
      'PolylineUtils bearing calculation returns valid 0-360 degree angle',
      () {
        const p1 = LatLng(19.0600, 72.8620);
        const p2 = LatLng(19.0660, 72.8687);
        final bearing = PolylineUtils.getBearing(p1, p2);
        expect(bearing, inInclusiveRange(0.0, 360.0));
      },
    );

    test('VehicleCategory calculates dynamic fare accurately', () {
      final category =
          MockData.vehicleCategories.first; // Vybe Go: base 50 + 10 * 14 = 190
      final fare = category.calculateFare(10.0);
      expect(fare, equals(190.0));
    });

    test(
      'MockData contains required 5 drop locations, 4 vehicles, and 6 history items',
      () {
        expect(MockData.dummyLocations.length, equals(5));
        expect(MockData.vehicleCategories.length, equals(4));
        expect(MockData.dummyRideHistory.length, equals(6));
      },
    );

    test('HistoryRepository pagination works correctly', () {
      final repo = HistoryRepository();
      final page0 = repo.getPage(0);
      expect(page0.length, equals(HistoryRepository.pageSize));
      expect(repo.hasMore(page0.length), isTrue);

      final page1 = repo.getPage(1);
      expect(page1.length, equals(HistoryRepository.pageSize));
      expect(page0.first.id, isNot(equals(page1.first.id)));
    });

    test('BookingRepository creates trip with accurate fare and path', () {
      final repo = BookingRepository();
      const pickup = MockData.defaultPickup;
      final drop = MockData.dummyLocations.first;
      final vehicle = MockData.vehicleCategories.first;

      final trip = repo.createTrip(
        pickup: pickup,
        drop: drop,
        vehicleCategory: vehicle,
      );

      expect(trip.pickupLocation, equals(pickup));
      expect(trip.dropLocation, equals(drop));
      expect(trip.vehicleCategory, equals(vehicle));
      expect(trip.fareAmount, equals(vehicle.calculateFare(drop.distanceKm)));
      expect(trip.pathDriverToPickup.isNotEmpty, isTrue);
      expect(trip.pathPickupToDrop.isNotEmpty, isTrue);
    });

    test('AuthBloc starts in AuthInitial and handles logout', () async {
      final authRepo = AuthRepository();
      final authBloc = AuthBloc(authRepository: authRepo);
      expect(authBloc.state, isA<AuthInitial>());

      authBloc.add(AuthLogoutRequested());
      await expectLater(authBloc.stream, emits(isA<AuthUnauthenticated>()));
      await authBloc.close();
    });
  });
}
