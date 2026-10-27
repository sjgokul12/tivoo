import 'package:flutter/material.dart';

import '../../../../core/widgets/tivoo_share_sheet.dart';

/// Viewer "More Options" bottom sheet with clean icon grid matching Tivoo UI style.
class ViewerMoreOptionsSheet extends StatelessWidget {
  final String streamerName;
  final String streamerId;
  final String? streamerAvatar;
  final String category;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final VoidCallback? onNotInterested;

  const ViewerMoreOptionsSheet({
    super.key,
    required this.streamerName,
    required this.streamerId,
    this.streamerAvatar,
    this.category = 'Live Stream',
    this.onReport,
    this.onBlock,
    this.onNotInterested,
  });

  static Future<void> show(
    BuildContext context, {
    required String streamerName,
    required String streamerId,
    String? streamerAvatar,
    String category = 'Live Stream',
    VoidCallback? onReport,
    VoidCallback? onBlock,
    VoidCallback? onNotInterested,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ViewerMoreOptionsSheet(
        streamerName: streamerName,
        streamerId: streamerId,
        streamerAvatar: streamerAvatar,
        category: category,
        onReport: onReport,
        onBlock: onBlock,
        onNotInterested: onNotInterested,
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
          color: const Color(0x33448AFF),
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
                  children: [
                    const Text(
                      'More Options',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Live with @$streamerName',
                      style: const TextStyle(
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
            const SizedBox(height: 22),

            // Grid: Share LIVE, Report LIVE, Not Interested, Block User, Help / LIVE Rules
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 14,
              childAspectRatio: 0.88,
              children: [
                _ViewerOptionItem(
                  icon: Icons.share_rounded,
                  label: 'Share\nLIVE',
                  gradient: const [Color(0xFF00E5FF), Color(0xFF0077FF)],
                  glowColor: const Color(0x5500E5FF),
                  onTap: () {
                    Navigator.of(context).pop();
                    final shareUrl = 'https://tivoo.app/live/$streamerId';
                    TivooShareSheet.show(
                      context,
                      title: 'Share Live Stream',
                      subtitle: '$streamerName • $category',
                      shareUrl: shareUrl,
                      shareText: 'Watch $streamerName live on Tivoo! $shareUrl',
                    );
                  },
                ),
                _ViewerOptionItem(
                  icon: Icons.flag_rounded,
                  label: 'Report\nLIVE',
                  gradient: const [Color(0xFFFF1744), Color(0xFFFF5252)],
                  glowColor: const Color(0x55FF1744),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showReportLiveDialog(context);
                  },
                ),
                _ViewerOptionItem(
                  icon: Icons.thumb_down_alt_rounded,
                  label: 'Not\nInterested',
                  gradient: const [Color(0xFFFFB300), Color(0xFFFF8F00)],
                  glowColor: const Color(0x55FFB300),
                  onTap: () {
                    Navigator.of(context).pop();
                    onNotInterested?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("We'll show you fewer lives like this."),
                        backgroundColor: const Color(0xFF192233),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: const Color(0xFF00E5FF),
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                ),
                _ViewerOptionItem(
                  icon: Icons.block_rounded,
                  label: 'Block\nUser',
                  gradient: const [Color(0xFFFF2D55), Color(0xFFB0203E)],
                  glowColor: const Color(0x55FF2D55),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBlockUserDialog(context);
                  },
                ),
                _ViewerOptionItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Help /\nLIVE Rules',
                  gradient: const [Color(0xFF2979FF), Color(0xFF651FFF)],
                  glowColor: const Color(0x552979FF),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLiveRulesDialog(context);
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
  // Report LIVE Dialog
  // ---------------------------------------------------------------------------
  void _showReportLiveDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportLiveSheet(streamerName: streamerName),
    );
  }

  // ---------------------------------------------------------------------------
  // Block User Confirmation Dialog
  // ---------------------------------------------------------------------------
  void _showBlockUserDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x33FF2D55), width: 1.2),
        ),
        title: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x22FF2D55),
              ),
              child: const Icon(Icons.block_rounded, color: Color(0xFFFF2D55), size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              'Block $streamerName?',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'They will not be able to follow you, view your profile, or see your comments. They will not be notified that you blocked them.',
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onBlock?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Blocked $streamerName'),
                        backgroundColor: const Color(0xFF192233),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Block', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE Rules Sub-sheet
  // ---------------------------------------------------------------------------
  void _showLiveRulesDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LiveRulesSheet(),
    );
  }
}

// -----------------------------------------------------------------------------
// Viewer Option Icon Item
// -----------------------------------------------------------------------------
class _ViewerOptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _ViewerOptionItem({
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
// SUB-SHEET: Report LIVE
// =============================================================================
class _ReportLiveSheet extends StatefulWidget {
  final String streamerName;
  const _ReportLiveSheet({required this.streamerName});

  @override
  State<_ReportLiveSheet> createState() => _ReportLiveSheetState();
}

class _ReportLiveSheetState extends State<_ReportLiveSheet> {
  int _selectedReasonIndex = -1;
  final TextEditingController _detailsController = TextEditingController();

  final List<Map<String, String>> _reasons = [
    {'title': 'Harassment or Bullying', 'desc': 'Insults, threats, or targeted harassment'},
    {'title': 'Inappropriate or Adult Content', 'desc': 'Sexually explicit or suggestive behavior'},
    {'title': 'Spam, Scams or Fraud', 'desc': 'Deceptive practices, phishing, or bot activity'},
    {'title': 'Hate Speech or Symbols', 'desc': 'Discrimination based on race, religion, etc.'},
    {'title': 'Violence or Dangerous Acts', 'desc': 'Self-harm, physical violence, or threats'},
    {'title': 'Other Violation', 'desc': 'Does not follow community guidelines'},
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 540,
      decoration: const BoxDecoration(
        color: Color(0xFF141724),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
      child: Column(
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
              Text(
                'Report @${widget.streamerName}',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
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
          const SizedBox(height: 6),
          const Text(
            'Select a reason why you are reporting this broadcast:',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: _reasons.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final reason = _reasons[index];
                final isSelected = _selectedReasonIndex == index;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0x22FF1744) : const Color(0xFF1B2033),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF1744) : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      reason['title']!,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFFF5252) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      reason['desc']!,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF1744), size: 20)
                        : const Icon(Icons.circle_outlined, color: Colors.white24, size: 20),
                    onTap: () => setState(() => _selectedReasonIndex = index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedReasonIndex >= 0 ? const Color(0xFFFF1744) : const Color(0xFF2C324B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
              ),
              onPressed: _selectedReasonIndex >= 0
                  ? () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report submitted. Thank you for keeping Tivoo safe! 🛡️'),
                          backgroundColor: Color(0xFF192233),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  : null,
              child: Text(
                'Submit Report',
                style: TextStyle(
                  color: _selectedReasonIndex >= 0 ? Colors.white : Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-SHEET: Help / LIVE Rules
// =============================================================================
class _LiveRulesSheet extends StatelessWidget {
  const _LiveRulesSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final rules = [
      {
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFFF2D55),
        'title': 'Respectful & Kind Community',
        'desc': 'No bullying, harassment, hate speech, or derogatory remarks in comments or broadcast.'
      },
      {
        'icon': Icons.shield_rounded,
        'color': const Color(0xFF00E5FF),
        'title': 'Safe & Age-Appropriate Content',
        'desc': 'Sexually explicit material, dangerous stunts, and illegal activities are strictly forbidden.'
      },
      {
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFFD700),
        'title': 'Fair Gifting & Stars Policy',
        'desc': 'All stars and virtual gifts are final. Fraudulent transactions or gift manipulation is prohibited.'
      },
      {
        'icon': Icons.gavel_rounded,
        'color': const Color(0xFFBA43F6),
        'title': 'Real-time Enforcement',
        'desc': 'Violations may result in stream termination, account suspensions, or permanent platform bans.'
      },
    ];

    return Container(
      height: 520,
      decoration: const BoxDecoration(
        color: Color(0xFF141724),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
      child: Column(
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
                'Tivoo LIVE Community Rules',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
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
          const SizedBox(height: 14),

          Expanded(
            child: ListView.separated(
              itemCount: rules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = rules[index];
                final color = r['color'] as Color;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2033),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(r['icon'] as IconData, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['title'] as String,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r['desc'] as String,
                              style: const TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'I Understand',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
