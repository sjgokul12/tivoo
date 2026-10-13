import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  late String _avatarUrl;
  bool _isLoading = false;

  final List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=85',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=85',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600&auto=format&fit=crop&q=85',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&auto=format&fit=crop&q=85',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;
    _nameController = TextEditingController(text: profile.name);
    _usernameController = TextEditingController(
      text: profile.username.startsWith('@')
          ? profile.username
          : '@${profile.username}',
    );
    _bioController = TextEditingController(text: profile.bio);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _emailController = TextEditingController(text: profile.email);
    _avatarUrl = profile.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choose Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a preset avatar or choose from your device:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _avatarPresets.map((url) {
                final isSelected = url == _avatarUrl;
                return GestureDetector(
                  onTap: () {
                    setState(() => _avatarUrl = url);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryYellow
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: CustomAvatar(
                      radius: 30,
                      imageUrl: url,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryYellow,
                      side: const BorderSide(color: AppColors.primaryYellow),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selected photo from gallery')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryYellow,
                      side: const BorderSide(color: AppColors.primaryYellow),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opened Camera')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    ref.read(profileControllerProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          avatarUrl: _avatarUrl,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.primaryYellow),
              SizedBox(width: 10),
              Text(
                'Profile updated successfully! ✨',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
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
          'Edit Profile',
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
            children: [
              // Avatar Change Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.storyRingGradient,
                      ),
                      child: CustomAvatar(
                        radius: 52,
                        imageUrl: _avatarUrl,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryYellow,
                            border: Border.all(
                              color: AppColors.background,
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showAvatarPicker,
                child: const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Full Name
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Full name cannot be empty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Username
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: '@username',
                icon: Icons.alternate_email_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  if (val.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bio
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Write something interesting about you...',
                icon: Icons.edit_note_rounded,
                maxLines: 3,
                maxLength: 150,
              ),

              const SizedBox(height: 16),

              // Phone Number
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+1 (555) 000-0000',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 7) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email Address
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'name@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Email cannot be empty';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Save Changes CTA
              GradientButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _onSave,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
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
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
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
            prefixIcon: Icon(icon, color: AppColors.primaryYellow, size: 20),
            counterStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
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
