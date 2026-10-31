import 'package:flutter/material.dart';

import 'live_stream_viewers_sheet.dart';

/// Creator "More Options" bottom sheet with an interactive icon grid
/// matching Tivoo's luxury glassmorphic style.
class CreatorMoreOptionsSheet extends StatelessWidget {
  final String streamTitle;
  final VoidCallback? onSettingsChanged;
  final VoidCallback? onPkBattleTap;

  const CreatorMoreOptionsSheet({
    super.key,
    this.streamTitle = 'My Live Stream',
    this.onSettingsChanged,
    this.onPkBattleTap,
  });

  static Future<void> show(
    BuildContext context, {
    String streamTitle = 'My Live Stream',
    VoidCallback? onSettingsChanged,
    VoidCallback? onPkBattleTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatorMoreOptionsSheet(
        streamTitle: streamTitle,
        onSettingsChanged: onSettingsChanged,
        onPkBattleTap: onPkBattleTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13151F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0x3300E5FF),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 36,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Drag Handle
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Top Bar: Title + Subtitle + Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 32),
                Column(
                  children: const [
                    Text(
                      'Creator Controls',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage chat, audience & stream quality',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Host PK Battle Action Card
            if (onPkBattleTap != null) ...[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onPkBattleTap!();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A1138), Color(0xFF1B1D36)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF2D55), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33FF2D55),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF2D55), Color(0xFFFF8F00)],
                          ),
                        ),
                        child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Host PK Battle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Match & challenge a rival streamer 1v1',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF2D55), Color(0xFFFF6D00)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Icon Grid (Comment Settings, Viewer List, LIVE Quality, Mute User)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              childAspectRatio: 0.74,
              children: [
                _OptionItem(
                  icon: Icons.speaker_notes_rounded,
                  label: 'Comment\nSettings',
                  gradient: const [Color(0xFF00E5FF), Color(0xFF0077FF)],
                  glowColor: const Color(0x5500E5FF),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showCommentSettingsDialog(context);
                  },
                ),
                _OptionItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Viewer\nList',
                  gradient: const [Color(0xFFFFD700), Color(0xFFFF8F00)],
                  glowColor: const Color(0x55FFD700),
                  onTap: () {
                    Navigator.of(context).pop();
                    LiveStreamViewersSheet.show(context, totalViewersCount: '85,432');
                  },
                ),
                _OptionItem(
                  icon: Icons.hd_rounded,
                  label: 'LIVE\nQuality',
                  gradient: const [Color(0xFF00E676), Color(0xFF00B0FF)],
                  glowColor: const Color(0x5500E676),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLiveQualityDialog(context);
                  },
                ),
                _OptionItem(
                  icon: Icons.volume_off_rounded,
                  label: 'Mute\nUser',
                  gradient: const [Color(0xFFFF2D55), Color(0xFFFF6D00)],
                  glowColor: const Color(0x55FF2D55),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showMuteUserDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Comment Settings Sub-sheet
  // ---------------------------------------------------------------------------
  static void _showCommentSettingsDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CommentSettingsSheet(),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. LIVE Quality Sub-sheet
  // ---------------------------------------------------------------------------
  static void _showLiveQualityDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LiveQualitySheet(),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Mute User Sub-sheet
  // ---------------------------------------------------------------------------
  static void _showMuteUserDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MuteUserSheet(),
    );
  }
}

// -----------------------------------------------------------------------------
// Grid Item Component
// -----------------------------------------------------------------------------
class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-SHEET: Comment Settings
// =============================================================================
class _CommentSettingsSheet extends StatefulWidget {
  const _CommentSettingsSheet();

  @override
  State<_CommentSettingsSheet> createState() => _CommentSettingsSheetState();
}

class _CommentSettingsSheetState extends State<_CommentSettingsSheet> {
  bool _allowComments = true;
  bool _filterSensitive = true;
  bool _allowEmojis = true;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141724),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
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
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comment Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _buildSwitchTile(
              title: 'Allow Comments',
              subtitle: 'Allow viewers to post live comments',
              value: _allowComments,
              onChanged: (val) => setState(() => _allowComments = val),
            ),
            _buildSwitchTile(
              title: 'Filter Sensitive Keywords',
              subtitle: 'Automatically hide abusive or spam comments',
              value: _filterSensitive,
              onChanged: (val) => setState(() => _filterSensitive = val),
            ),
            _buildSwitchTile(
              title: 'Allow Emojis & Stickers',
              subtitle: 'Enable quick emoji reactions in chat',
              value: _allowEmojis,
              onChanged: (val) => setState(() => _allowEmojis = val),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comment settings updated successfully! 💬'),
                      backgroundColor: Color(0xFF192233),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF00E5FF),
            activeTrackColor: const Color(0x6600E5FF),
            inactiveThumbColor: Colors.white60,
            inactiveTrackColor: const Color(0xFF2B3047),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-SHEET: LIVE Quality
// =============================================================================
class _LiveQualitySheet extends StatefulWidget {
  const _LiveQualitySheet();

  @override
  State<_LiveQualitySheet> createState() => _LiveQualitySheetState();
}

class _LiveQualitySheetState extends State<_LiveQualitySheet> {
  String _selectedQuality = '720p HD';

  final List<Map<String, String>> _qualities = [
    {'title': '1080p 60fps', 'subtitle': 'Full HD • 4500 kbps (High bandwidth)'},
    {'title': '720p HD', 'subtitle': 'Recommended • 2500 kbps (Smooth)'},
    {'title': '480p SD', 'subtitle': 'Standard • 1200 kbps (Data saver)'},
    {'title': 'Auto', 'subtitle': 'Dynamically adjusts to network quality'},
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141724),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
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
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Broadcast Quality',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ..._qualities.map((q) {
              final isSelected = _selectedQuality == q['title'];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0x2200E676) : const Color(0xFF1B2033),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    q['title']!,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF00E676) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    q['subtitle']!,
                    style: const TextStyle(color: Colors.white54, fontSize: 11.5),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676))
                      : const Icon(Icons.circle_outlined, color: Colors.white30),
                  onTap: () {
                    setState(() => _selectedQuality = q['title']!);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Quality changed to ${q['title']}! 📺'),
                          backgroundColor: const Color(0xFF192233),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-SHEET: Mute User
// =============================================================================
class _MuteUserSheet extends StatefulWidget {
  const _MuteUserSheet();

  @override
  State<_MuteUserSheet> createState() => _MuteUserSheetState();
}

class _MuteUserSheetState extends State<_MuteUserSheet> {
  String _selectedUser = '@Karthik_07';
  String _duration = '5 Minutes';

  final List<String> _viewers = ['@Karthik_07', '@Queen_Anu', '@Priya_Love', '@Rohan_99', '@Guest_412'];
  final List<String> _durations = ['5 Minutes', '1 Hour', 'Entire LIVE'];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141724),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
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
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mute User in Chat',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Select User to Mute',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _viewers.map((user) {
                final isSelected = _selectedUser == user;
                return ChoiceChip(
                  label: Text(user),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF2D55),
                  backgroundColor: const Color(0xFF1E2235),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedUser = user),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text(
              'Mute Duration',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: _durations.map((dur) {
                final isSelected = _duration == dur;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          dur,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFF6D00),
                      backgroundColor: const Color(0xFF1E2235),
                      onSelected: (_) => setState(() => _duration = dur),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                ),
                icon: const Icon(Icons.volume_off_rounded, color: Colors.white, size: 18),
                label: Text(
                  'Mute $_selectedUser',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$_selectedUser has been muted for $_duration 🔇'),
                      backgroundColor: const Color(0xFF192233),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
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
