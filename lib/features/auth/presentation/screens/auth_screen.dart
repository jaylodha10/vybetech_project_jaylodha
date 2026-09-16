import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/vybe_widgets.dart';
import '../bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Phone auth
  final _phoneController = TextEditingController(text: '+91 9876543210');
  final _otpController = TextEditingController();
  String? _verificationId;

  // Email auth
  final _emailController = TextEditingController(text: 'rider@vybecabs.com');
  final _passwordController = TextEditingController(text: 'vybe1234');
  final _nameController = TextEditingController(text: 'Jay Lodha');
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.home);
        } else if (state is AuthOtpSent) {
          setState(() => _verificationId = state.verificationId);
          _showSuccess('OTP sent to ${state.phoneNumber}. Demo OTP: 123456');
        } else if (state is AuthError) {
          _showError(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.uberDarkSurface
              : AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.uberBlack,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rider Sign In',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDarkElevated
                          : AppColors.cardLightElevated,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: isDark ? Colors.white : AppColors.uberBlack,
                      unselectedLabelColor: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'Phone OTP'),
                        Tab(text: 'Email'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return IndexedStack(
                        index: _tabController.index,
                        children: [
                          _buildPhoneTab(context, isDark, isLoading),
                          _buildEmailTab(context, isDark, isLoading),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneTab(BuildContext context, bool isDark, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VybeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Phone Number',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "We'll send a 6-digit OTP to verify",
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              VybeTextField(
                controller: _phoneController,
                hintText: '+91 9876543210',
                labelText: 'Phone Number',
                prefixIcon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
              if (_verificationId != null) ...[
                const SizedBox(height: 14),
                VybeTextField(
                  controller: _otpController,
                  hintText: '6-digit OTP (demo: 123456)',
                  labelText: 'Verification Code',
                  prefixIcon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_verificationId == null)
          VybeButton(
            text: 'Send Verification OTP',
            isLoading: isLoading,
            icon: Icons.send_rounded,
            onPressed: () {
              final phone = _phoneController.text.trim();
              if (phone.isEmpty) {
                _showError('Enter a valid phone number');
                return;
              }
              context.read<AuthBloc>().add(AuthPhoneOtpRequested(phone));
            },
          )
        else
          Column(
            children: [
              VybeButton(
                text: 'Verify & Continue',
                isLoading: isLoading,
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  final otp = _otpController.text.trim();
                  if (otp.length < 6) {
                    _showError('Enter a valid 6-digit OTP');
                    return;
                  }
                  context.read<AuthBloc>().add(
                    AuthPhoneOtpVerified(
                      verificationId: _verificationId!,
                      otp: otp,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() {
                  _verificationId = null;
                  _otpController.clear();
                }),
                child: const Text(
                  'Change Phone Number',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmailTab(BuildContext context, bool isDark, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VybeCard(
          child: Column(
            children: [
              if (_isSignUp) ...[
                VybeTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  labelText: 'Name',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
              ],
              VybeTextField(
                controller: _emailController,
                hintText: 'rider@vybecabs.com',
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              VybeTextField(
                controller: _passwordController,
                hintText: 'Password (min 6 chars)',
                labelText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        VybeButton(
          text: _isSignUp ? 'Create Account' : 'Sign In with Email',
          isLoading: isLoading,
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            final email = _emailController.text.trim();
            final password = _passwordController.text.trim();
            if (!email.contains('@') || password.length < 6) {
              _showError('Check email address and password (min 6 chars)');
              return;
            }
            context.read<AuthBloc>().add(
              AuthEmailSubmitted(
                email: email,
                password: password,
                name: _nameController.text.trim(),
                isSignUp: _isSignUp,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp
                  ? 'Already have an account? Sign In'
                  : 'New to VybeCabs? Create Account',
              style: TextStyle(
                color: isDark ? AppColors.primary : AppColors.uberBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
