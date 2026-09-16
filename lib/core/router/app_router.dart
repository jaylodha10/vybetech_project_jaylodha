import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/booking/data/repositories/booking_repository.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/booking/presentation/screens/home_screen.dart';
import '../../features/history/data/repositories/history_repository.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';
import '../../features/tracking/presentation/screens/finding_driver_screen.dart';
import '../../features/tracking/presentation/screens/live_tracking_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String findingDriver = '/finding-driver';
  static const String liveTracking = '/live-tracking';
  static const String history = '/history';

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: splash,
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(path: auth, builder: (context, state) => const AuthScreen()),
        GoRoute(
          path: home,
          builder: (context, state) => BlocProvider(
            create: (_) => BookingBloc(
              bookingRepository: context.read<BookingRepository>(),
            )..add(BookingInitialized()),
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: findingDriver,
          builder: (context, state) {
            final trackingBloc = state.extra as TrackingBloc;
            return BlocProvider.value(
              value: trackingBloc,
              child: const FindingDriverScreen(),
            );
          },
        ),
        GoRoute(
          path: liveTracking,
          builder: (context, state) {
            final trackingBloc = state.extra as TrackingBloc;
            return BlocProvider.value(
              value: trackingBloc,
              child: const LiveTrackingScreen(),
            );
          },
        ),
        GoRoute(
          path: history,
          builder: (context, state) => BlocProvider(
            create: (_) => HistoryBloc(
              historyRepository: context.read<HistoryRepository>(),
            )..add(HistoryLoadRequested()),
            child: const HistoryScreen(),
          ),
        ),
      ],
    );
  }
}
