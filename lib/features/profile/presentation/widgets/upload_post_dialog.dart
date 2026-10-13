import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glow_text_field.dart';
import '../../domain/models/user_profile_model.dart';

class UploadPostDialog extends StatefulWidget {
  final ProfileMediaType type;
  final Function({required ProfileMediaType type, required String title, required String mediaUrl, String duration})
  onUpload;

  const UploadPostDialog({super.key, required this.type, required this.onUpload});

  static void show(
    BuildContext context, {
    required ProfileMediaType type,
    required Function({
      required ProfileMediaType type,
      required String title,
      required String mediaUrl,
      String duration,
    })
    onUpload,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => UploadPostDialog(type: type, onUpload: onUpload),
    );
  }

  @override
  State<UploadPostDialog> createState() => _UploadPostDialogState();
}

class _UploadPostDialogState extends State<UploadPostDialog> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '10:00');
  String _selectedThumbnailUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=85';

  final List<String> _sampleMediaOptions = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=85',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=85',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&auto=format&fit=crop&q=85',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600&auto=format&fit=crop&q=85',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.type == ProfileMediaType.video;
    final accentColor = isVideo ? AppColors.glowPurple : AppColors.glowPink;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF5161622),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(top: BorderSide(color: Color(0x33FFFFFF), width: 1)),
        boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: -10)],
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
              Center(
                child: Text(
                  isVideo ? 'Upload Live Video' : 'Upload Image Post',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 18),

              const Text(
                'Select Cover / Media',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Thumbnail Selector
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleMediaOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final url = _sampleMediaOptions[index];
                    final isSelected = url == _selectedThumbnailUrl;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedThumbnailUrl = url;
                        });
                      },
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? accentColor : Colors.white24,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 12)]
                              : null,
                          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Title / Caption',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              GlowTextField(
                controller: _titleController,
                hintText: isVideo ? 'e.g. Acoustic Chill Session #12' : 'e.g. Studio Light setup vibe',
              ),

              if (isVideo) ...[
                const SizedBox(height: 12),
                const Text(
                  'Video Duration',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                GlowTextField(controller: _durationController, hintText: 'e.g. 12:45'),
              ],

              const SizedBox(height: 20),

              GradientButton(
                text: isVideo ? 'Publish Video' : 'Publish Photo',
                height: 48,
                borderRadius: 24,
                gradient: isVideo
                    ? const LinearGradient(colors: [Color(0xFF8E38FF), Color(0xFF6A3BFF)])
                    : AppColors.getStartedButtonGradient,
                onPressed: () {
                  final title = _titleController.text.trim().isNotEmpty
                      ? _titleController.text.trim()
                      : (isVideo ? 'Live Stream Video' : 'Photo Moment');

                  widget.onUpload(
                    type: widget.type,
                    title: title,
                    mediaUrl: _selectedThumbnailUrl,
                    duration: _durationController.text.trim(),
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
}
