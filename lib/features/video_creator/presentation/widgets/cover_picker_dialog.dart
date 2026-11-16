import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/luxe_theme.dart';

class CoverPickerDialog extends StatefulWidget {
  final File? currentCover;
  final Uint8List? currentCoverBytes;
  final String? currentCoverPath;
  final Duration videoDuration;
  final void Function(File file, Uint8List? bytes, String? path) onCoverSelected;

  const CoverPickerDialog({
    super.key,
    this.currentCover,
    this.currentCoverBytes,
    this.currentCoverPath,
    required this.videoDuration,
    required this.onCoverSelected,
  });

  static Future<void> show(
    BuildContext context, {
    File? currentCover,
    Uint8List? currentCoverBytes,
    String? currentCoverPath,
    required Duration videoDuration,
    required void Function(File file, Uint8List? bytes, String? path) onCoverSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoverPickerDialog(
        currentCover: currentCover,
        currentCoverBytes: currentCoverBytes,
        currentCoverPath: currentCoverPath,
        videoDuration: videoDuration,
        onCoverSelected: onCoverSelected,
      ),
    );
  }

  @override
  State<CoverPickerDialog> createState() => _CoverPickerDialogState();
}

class _CoverPickerDialogState extends State<CoverPickerDialog> {
  File? _selectedFile;
  Uint8List? _selectedBytes;
  String? _selectedPath;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.currentCover;
    _selectedBytes = widget.currentCoverBytes;
    _selectedPath = widget.currentCoverPath;
  }

  Future<void> _pickFromGallery() async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img != null) {
        final bytes = await img.readAsBytes();
        final path = img.path;
        final f = File(path);
        setState(() {
          _selectedFile = f;
          _selectedBytes = bytes;
          _selectedPath = path;
        });
        widget.onCoverSelected(f, bytes, path);
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error picking cover: $e');
    }
  }

  Widget _defaultPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C1654), Color(0xFF131526)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_rounded, size: 36, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            Text(
              'Select Cover',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPreview() {
    if (_selectedBytes != null) {
      return Image.memory(_selectedBytes!, fit: BoxFit.cover);
    }
    if (_selectedPath != null && _selectedPath!.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(
          _selectedPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultPlaceholder(),
        );
      }
      if (_selectedPath!.startsWith('blob:') || _selectedPath!.startsWith('http')) {
        return Image.network(
          _selectedPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultPlaceholder(),
        );
      }
      return Image.file(
        File(_selectedPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultPlaceholder(),
      );
    }
    if (!kIsWeb && _selectedFile != null) {
      return Image.file(
        _selectedFile!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultPlaceholder(),
      );
    }
    return _defaultPlaceholder();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.75),
      padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + mq.padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF131526),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0x3300E5FF), width: 1.2)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 28, offset: Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Video Cover',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedFile != null) {
                      widget.onCoverSelected(_selectedFile!, _selectedBytes, _selectedPath);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save', style: TextStyle(color: LuxeColors.gold, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Cover Preview Box
            Container(
              width: 140,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF2A85), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x55FF2A85), blurRadius: 14, spreadRadius: 1),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildCoverPreview(),
              ),
            ),
            const SizedBox(height: 20),
            // Upload button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.black, size: 20),
                label: const Text(
                  'Upload Cover Image',
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LuxeColors.gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select any photo from your device to use as the reel cover',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
