import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../root/presentation/main_navigation_screen.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/login_hero_section.dart';
import '../widgets/social_login_buttons.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialEmail;
  const LoginScreen({super.key, this.initialEmail});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpMode = false;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    } else {
      final error = ref.read(authControllerProvider).errorMessage ??
          'Login failed. Please check your credentials.';

      // If email is not verified yet, switch directly to OTP entry
      if (error.toLowerCase().contains('email not verified')) {
        setState(() {
          _isOtpMode = true;
          _otpSent = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _onSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address to receive an OTP.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).sendEmailOtp(email, purpose: 'login');
    if (!mounted) return;

    if (success) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent from tivoo5477@gmail.com to $email!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      final error = ref.read(authControllerProvider).errorMessage ?? 'Failed to send OTP.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _onVerifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP code.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).verifyEmailOtp(email, otp, purpose: 'login');
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } else {
      final error = ref.read(authControllerProvider).errorMessage ?? 'Invalid OTP code.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF09090F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image from assets/Login.png
          Positioned.fill(
            child: Image.asset(
              AppAssets.loginBg,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF09090F)),
            ),
          ),

          // 2. Dark Atmospheric Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.70),
                    const Color(0xFF09090F).withValues(alpha: 0.95),
                    const Color(0xFF09090F),
                  ],
                  stops: const [0.0, 0.35, 0.65, 0.95],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Form Content (fitted for full-screen zero-scroll responsive layout)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 32) > 0
                          ? constraints.maxHeight - 32
                          : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Hero Section: Logo, Live. Stream. Connect., Subtitle
                        const LoginHeroSection(),

                        const SizedBox(height: 16),

                        // Welcome Back form, in a neon-glass card
                        GlassContainer(
                          borderRadius: BorderRadius.circular(24),
                          glowColor: AppColors.glowPurple,
                          glowBlur: 24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back',
                                style: AppTextStyles.heroHeading.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Login to continue your journey',
                                style: AppTextStyles.heroSubtitle.copyWith(
                                  fontSize: 12.5,
                                  color: Colors.white60,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Login Mode Switch: Password vs Email OTP
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isOtpMode = false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: !_isOtpMode ? AppColors.primaryYellow.withValues(alpha: 0.25) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(9),
                                            border: Border.all(
                                              color: !_isOtpMode ? AppColors.primaryYellow : Colors.transparent,
                                              width: 1,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Password',
                                            style: TextStyle(
                                              color: !_isOtpMode ? AppColors.primaryYellow : Colors.white60,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isOtpMode = true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _isOtpMode ? AppColors.primaryYellow.withValues(alpha: 0.25) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(9),
                                            border: Border.all(
                                              color: _isOtpMode ? AppColors.primaryYellow : Colors.transparent,
                                              width: 1,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Email OTP',
                                            style: TextStyle(
                                              color: _isOtpMode ? AppColors.primaryYellow : Colors.white60,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              if (!_isOtpMode) ...[
                                // Email or Phone Number Input Field
                                AuthTextField(
                                  controller: _emailController,
                                  hintText: 'Email or Phone Number',
                                  prefixIcon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 10),

                                // Password Input Field with Visibility Toggle
                                AuthTextField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  isPasswordVisible: authState.isPasswordVisible,
                                  onTogglePassword: authController.togglePasswordVisibility,
                                ),

                                const SizedBox(height: 10),

                                // Forgot Password Button
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Password reset link sent to email'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: AppColors.primaryYellow,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Gradient Log In CTA Button
                                GradientButton(
                                  text: 'Log In',
                                  height: 48,
                                  borderRadius: 24,
                                  isLoading: authState.isLoading,
                                  onPressed: _onLogin,
                                ),
                              ] else ...[
                                // Email for OTP
                                AuthTextField(
                                  controller: _emailController,
                                  hintText: 'Enter your email',
                                  prefixIcon: Icons.email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                if (_otpSent) ...[
                                  const SizedBox(height: 10),
                                  AuthTextField(
                                    controller: _otpController,
                                    hintText: '6-digit OTP Code',
                                    prefixIcon: Icons.pin_outlined,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: _onSendOtp,
                                      child: const Text(
                                        'Resend OTP',
                                        style: TextStyle(
                                          color: AppColors.primaryYellow,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GradientButton(
                                    text: 'Verify & Log In',
                                    height: 48,
                                    borderRadius: 24,
                                    isLoading: authState.isLoading,
                                    onPressed: _onVerifyOtp,
                                  ),
                                ] else ...[
                                  const SizedBox(height: 14),
                                  GradientButton(
                                    text: 'Send OTP Code',
                                    height: 48,
                                    borderRadius: 24,
                                    isLoading: authState.isLoading,
                                    onPressed: _onSendOtp,
                                  ),
                                ],

                                const SizedBox(height: 8),
                                Text(
                                  'OTP sent from tivoo5477@gmail.com',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // OR Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.45),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Social Logins: Google, Apple, Facebook
                      SocialLoginButtons(
                        onGoogleTap: _onLogin,
                        onAppleTap: _onLogin,
                        onFacebookTap: _onLogin,
                      ),

                      const SizedBox(height: 16),

                          // Sign Up Footer
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.65),
                                    fontSize: 12.5,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: AppColors.primaryYellow,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
            ),
          ),
        ],
      ),
    );
  }
}
