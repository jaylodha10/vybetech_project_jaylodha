import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotationAnim;
  late Animation<double> _slideTextAnim;

  bool _minTimeElapsed = false;
  AuthState? _pendingState;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (runs once)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _rotationAnim = Tween<double>(begin: -0.06, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _slideTextAnim = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Continuous ambient pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _entranceController.forward();

    // Ensure splash is visible for at least 2 seconds so user enjoys the animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _minTimeElapsed = true);
        _checkAndNavigate();
      }
    });

    // Dispatch auth session check
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  void _checkAndNavigate() {
    if (!_minTimeElapsed || _pendingState == null || !mounted) return;
    if (_pendingState is AuthAuthenticated) {
      context.go(AppRouter.home);
    } else if (_pendingState is AuthUnauthenticated) {
      context.go(AppRouter.auth);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _pendingState = state;
        _checkAndNavigate();
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.uberDarkSurface
            : AppColors.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Animated Logo with Radiant Glow & Breathing Pulse ──────────
              AnimatedBuilder(
                animation: Listenable.merge([
                  _entranceController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  final pulse = _pulseController.value;
                  final breathScale = 1.0 + (pulse * 0.04);
                  final glowBlur = 24.0 + (pulse * 18.0);
                  final glowSpread = 2.0 + (pulse * 6.0);
                  final glowOpacity = 0.35 + (pulse * 0.25);

                  return Transform.scale(
                    scale: _scaleAnim.value * breathScale,
                    child: Transform.rotate(
                      angle: _rotationAnim.value,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Radiating background aura ring
                            Container(
                              width: 126 + (pulse * 14),
                              height: 126 + (pulse * 14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(
                                  alpha: (0.15 - pulse * 0.08).clamp(0.0, 1.0),
                                ),
                              ),
                            ),
                            // Logo badge
                            Container(
                              width: 114,
                              height: 114,
                              decoration: BoxDecoration(
                                color: AppColors.uberBlack,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 3.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: glowOpacity,
                                    ),
                                    blurRadius: glowBlur,
                                    spreadRadius: glowSpread,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: SvgPicture.asset(
                                'assets/images/logo.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // ── Animated Brand Typography ─────────────────────────────────
              AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideTextAnim.value),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.tagLine,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 54),

              // ── Animated Loader & Status ──────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Starting your ride...',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textSecondaryLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
