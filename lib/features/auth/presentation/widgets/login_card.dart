import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/gradient_mask.dart';
import '../../providers/auth_providers.dart';
import 'social_login_row.dart';

class LoginCard extends ConsumerStatefulWidget {
  const LoginCard({super.key});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard> {
  static const _radius = 32.0;

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = ValueNotifier(true);
  final _rememberMe = ValueNotifier(true);

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _rememberMe.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(loginControllerProvider.notifier).login(
          identifier: _identifierController.text,
          password: _passwordController.text,
        );
  }

  void _comingSoon(String feature) => context.showAppSnackBar('$feature is coming soon');

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      // Light blur + near-clear fill so the artwork stays visible through the glass.
      blur: 9,
      borderRadius: _radius,
      borderWidth: 1.8,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x263D55C8), Color(0x14080A28), Color(0x269A3BD0)],
      ),
      borderGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFAFC6FF), Color(0xFFE05BFF), Color(0xFFFF4FB0), Color(0xFF4F8CFF)],
        stops: [0, 0.35, 0.65, 1],
      ),
      // Two-tone rim light: pink on the left/bottom, blue on the right/top.
      shadows: const [
        BoxShadow(color: Color(0x8CFF3FA4), blurRadius: 26, offset: Offset(-3, 3), blurStyle: BlurStyle.outer),
        BoxShadow(color: Color(0x8C3B82F6), blurRadius: 26, offset: Offset(3, -3), blurStyle: BlurStyle.outer),
      ],
      child: CustomPaint(
        // Inner highlight line — the "thick glass edge" from the design.
        foregroundPainter: const GradientBorderPainter(
          radius: _radius - 5,
          inset: 5,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x80FFFFFF), Color(0x14FFFFFF), Color(0x40FFFFFF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Title(),
                  const SizedBox(height: 18),
                  GlassTextField(
                    controller: _identifierController,
                    hint: 'Mobile Number / Email',
                    prefixIcon: Icons.phone_in_talk_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email, AutofillHints.telephoneNumber],
                    validator: Validators.phoneOrEmail,
                    maxLength: 80,
                    fontSize: 13,
                    verticalPadding: 14,
                    borderRadius: 16,
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscurePassword,
                    builder: (context, obscure, _) => GlassTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      prefixIcon: Icons.lock_open_rounded,
                      obscureText: obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: Validators.password,
                      onSubmitted: (_) => _submit(),
                      maxLength: 64,
                      fontSize: 13,
                      verticalPadding: 14,
                      borderRadius: 16,
                      suffix: IconButton(
                        onPressed: () => _obscurePassword.value = !obscure,
                        tooltip: obscure ? 'Show password' : 'Hide password',
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        iconSize: 19,
                        icon: Icon(
                          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF9FB2FF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Both halves shrink to fit on narrow phones / large system fonts.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _rememberMe,
                            builder: (context, remember, _) => _RememberMe(
                              value: remember,
                              onChanged: (v) => _rememberMe.value = v,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _comingSoon('Password reset'),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: AppColors.link, fontWeight: FontWeight.w600, fontSize: 11.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, _) => GradientButton(
                      label: 'Login',
                      height: 48,
                      isLoading: ref.watch(loginControllerProvider.select((s) => s.isLoading)),
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _OrDivider(),
                  const SizedBox(height: 14),
                  SocialLoginRow(
                    onSelected: (provider) => ref.read(loginControllerProvider.notifier).loginWith(provider),
                  ),
                  const SizedBox(height: 16),
                  _RegisterPill(onTap: () => _comingSoon('Registration')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white, height: 1.15);
    return const Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome ', style: titleStyle),
              GradientText('Back!', gradient: AppColors.pinkPurpleGradient, style: titleStyle),
            ],
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Login to continue your live journey',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
      ],
    );
  }
}

class _RememberMe extends StatelessWidget {
  const _RememberMe({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: value ? AppColors.pinkPurpleGradient : null,
                border: value ? null : Border.all(color: Colors.white54),
              ),
              child: value ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 8),
            const Text('Remember Me', style: TextStyle(color: Colors.white, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    const line = Expanded(child: Divider(color: Colors.white24, thickness: 1, height: 1));
    return const Row(
      children: [
        line,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Or continue with', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ),
        line,
      ],
    );
  }
}

class _RegisterPill extends StatelessWidget {
  const _RegisterPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: GlassContainer(
          borderRadius: 26,
          color: const Color(0x1F8DA2FF),
          borderColor: const Color(0x668DA2FF),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(
                  width: 52,
                  child: Icon(Icons.person_add_alt_outlined, color: Colors.white, size: 20),
                ),
                Container(width: 1, color: const Color(0x4D8DA2FF)),
                const SizedBox(width: 14),
                // Scales down on narrow phones / large system fonts instead of wrapping.
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5, height: 1.3),
                        ),
                        GradientText(
                          'Register Now',
                          gradient: AppColors.pinkPurpleGradient,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
