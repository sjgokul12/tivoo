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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'jessica@tivoo.live');
  final _passwordController = TextEditingController(text: '••••••••');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
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
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Hero Section: Logo, Live. Stream. Connect., Subtitle
                          const LoginHeroSection(),

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

                                const SizedBox(height: 14),

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
                                  isPasswordVisible:
                                      authState.isPasswordVisible,
                                  onTogglePassword:
                                      authController.togglePasswordVisibility,
                                ),

                                const SizedBox(height: 10),

                                // Forgot Password Button
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Password reset link sent to email',
                                          ),
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
                              ],
                            ),
                          ),

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

                          // Social Logins: Google, Apple, Facebook
                          SocialLoginButtons(
                            onGoogleTap: _onLogin,
                            onAppleTap: _onLogin,
                            onFacebookTap: _onLogin,
                          ),

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
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Navigating to Sign Up registration'),
                                        duration: Duration(seconds: 1),
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
