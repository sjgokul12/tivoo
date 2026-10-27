import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:tivoo/core/config/api_config.dart';
import 'package:tivoo/features/home/presentation/controllers/home_controller.dart';
import 'package:tivoo/features/explore/data/video_processor.dart';
import 'package:tivoo/features/explore/presentation/controllers/posts_controller.dart';

const _gold = Color(0xFFFFC928);
const _goldDeep = Color(0xFFFF9500);
const _muted = Color(0xFFC9C6E8);

/// "Upload Video" bottom sheet: pick a video, preview it, add a caption and post it.
/// The post appears on the user's profile and at the top of Explore.
class UploadVideoSheet extends ConsumerStatefulWidget {
  const UploadVideoSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UploadVideoSheet(),
    );
  }

  @override
  ConsumerState<UploadVideoSheet> createState() => _UploadVideoSheetState();
}

class _UploadVideoSheetState extends ConsumerState<UploadVideoSheet> {
  final _caption = TextEditingController();
  File? _file;
  File? _thumb;
  Duration? _duration;
  int _fileBytes = 0;
  bool _uploading = false;
  UploadStep _step = UploadStep.converting;
  double _progress = 0;
  String? _error;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pickWithImagePicker(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickVideo(source: source);
      if (picked != null) await _use(File(picked.path));
    } catch (_) {
      _fail(source == ImageSource.camera ? 'Camera unavailable' : 'Could not open gallery');
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.video);
      final path = result.isNotEmpty ? result.first.path : null;
      if (path != null) await _use(File(path));
    } catch (_) {
      _fail('Could not open files');
    }
  }

  void _fail(String message) {
    if (mounted) setState(() => _error = message);
  }

  /// Any video the phone can open is accepted: it's converted to MP4 when posting.
  Future<void> _use(File file) async {
    final bytes = await file.length();
    if (bytes > ApiConfig.maxUploadBytes) return _fail('This video is larger than 2 GB');
    setState(() {
      _file = file;
      _fileBytes = bytes;
      _thumb = null;
      _duration = null;
      _error = null;
    });
    final thumb = await VideoProcessor.thumbnail(file.path);
    final duration = await VideoProcessor.duration(file.path);
    if (mounted && _file == file) {
      setState(() {
        _thumb = thumb;
        _duration = duration;
      });
    }
  }

  Future<void> _post() async {
    final file = _file;
    if (file == null || _uploading) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _uploading = true;
      _progress = 0;
      _error = null;
    });
    try {
      await ref
          .read(postsControllerProvider.notifier)
          .upload(
            file,
            thumbnail: _thumb,
            caption: _caption.text.trim(),
            onProgress: (step, p) {
              if (mounted) {
                setState(() {
                  _step = step;
                  _progress = p;
                });
              }
            },
          );
      if (mounted) navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Video posted to your profile & Explore 🎉'),
          backgroundColor: const Color(0xFF1F293D),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          // Without this, a snackbar with an action stays until tapped.
          persist: false,
          action: SnackBarAction(
            label: 'VIEW',
            textColor: _gold,
            onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 3,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = 'Upload failed: ${e.toString().replaceFirst('HttpException: ', '')}';
      });
    }
  }

  String get _buttonLabel {
    if (!_uploading) return _file != null ? 'Post Video' : 'Select Video';
    final pct = (_progress * 100).clamp(0, 100).toStringAsFixed(0);
    return _step == UploadStep.converting ? 'Optimizing $pct%' : 'Uploading $pct%';
  }

  String get _sizeLabel {
    final mb = _fileBytes / (1024 * 1024);
    return mb >= 1024 ? '${(mb / 1024).toStringAsFixed(2)} GB' : '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _file != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.only(top: 1.4),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_gold, Color(0x557B4DFF), Color(0x337B4DFF)],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0E0D14),
                borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 22),
                      const _GlowIcon(),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload Video',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Share a video with your followers on Tivoo',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted, fontSize: 14.5),
                      ),
                      const SizedBox(height: 22),
                      _DashedBox(
                        onTap: _uploading ? null : () => _pickWithImagePicker(ImageSource.gallery),
                        child: hasFile ? _buildPreview() : _buildEmpty(),
                      ),
                      if (hasFile) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller: _caption,
                          enabled: !_uploading,
                          maxLength: 200,
                          maxLines: 2,
                          minLines: 1,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Write a caption… #tivoo',
                            hintStyle: const TextStyle(color: Colors.white38),
                            counterStyle: const TextStyle(color: Colors.white30, fontSize: 10),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.06),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: _gold, width: 1),
                            ),
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12.5),
                        ),
                      ],
                      const SizedBox(height: 18),
                      _GradientPillButton(
                        label: _buttonLabel,
                        progress: _uploading ? _progress : null,
                        onTap: _uploading
                            ? null
                            : (hasFile ? _post : () => _pickWithImagePicker(ImageSource.gallery)),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: _uploading ? null : () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _uploading ? Colors.white24 : _muted,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    Widget source(IconData icon, String label, VoidCallback onTap) => InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _gold, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: _gold, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          const Icon(Icons.video_file_outlined, color: _gold, size: 54),
          const SizedBox(height: 12),
          const Text(
            'Choose a video to upload',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text('Any video format  •  Up to 2 GB', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              source(Icons.videocam_rounded, 'Record', () => _pickWithImagePicker(ImageSource.camera)),
              source(Icons.folder_open_rounded, 'Files', _pickFromFiles),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final d = _duration;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 92,
              height: 132,
              color: Colors.black,
              child: _thumb == null
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _gold))
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_thumb!, fit: BoxFit.cover),
                        const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 34)),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF4CD964), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Video selected',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  d == null ? _sizeLabel : '${_formatDuration(d)}  •  $_sizeLabel',
                  style: const TextStyle(color: Colors.white54, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                if (!_uploading)
                  const Text(
                    'Tap to change video',
                    style: TextStyle(color: _gold, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }
}

/// Gold ring with a glowing cloud-upload icon.
class _GlowIcon extends StatelessWidget {
  const _GlowIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF15120A),
        border: Border.all(color: _gold, width: 2.4),
        boxShadow: const [
          BoxShadow(color: Color(0x88FFC928), blurRadius: 26, spreadRadius: 1),
          BoxShadow(color: Color(0x33FF9500), blurRadius: 46, spreadRadius: 8),
        ],
      ),
      child: const Icon(
        Icons.cloud_upload_outlined,
        color: _gold,
        size: 46,
        shadows: [Shadow(color: Color(0xAAFFC928), blurRadius: 12)],
      ),
    );
  }
}

/// Rounded box with a dashed gold border.
class _DashedBox extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _DashedBox({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: CustomPaint(
        painter: const _DashedBorderPainter(),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(22));
    canvas.drawRRect(rrect, Paint()..color = const Color(0x0DFFC928));
    final paint = Paint()
      ..color = _gold.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final metric in (Path()..addRRect(rrect.deflate(0.7))).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 13) {
        canvas.drawPath(metric.extractPath(d, d + 7), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Yellow → orange pill button; with [progress] it fills like a progress bar.
class _GradientPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double? progress;

  const _GradientPillButton({required this.label, this.onTap, this.progress});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(colors: [Color(0xFFFFE600), _gold, _goldDeep]);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: progress == null ? gradient : null,
          color: progress == null ? null : const Color(0xFF2A2412),
          boxShadow: const [BoxShadow(color: Color(0x55FFB000), blurRadius: 18, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (progress != null)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress!.clamp(0.02, 1.0),
                  child: const DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
                ),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: progress == null ? const Color(0xFF1A1300) : Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    shadows: progress == null ? null : const [Shadow(color: Colors.black87, blurRadius: 6)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
