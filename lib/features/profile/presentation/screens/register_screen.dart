import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/tivoo_logo.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _termsAccepted = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions to continue.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authControllerProvider.notifier).register(
      name: fullName,
      username: username,
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Must type OTP code in popup before proceeding to Login
      _showOtpVerificationDialog(email);
    } else {
      final err = ref.read(authControllerProvider).errorMessage ?? 'Registration failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onGoogleSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google sign-up selected'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showOtpVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _OtpVerificationDialog(
        email: email,
        onVerified: () {
          Navigator.of(dialogCtx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account verified successfully! Please log in.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LoginScreen(initialEmail: email),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (same Login.png)
          Positioned.fill(
            child: Image.asset(
              AppAssets.loginBg,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF09090F)),
            ),
          ),

          // 2. Dark Atmospheric Gradient Overlay — identical to LoginScreen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.72),
                    const Color(0xFF09090F).withValues(alpha: 0.97),
                    const Color(0xFF09090F),
                  ],
                  stops: const [0.0, 0.30, 0.58, 0.90],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Subtle purple neon blob — decorative atmosphere (top-left)
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFB84DFF).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 4. Subtle yellow neon blob — bottom right
          Positioned(
            bottom: -40,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryYellow.withValues(alpha: 0.09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 5. Scrollable form content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Logo ──
                      const TivooLogo(fontSize: 28),

                      const SizedBox(height: 18),

                      // ── Glass Form Card ──
                      GlassContainer(
                        borderRadius: BorderRadius.circular(24),
                        glowColor: AppColors.glowPurple,
                        glowBlur: 28,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading
                            Text(
                              'Create Account',
                              style: AppTextStyles.heroHeading.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Subtitle
                            Text(
                              'Join Tivoo and connect with your community.',
                              style: AppTextStyles.heroSubtitle.copyWith(
                                fontSize: 12.5,
                                color: Colors.white60,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Full Name
                            AuthTextField(
                              controller: _fullNameController,
                              hintText: 'Full Name',
                              prefixIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                            ),

                            const SizedBox(height: 10),

                            // Username
                            AuthTextField(
                              controller: _usernameController,
                              hintText: 'Username',
                              prefixIcon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.text,
                            ),

                            const SizedBox(height: 10),

                            // Email Address
                            AuthTextField(
                              controller: _emailController,
                              hintText: 'Email Address',
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 10),

                            // Password
                            _PasswordField(
                              controller: _passwordController,
                              hintText: 'Password',
                              isVisible: _isPasswordVisible,
                              onToggle: () => setState(
                                  () => _isPasswordVisible = !_isPasswordVisible),
                            ),

                            const SizedBox(height: 10),

                            // Confirm Password
                            _PasswordField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              isVisible: _isConfirmPasswordVisible,
                              onToggle: () => setState(() =>
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible),
                            ),

                            const SizedBox(height: 14),

                            // Terms & Conditions checkbox
                            _TermsCheckbox(
                              value: _termsAccepted,
                              onChanged: (v) =>
                                  setState(() => _termsAccepted = v ?? false),
                            ),

                            const SizedBox(height: 18),

                            // Create Account button
                            GradientButton(
                              text: 'Create Account',
                              height: 48,
                              borderRadius: 24,
                              isLoading: _isLoading,
                              onPressed: _onRegister,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── OR Divider ──
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
                                color: Colors.white.withValues(alpha: 0.45),
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

                      // ── Google Sign-Up button ──
                      _GoogleSignUpButton(onTap: _onGoogleSignUp),

                      const SizedBox(height: 22),

                      // ── "Already have an account? Log In" footer ──
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 12.5,
                                  fontFamily:
                                      GoogleFonts.plusJakartaSans().fontFamily,
                                ),
                              ),
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  color: AppColors.primaryYellow,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  fontFamily:
                                      GoogleFonts.plusJakartaSans().fontFamily,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    } else {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    }
                                  },
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Password field with its own local visibility state wired externally ──
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isVisible;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0x9913131E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? AppColors.glowPink.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.12),
          width: _isFocused ? 1.2 : 0.8,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.glowPink.withValues(alpha: 0.28),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: !widget.isVisible,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: _isFocused ? AppColors.glowPink : Colors.white60,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              widget.isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white54,
              size: 20,
            ),
            onPressed: widget.onToggle,
          ),
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12.5,
          ),
        ),
      ),
    );
  }
}

// ── Terms & Conditions checkbox row ──
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryYellow,
            checkColor: Colors.black,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    fontSize: 12,
                    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                  ),
                ),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    fontSize: 12,
                    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                  ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Google Sign-Up button ──
class _GoogleSignUpButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GoogleSignUpButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0x9913131E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google "G" logo fallback (same pattern as SocialLoginButtons)
              Image.asset(
                AppAssets.logoGoogle,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  child: const Text(
                    'G',
                    style: TextStyle(
                      color: Color(0xFFEA4335),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Continue with Google',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpVerificationDialog extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback onVerified;

  const _OtpVerificationDialog({
    required this.email,
    required this.onVerified,
  });

  @override
  ConsumerState<_OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends ConsumerState<_OtpVerificationDialog> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() => _error = 'Please enter the 6-digit OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref.read(authControllerProvider.notifier).verifyEmailOtp(
      widget.email,
      otp,
      purpose: 'verify_email',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.onVerified();
    } else {
      final err = ref.read(authControllerProvider).errorMessage ?? 'Invalid OTP code. Please try again.';
      setState(() => _error = err);
    }
  }

  void _onResend() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref.read(authControllerProvider.notifier).sendEmailOtp(
      widget.email,
      purpose: 'verify_email',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New OTP code dispatched to ${widget.email} from tivoo5477@gmail.com!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final err = ref.read(authControllerProvider).errorMessage ?? 'Failed to resend OTP.';
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF131526),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryYellow.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            const BoxShadow(color: Colors.black87, blurRadius: 30),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD600), Color(0xFFFF9100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryYellow.withValues(alpha: 0.4), blurRadius: 16),
                ],
              ),
              child: const Icon(Icons.mark_email_read_rounded, color: Colors.black, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'Verify Account',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the 6-digit OTP code sent to',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              widget.email,
              style: const TextStyle(color: AppColors.primaryYellow, fontSize: 13.5, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'Sender: tivoo5477@gmail.com',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF090A14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _otpController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  color: AppColors.primaryYellow,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                ),
                decoration: const InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 22, letterSpacing: 8),
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Please check your inbox or spam folder for your 6-digit code',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'Verify & Continue to Login',
              height: 48,
              borderRadius: 24,
              isLoading: _isLoading,
              onPressed: _onVerify,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
                GestureDetector(
                  onTap: _isLoading ? null : _onResend,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: AppColors.primaryYellow,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

