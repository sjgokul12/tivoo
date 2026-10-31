import 'package:flutter/material.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/tivoo_share_sheet.dart';
import '../core/pk_models.dart';
import 'pk_sheets.dart';

/// PK Battle "More Options" bottom sheet matching the live streaming style.
///
/// Features:
/// - "Share Battle" (replaces Share LIVE)
/// - "Report Battle" (replaces Report LIVE)
/// - "Help" (replaces Help / LIVE Rules)
/// - "Block User"
/// - "Switch Active Host"
class PkMoreOptionsSheet extends StatelessWidget {
  final PkHost leftHost;
  final PkHost rightHost;
  final VoidCallback? onSwitchHost;
  final VoidCallback? onBlock;
  final VoidCallback? onHelp;

  const PkMoreOptionsSheet({
    super.key,
    required this.leftHost,
    required this.rightHost,
    this.onSwitchHost,
    this.onBlock,
    this.onHelp,
  });

  static Future<void> show(
    BuildContext context, {
    required PkHost leftHost,
    required PkHost rightHost,
    VoidCallback? onSwitchHost,
    VoidCallback? onBlock,
    VoidCallback? onHelp,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PkMoreOptionsSheet(
        leftHost: leftHost,
        rightHost: rightHost,
        onSwitchHost: onSwitchHost,
        onBlock: onBlock,
        onHelp: onHelp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    final isCompact = mq.size.width < 360;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13151F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0x33448AFF), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 36, offset: Offset(0, -6))],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
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

              // Header: Title + Subtitle + Close Button
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
                        '${leftHost.name}  ⚔️  ${rightHost.name}',
                        style: const TextStyle(color: LuxeColors.textDim, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Options Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isCompact ? 2 : 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  // 1. Share Battle (replaces Share LIVE)
                  _PkOptionItem(
                    icon: Icons.share_rounded,
                    label: 'Share\nBattle',
                    gradient: const [Color(0xFF00E5FF), Color(0xFF0077FF)],
                    glowColor: const Color(0x5500E5FF),
                    onTap: () {
                      Navigator.of(context).pop();
                      final shareUrl = 'https://tivoo.app/pk/${leftHost.name.toLowerCase()}';
                      TivooShareSheet.show(
                        context,
                        title: 'Share PK Battle',
                        subtitle: '${leftHost.name} VS ${rightHost.name}',
                        shareUrl: shareUrl,
                        shareText: 'Watch ${leftHost.name} vs ${rightHost.name} in PK Battle on Tivoo! $shareUrl',
                      );
                    },
                  ),

                  // 2. Report Battle (replaces Report LIVE)
                  _PkOptionItem(
                    icon: Icons.flag_rounded,
                    label: 'Report\nBattle',
                    gradient: const [Color(0xFFFF1744), Color(0xFFFF5252)],
                    glowColor: const Color(0x55FF1744),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showReportBattleDialog(context);
                    },
                  ),

                  // 3. Help (replaces Help / LIVE Rules)
                  _PkOptionItem(
                    icon: Icons.menu_book_rounded,
                    label: 'Help',
                    gradient: const [Color(0xFF2979FF), Color(0xFF651FFF)],
                    glowColor: const Color(0x552979FF),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (onHelp != null) {
                        onHelp!();
                      } else {
                        PkSheets.showRules(context);
                      }
                    },
                  ),

                  // 4. Block User
                  _PkOptionItem(
                    icon: Icons.block_rounded,
                    label: 'Block\nUser',
                    gradient: const [Color(0xFFFF2D55), Color(0xFFB0203E)],
                    glowColor: const Color(0x55FF2D55),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showBlockDialog(context);
                    },
                  ),

                  // 5. Switch Active Host
                  _PkOptionItem(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Switch\nHost',
                    gradient: const [Color(0xFFFFD54F), Color(0xFFFF9100)],
                    glowColor: const Color(0x55FFD54F),
                    onTap: () {
                      Navigator.of(context).pop();
                      onSwitchHost?.call();
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

  void _showReportBattleDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportBattleSheet(battleTitle: '${leftHost.name} vs ${rightHost.name}'),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1638),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFF2D55), width: 1.2),
        ),
        title: const Text(
          'Block Streamer?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to block ${rightHost.name}? You will no longer see their battles or comments.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D55),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onBlock?.call();
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

class _PkOptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _PkOptionItem({
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: glowColor, blurRadius: 14, spreadRadius: 1, offset: const Offset(0, 3))],
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 24)),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _ReportBattleSheet extends StatefulWidget {
  final String battleTitle;

  const _ReportBattleSheet({required this.battleTitle});

  @override
  State<_ReportBattleSheet> createState() => _ReportBattleSheetState();
}

class _ReportBattleSheetState extends State<_ReportBattleSheet> {
  final List<String> _reasons = [
    'Inappropriate or adult content',
    'Harassment or hate speech',
    'Fraud, scam, or fake engagement',
    'Dangerous or harmful acts',
    'Underage host in battle',
    'Other battle policy violation',
  ];
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13151F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFFF1744), width: 1.2)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
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
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Report Battle',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a reason for reporting ${widget.battleTitle}:',
              style: const TextStyle(color: LuxeColors.textDim, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ..._reasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  reason,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFF5252) : Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF1744), size: 18)
                    : const Icon(Icons.radio_button_unchecked_rounded, color: Colors.white30, size: 18),
                onTap: () => setState(() => _selectedReason = reason),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1744),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _selectedReason == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report submitted. Thank you for keeping Tivoo safe!'),
                            backgroundColor: Color(0xFF192233),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
