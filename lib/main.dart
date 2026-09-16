import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/booking/data/repositories/booking_repository.dart';
import 'features/history/data/repositories/history_repository.dart';

/// Global notifier so any screen can toggle the app theme
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp();
  } catch (_) {}

  runApp(const VybeCabsApp());
}

class VybeCabsApp extends StatelessWidget {
  const VybeCabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final bookingRepository = BookingRepository();
    final historyRepository = HistoryRepository();
    final authBloc = AuthBloc(authRepository: authRepository);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<BookingRepository>.value(value: bookingRepository),
        RepositoryProvider<HistoryRepository>.value(value: historyRepository),
      ],
      child: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp.router(
              title: 'VybeCabs',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: AppRouter.createRouter(authBloc),
            );
          },
        ),
      ),
    );
  }
}
