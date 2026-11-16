import 'package:flutter/material.dart';
import '../../../../core/theme/luxe_theme.dart';

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final IconData icon;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.icon = Icons.music_note_rounded,
  });
}

class MusicPickerSheet extends StatefulWidget {
  final String? initialSelectedTitle;
  final double initialOriginalVolume;
  final double initialMusicVolume;
  final void Function(String title, String artist, double originalVol, double musicVol) onApply;

  const MusicPickerSheet({
    super.key,
    this.initialSelectedTitle,
    this.initialOriginalVolume = 1.0,
    this.initialMusicVolume = 0.7,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialSelectedTitle,
    double initialOriginalVolume = 1.0,
    double initialMusicVolume = 0.7,
    required void Function(String title, String artist, double originalVol, double musicVol) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MusicPickerSheet(
        initialSelectedTitle: initialSelectedTitle,
        initialOriginalVolume: initialOriginalVolume,
        initialMusicVolume: initialMusicVolume,
        onApply: onApply,
      ),
    );
  }

  @override
  State<MusicPickerSheet> createState() => _MusicPickerSheetState();
}

class _MusicPickerSheetState extends State<MusicPickerSheet> {
  static const List<MusicTrack> _tracks = [
    MusicTrack(id: '1', title: 'Luxe Lounge Vibes', artist: 'Tivoo Originals', duration: '00:30'),
    MusicTrack(id: '2', title: 'Dance Floor Heat', artist: 'Metro Beat', duration: '00:45'),
    MusicTrack(id: '3', title: 'Sunset Drive', artist: 'Neon Horizon', duration: '01:00'),
    MusicTrack(id: '4', title: 'Golden Hour Groove', artist: 'Arya Sharma', duration: '00:30'),
    MusicTrack(id: '5', title: 'Midnight Electric', artist: 'Cyber Synth', duration: '00:45'),
    MusicTrack(id: '6', title: 'Acoustic Breeze', artist: 'Maya Lin', duration: '00:30'),
  ];

  late String? _selectedTitle = widget.initialSelectedTitle;
  late String _selectedArtist = 'Tivoo Sound';
  late double _origVol = widget.initialOriginalVolume;
  late double _musicVol = widget.initialMusicVolume;
  String? _previewingId;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.78),
      padding: EdgeInsets.fromLTRB(18, 14, 18, 16 + mq.padding.bottom),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                const Row(
                  children: [
                    Icon(Icons.music_note_rounded, color: LuxeColors.gold, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Choose Music & Audio',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedTitle != null) {
                      widget.onApply(_selectedTitle!, _selectedArtist, _origVol, _musicVol);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done', style: TextStyle(color: LuxeColors.gold, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Volume Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x661E1A3C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mic_none_rounded, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Original Video Sound', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                      ),
                      Text('${(_origVol * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF9D4EDD),
                      thumbColor: const Color(0xFFFF2A85),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _origVol,
                      onChanged: (v) => setState(() => _origVol = v),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, color: LuxeColors.gold, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Added Music Track', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                      ),
                      Text('${(_musicVol * 100).toInt()}%', style: const TextStyle(color: LuxeColors.gold, fontSize: 12)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: LuxeColors.gold,
                      thumbColor: LuxeColors.goldLight,
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _musicVol,
                      onChanged: (v) => setState(() => _musicVol = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Trending Sounds',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: _tracks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final t = _tracks[i];
                  final isSelected = _selectedTitle == t.title;
                  final isPlaying = _previewingId == t.id;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0x339D4EDD) : const Color(0x441E1A3C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF2A85) : Colors.white10,
                        width: isSelected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _previewingId = isPlaying ? null : t.id;
                            });
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFF9D4EDD), Color(0xFFFF2A85)]),
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.title,
                                style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${t.artist} • ${t.duration}',
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTitle = t.title;
                              _selectedArtist = t.artist;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: isSelected
                                  ? const LinearGradient(colors: [Color(0xFF4CD964), Color(0xFF2E7D32)])
                                  : const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF2979FF)]),
                            ),
                            child: Text(
                              isSelected ? 'Selected ✓' : 'Use',
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
