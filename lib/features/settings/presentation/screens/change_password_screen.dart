import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../../core/widgets/gradient_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  double _passwordStrength = 0.0;
  String _strengthLabel = 'Enter new password';
  Color _strengthColor = AppColors.textMuted;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_calculateStrength);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_calculateStrength);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _calculateStrength() {
    final password = _newPasswordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _strengthLabel = 'Enter new password';
        _strengthColor = AppColors.textMuted;
      });
      return;
    }

    double strength = 0.0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9!@#\$&*~]').hasMatch(password)) strength += 0.25;

    String label = 'Weak';
    Color color = Colors.redAccent;

    if (strength <= 0.25) {
      label = 'Too Weak';
      color = Colors.redAccent;
    } else if (strength == 0.5) {
      label = 'Medium';
      color = Colors.orangeAccent;
    } else if (strength == 0.75) {
      label = 'Good';
      color = AppColors.primaryYellow;
    } else {
      label = 'Strong & Secure ✨';
      color = Colors.greenAccent;
    }

    setState(() {
      _passwordStrength = strength;
      _strengthLabel = label;
      _strengthColor = color;
    });
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: const [
              Icon(Icons.lock_reset_rounded, color: AppColors.primaryYellow),
              SizedBox(width: 10),
              Text(
                'Password updated successfully! 🔒',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GlowIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          size: 38,
          backgroundColor: AppColors.cardBackground,
          iconColor: AppColors.textPrimary,
          onTap: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your new password must be at least 8 characters long, containing letters, numbers, or special symbols.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Current Password
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Current Password',
                hint: '••••••••',
                obscureText: _obscureCurrent,
                onToggleVisibility: () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset instructions sent to your email.'),
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

              const SizedBox(height: 8),

              // New Password
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
                hint: '••••••••',
                obscureText: _obscureNew,
                onToggleVisibility: () {
                  setState(() => _obscureNew = !_obscureNew);
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (val.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (val == _currentPasswordController.text) {
                    return 'New password cannot be the same as current password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // Password Strength Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Strength: $_strengthLabel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _strengthColor,
                    ),
                  ),
                  Text(
                    '${(_passwordStrength * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _strengthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  minHeight: 5,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                ),
              ),

              const SizedBox(height: 20),

              // Confirm New Password
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                hint: '••••••••',
                obscureText: _obscureConfirm,
                onToggleVisibility: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (val != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 36),

              // Submit Button
              GradientButton(
                text: 'Update Password',
                isLoading: _isLoading,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            fontSize: 14.5,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            filled: true,
            fillColor: AppColors.cardBackground,
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.primaryYellow, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryYellow,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
