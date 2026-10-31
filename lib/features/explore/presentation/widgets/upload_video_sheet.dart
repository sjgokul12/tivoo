import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tivoo/core/config/api_config.dart';
import 'package:tivoo/features/explore/data/video_processor.dart';
import 'package:tivoo/features/explore/presentation/controllers/posts_controller.dart';
import 'package:tivoo/features/home/presentation/controllers/home_controller.dart';

const _gold = Color(0xFFFFC928);
const _goldDeep = Color(0xFFFF9500);
const _muted = Color(0xFFC9C6E8);

/// Mobile-responsive luxury bottom sheet to pick, preview, and upload 4K/HD video reels.
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
  int? _width;
  int? _height;
  String _qualityTag = 'HD';
  int _fileBytes = 0;
  bool _thumbLoading = false;
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
      final files = await FilePicker.pickFiles(type: FileType.video);
      final path = files.isNotEmpty ? files.first.path : null;
      if (path != null) await _use(File(path));
    } catch (_) {
      _fail('Could not open files');
    }
  }

  void _fail(String message) {
    if (mounted) setState(() => _error = message);
  }

  Future<void> _use(File file) async {
    final bytes = await file.length();
    if (bytes > ApiConfig.maxUploadBytes) return _fail('This video is larger than 2 GB');
    setState(() {
      _file = file;
      _fileBytes = bytes;
      _thumb = null;
      _thumbLoading = true;
      _duration = null;
      _width = null;
      _height = null;
      _qualityTag = 'HD';
      _error = null;
    });

    final info = await VideoProcessor.getMediaInfo(file.path);
    final width = info?.width;
    final height = info?.height;
    final dur = info?.duration != null ? Duration(milliseconds: info!.duration!.round()) : null;
    final tag = VideoProcessor.resolutionLabel(width, height);

    if (mounted && _file == file) {
      setState(() {
        _width = width;
        _height = height;
        _duration = dur;
        _qualityTag = tag;
      });
    }

    final thumb = await VideoProcessor.thumbnail(file.path);
    if (mounted && _file == file) {
      setState(() {
        _thumb = thumb;
        _thumbLoading = false;
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
      await ref.read(postsControllerProvider.notifier).upload(
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
    if (_step == UploadStep.converting) {
      return _qualityTag.contains('4K') ? 'Optimizing 4K Clarity $pct%' : 'Optimizing Quality $pct%';
    }
    return 'Uploading $pct%';
  }

  String get _sizeLabel {
    final mb = _fileBytes / (1024 * 1024);
    return mb >= 1024 ? '${(mb / 1024).toStringAsFixed(2)} GB' : '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    final isSmall = width < 360 || height < 700;
    final isTablet = width >= 600;
    final hasFile = _file != null;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : double.infinity,
            maxHeight: height * 0.9,
          ),
          child: Container(
            padding: const EdgeInsets.only(top: 1.4),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_gold, Color(0x557B4DFF), Color(0x337B4DFF)],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0E0D14),
                borderRadius: BorderRadius.vertical(top: Radius.circular(31)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(isSmall ? 16 : 22, 10, isSmall ? 16 : 22, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                      SizedBox(height: isSmall ? 12 : 18),
                      _GlowIcon(size: isSmall ? 68 : 84),
                      SizedBox(height: isSmall ? 10 : 14),
                      Text(
                        'Upload Video',
                        style: TextStyle(color: Colors.white, fontSize: isSmall ? 22 : 25, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Share 4K & HD videos with your followers',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted, fontSize: isSmall ? 13 : 14),
                      ),
                      SizedBox(height: isSmall ? 14 : 20),
                      _DashedBox(
                        onTap: _uploading ? null : () => _pickWithImagePicker(ImageSource.gallery),
                        child: hasFile ? _buildPreview(isSmall) : _buildEmpty(isSmall),
                      ),
                      if (hasFile) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _caption,
                          enabled: !_uploading,
                          maxLength: 200,
                          maxLines: 2,
                          minLines: 1,
                          style: TextStyle(color: Colors.white, fontSize: isSmall ? 13 : 14),
                          decoration: InputDecoration(
                            hintText: 'Write a caption… #tivoo #4k',
                            hintStyle: const TextStyle(color: Colors.white38),
                            counterStyle: const TextStyle(color: Colors.white30, fontSize: 10),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.06),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: _gold, width: 1),
                            ),
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12)),
                      ],
                      SizedBox(height: isSmall ? 12 : 16),
                      _GradientPillButton(
                        label: _buttonLabel,
                        height: isSmall ? 48 : 54,
                        progress: _uploading ? _progress : null,
                        onTap: _uploading ? null : (hasFile ? _post : () => _pickWithImagePicker(ImageSource.gallery)),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _uploading ? null : () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _uploading ? Colors.white24 : _muted,
                            fontSize: isSmall ? 14 : 15,
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

  Widget _buildEmpty(bool isSmall) {
    Widget source(IconData icon, String label, VoidCallback onTap) => InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 12, vertical: isSmall ? 6 : 7),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: _gold, size: isSmall ? 14 : 16),
                const SizedBox(width: 5),
                Text(label, style: TextStyle(color: _gold, fontSize: isSmall ? 11.5 : 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 18 : 22, horizontal: 14),
      child: Column(
        children: [
          Icon(Icons.video_file_outlined, color: _gold, size: isSmall ? 42 : 50),
          const SizedBox(height: 10),
          Text(
            'Choose a video to upload',
            style: TextStyle(color: Colors.white, fontSize: isSmall ? 15 : 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          const Text('Supports 4K UHD, 1080p & all formats  •  Up to 2 GB',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
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

  Widget _buildPreview(bool isSmall) {
    final d = _duration;
    final is4K = _qualityTag.contains('4K');
    final is1080 = _qualityTag.contains('1080p') || _qualityTag.contains('2K');
    final thumbW = isSmall ? 82.0 : 94.0;
    final thumbH = isSmall ? 116.0 : 132.0;

    return Padding(
      padding: EdgeInsets.all(isSmall ? 8 : 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: thumbW,
              height: thumbH,
              color: const Color(0xFF1B1B26),
              child: _thumb != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_thumb!, fit: BoxFit.cover),
                        const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 32)),
                      ],
                    )
                  : (_thumbLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _gold),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2B2240), Color(0xFF151421)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_camera_back_rounded, color: is4K ? _gold : Colors.white70, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                _qualityTag,
                                style: TextStyle(color: is4K ? _gold : Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        )),
            ),
          ),
          SizedBox(width: isSmall ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF4CD964), size: 16),
                    const SizedBox(width: 5),
                    const Expanded(
                      child: Text(
                        'Video selected',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: is4K
                            ? _gold.withValues(alpha: 0.18)
                            : (is1080 ? Colors.cyanAccent.withValues(alpha: 0.15) : Colors.white12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: is4K ? _gold : (is1080 ? Colors.cyanAccent.withValues(alpha: 0.7) : Colors.white24),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _qualityTag,
                        style: TextStyle(
                          color: is4K ? _gold : (is1080 ? Colors.cyanAccent : Colors.white70),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _width != null && _height != null ? '$_width×$_height  •  $_sizeLabel' : _sizeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  d == null ? 'High clarity video' : '${_formatDuration(d)}  •  Full clarity playback',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 11.5),
                ),
                SizedBox(height: isSmall ? 8 : 12),
                if (!_uploading)
                  const Text('Tap to change video', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
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

class _GlowIcon extends StatelessWidget {
  final double size;
  const _GlowIcon({this.size = 84});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF15120A),
        border: Border.all(color: _gold, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x66FFC928), blurRadius: 20, spreadRadius: 1),
          BoxShadow(color: Color(0x22FF9500), blurRadius: 36, spreadRadius: 4),
        ],
      ),
      child: Icon(Icons.cloud_upload_outlined, color: _gold, size: size * 0.48),
    );
  }
}

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
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18));
    canvas.drawRRect(rrect, Paint()..color = const Color(0x0DFFC928));
    final paint = Paint()
      ..color = _gold.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in (Path()..addRRect(rrect.deflate(0.6))).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GradientPillButton extends StatelessWidget {
  final String label;
  final double height;
  final VoidCallback? onTap;
  final double? progress;

  const _GradientPillButton({required this.label, this.height = 54, this.onTap, this.progress});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(colors: [Color(0xFFFFE600), _gold, _goldDeep]);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: progress == null ? gradient : null,
          color: progress == null ? null : const Color(0xFF2A2412),
          boxShadow: const [BoxShadow(color: Color(0x44FFB000), blurRadius: 14, offset: Offset(0, 3))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
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
                    fontSize: height * 0.31,
                    fontWeight: FontWeight.w800,
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
