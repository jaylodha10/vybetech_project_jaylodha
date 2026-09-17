import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/booking/data/repositories/booking_repository.dart';
import 'features/history/data/repositories/history_repository.dart';
import 'firebase_options.dart';

/// Global notifier so any screen can toggle the app theme
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  runApp(const VybeCabsApp());
}

class VybeCabsApp extends StatefulWidget {
  const VybeCabsApp({super.key});

  @override
  State<VybeCabsApp> createState() => _VybeCabsAppState();
}

class _VybeCabsAppState extends State<VybeCabsApp> {
  late final AuthRepository _authRepository;
  late final BookingRepository _bookingRepository;
  late final HistoryRepository _historyRepository;
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _bookingRepository = BookingRepository();
    _historyRepository = HistoryRepository();
    _authBloc = AuthBloc(authRepository: _authRepository);
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<BookingRepository>.value(value: _bookingRepository),
        RepositoryProvider<HistoryRepository>.value(value: _historyRepository),
      ],
      child: BlocProvider<AuthBloc>.value(
        value: _authBloc,
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp.router(
              title: 'VybeCabs',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
