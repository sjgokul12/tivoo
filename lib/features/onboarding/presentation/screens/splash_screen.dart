import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/animated_gradient_background.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/tivoo_logo.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../widgets/chat_bubble_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;
    final topPadding = context.padding.top;
    final bottomPadding = context.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background visual collage (assets/Splash.png)
          Positioned.fill(
            child: Image.asset(
              AppAssets.splashBg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Top gradient overlay to make text crisp & readable
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.32,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    Color(0xF007070A),
                    Color(0xAA07070A),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Bottom gradient overlay to blend into button and navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.40,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0x8007070A),
                    Color(0xF507070A),
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Ambient neon glow blobs drifting behind the foreground content
          const Positioned.fill(
            child: AnimatedGradientBackground(backgroundColor: null),
          ),

          // Foreground Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SizedBox(height: topPadding > 0 ? 8 : 20),

                          // Top Header Section: Logo + Slogan
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                const TivooLogo(fontSize: 46)
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                                const SizedBox(height: 12),
                                Text(
                                      AppStrings.splashSubtitle,
                                      style: AppTextStyles.heroHeading,
                                      textAlign: TextAlign.center,
                                    )
                                    .animate()
                                    .fadeIn(delay: 150.ms, duration: 500.ms)
                                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                                const SizedBox(height: 8),
                                Text(
                                      AppStrings.splashTagline,
                                      style: AppTextStyles.heroSubtitle,
                                      textAlign: TextAlign.center,
                                    )
                                    .animate()
                                    .fadeIn(delay: 280.ms, duration: 500.ms)
                                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Floating Chat Bubbles over Streamers
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Align(
                                  alignment: const Alignment(-0.25, 0),
                                  child: const ChatBubbleWidget(text: 'Great show! 🔥'),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: const Alignment(0.45, 0),
                                  child: const ChatBubbleWidget(text: 'Love your vibes! 💖'),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: const Alignment(0.18, 0),
                                  child: const ChatBubbleWidget(text: 'Keep going! 👏'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // CTA Button: Get Started ➔
                          Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: GradientButton(
                                  text: AppStrings.getStarted,
                                  onPressed: () => _navigateToLogin(context),
                                  trailingIcon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.textOnPrimary,
                                    size: 22,
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 500.ms, duration: 500.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                          const SizedBox(height: 16),

                          // Bottom Login Prompt
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${AppStrings.alreadyHaveAccount} ',
                                style: AppTextStyles.heroSubtitle.copyWith(fontSize: 13.5),
                              ),
                              GestureDetector(
                                onTap: () => _navigateToLogin(context),
                                child: Text(
                                  AppStrings.logIn,
                                  style: AppTextStyles.heroSubtitle.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPink,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: bottomPadding > 0 ? 12 : 20),
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
