import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraSettingsSheet extends StatefulWidget {
  const CameraSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CameraSettingsSheet(),
    );
  }

  @override
  State<CameraSettingsSheet> createState() => _CameraSettingsSheetState();
}

class _CameraSettingsSheetState extends State<CameraSettingsSheet> {
  String _resolution = '1080p 60fps';
  bool _gridLines = false;
  bool _mirrorFrontCamera = true;
  bool _highFidelityAudio = true;
  bool _lowLightBoost = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xF2121020),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0x33FF2DC0), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.settings_rounded, color: Color(0xFFFF2DC0), size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Camera Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Resolution Selector
            const Text(
              'Video Quality',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final res in ['720p', '1080p 60fps', '4K 30fps'])
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _resolution = res);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _resolution == res
                              ? const Color(0xFFFF2DC0).withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: _resolution == res ? const Color(0xFFFF2DC0) : Colors.white12,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          res,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _resolution == res ? const Color(0xFFFF8AE6) : Colors.white70,
                            fontSize: 11.5,
                            fontWeight: _resolution == res ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Toggles
            _buildSwitchTile('Grid Lines (Rule of Thirds)', _gridLines, (v) {
              setState(() => _gridLines = v);
            }),
            _buildSwitchTile('Mirror Front Camera', _mirrorFrontCamera, (v) {
              setState(() => _mirrorFrontCamera = v);
            }),
            _buildSwitchTile('High-Fidelity Audio', _highFidelityAudio, (v) {
              setState(() => _highFidelityAudio = v);
            }),
            _buildSwitchTile('Ultra Low-Light Boost', _lowLightBoost, (v) {
              setState(() => _lowLightBoost = v);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFFFF2DC0),
            activeTrackColor: const Color(0x55FF2DC0),
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
