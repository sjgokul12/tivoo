import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glow_text_field.dart';
import '../../domain/models/user_profile_model.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfileModel profile;
  final Function({required String name, required String username, required String bio, required String aboutMe}) onSave;

  const EditProfileDialog({super.key, required this.profile, required this.onSave});

  static void show(
    BuildContext context, {
    required UserProfileModel profile,
    required Function({required String name, required String username, required String bio, required String aboutMe})
    onSave,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EditProfileDialog(profile: profile, onSave: onSave),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _aboutMeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _usernameController = TextEditingController(text: widget.profile.username);
    _bioController = TextEditingController(text: widget.profile.bio);
    _aboutMeController = TextEditingController(text: widget.profile.aboutMe);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF5161622),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(top: BorderSide(color: Color(0x33FFFFFF), width: 1)),
        boxShadow: [BoxShadow(color: AppColors.glowPurple.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: -10)],
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.viewInsetsOf(context).bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 18),

              _buildFieldLabel('Display Name'),
              GlowTextField(controller: _nameController, hintText: 'Your display name'),

              const SizedBox(height: 12),
              _buildFieldLabel('Username'),
              GlowTextField(controller: _usernameController, hintText: '@username'),

              const SizedBox(height: 12),
              _buildFieldLabel('Tagline / Bio'),
              GlowTextField(controller: _bioController, hintText: 'Live. Stream. Connect.'),

              const SizedBox(height: 12),
              _buildFieldLabel('About Me'),
              GlowTextField(controller: _aboutMeController, hintText: 'Tell viewers about yourself...', maxLines: 3),

              const SizedBox(height: 20),
              GradientButton(
                text: 'Save Changes',
                height: 48,
                borderRadius: 24,
                onPressed: () {
                  widget.onSave(
                    name: _nameController.text.trim(),
                    username: _usernameController.text.trim(),
                    bio: _bioController.text.trim(),
                    aboutMe: _aboutMeController.text.trim(),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}
