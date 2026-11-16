import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RetouchSettings {
  final bool isEnabled;
  final double smooth;
  final double tone;
  final double slim;
  final double eyes;
  final double teeth;

  const RetouchSettings({
    this.isEnabled = true,
    this.smooth = 0.65,
    this.tone = 0.50,
    this.slim = 0.40,
    this.eyes = 0.35,
    this.teeth = 0.50,
  });

  RetouchSettings copyWith({
    bool? isEnabled,
    double? smooth,
    double? tone,
    double? slim,
    double? eyes,
    double? teeth,
  }) {
    return RetouchSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      smooth: smooth ?? this.smooth,
      tone: tone ?? this.tone,
      slim: slim ?? this.slim,
      eyes: eyes ?? this.eyes,
      teeth: teeth ?? this.teeth,
    );
  }
}

class RetouchBottomSheet extends StatefulWidget {
  final RetouchSettings initialSettings;
  final ValueChanged<RetouchSettings> onChanged;

  const RetouchBottomSheet({
    super.key,
    required this.initialSettings,
    required this.onChanged,
  });

  static void show(
    BuildContext context, {
    required RetouchSettings initialSettings,
    required ValueChanged<RetouchSettings> onChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RetouchBottomSheet(
        initialSettings: initialSettings,
        onChanged: onChanged,
      ),
    );
  }

  @override
  State<RetouchBottomSheet> createState() => _RetouchBottomSheetState();
}

class _RetouchBottomSheetState extends State<RetouchBottomSheet> {
  late RetouchSettings _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialSettings;
  }

  void _update(RetouchSettings next) {
    setState(() => _current = next);
    widget.onChanged(next);
  }

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
          children: [
            // Drag handle
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row
            Row(
              children: [
                const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Color(0xFFFF2DC0),
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Beauty & Retouch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _current.isEnabled,
                  activeThumbColor: const Color(0xFFFF2DC0),
                  activeTrackColor: const Color(0x55FF2DC0),
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    _update(_current.copyWith(isEnabled: val));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Retouch Sliders
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _current.isEnabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !_current.isEnabled,
                child: Column(
                  children: [
                    _buildSliderRow(
                      icon: Icons.spa_rounded,
                      label: 'Smooth',
                      value: _current.smooth,
                      onChanged: (v) => _update(_current.copyWith(smooth: v)),
                    ),
                    _buildSliderRow(
                      icon: Icons.wb_sunny_rounded,
                      label: 'Skin Tone',
                      value: _current.tone,
                      onChanged: (v) => _update(_current.copyWith(tone: v)),
                    ),
                    _buildSliderRow(
                      icon: Icons.face_rounded,
                      label: 'Face Slim',
                      value: _current.slim,
                      onChanged: (v) => _update(_current.copyWith(slim: v)),
                    ),
                    _buildSliderRow(
                      icon: Icons.visibility_rounded,
                      label: 'Enlarge Eyes',
                      value: _current.eyes,
                      onChanged: (v) => _update(_current.copyWith(eyes: v)),
                    ),
                    _buildSliderRow(
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      label: 'Whiten Teeth',
                      value: _current.teeth,
                      onChanged: (v) => _update(_current.copyWith(teeth: v)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Actions: Reset & Done
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _update(const RetouchSettings());
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                  label: const Text('Reset', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    backgroundColor: const Color(0xFFFF2DC0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final pct = (value * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFFF2DC0),
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                overlayColor: const Color(0x33FF2DC0),
                trackHeight: 3.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                min: 0.0,
                max: 1.0,
                onChanged: (v) {
                  onChanged(v);
                },
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$pct%',
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFFFF8AE6),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
