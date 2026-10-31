import 'package:flutter/material.dart';

/// Live Tools / PK Control Bottom Sheet from Screenshot 3
/// Opened via Middle button [LIVE] in PK Live bottom action bar
class LiveToolsBottomSheet extends StatelessWidget {
  final VoidCallback? onPkSettingsTap;
  final VoidCallback? onInviteTap;
  final VoidCallback? onRankingTap;
  final VoidCallback? onGuestsTap;
  final VoidCallback? onReportTap;

  const LiveToolsBottomSheet({
    super.key,
    this.onPkSettingsTap,
    this.onInviteTap,
    this.onRankingTap,
    this.onGuestsTap,
    this.onReportTap,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onPkSettingsTap,
    VoidCallback? onInviteTap,
    VoidCallback? onRankingTap,
    VoidCallback? onGuestsTap,
    VoidCallback? onReportTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LiveToolsBottomSheet(
        onPkSettingsTap: onPkSettingsTap,
        onInviteTap: onInviteTap,
        onRankingTap: onRankingTap,
        onGuestsTap: onGuestsTap,
        onReportTap: onReportTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0x33448AFF), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 36, offset: Offset(0, -6))],
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + (bottomInset > 0 ? bottomInset : 0)),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Bar: Live Tools Title + Close ✕ Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Column(
                  children: const [
                    Text(
                      'Live Tools',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage your Live room, PK and more',
                      style: TextStyle(color: Colors.white54, fontSize: 11.5, fontWeight: FontWeight.w500),
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
            const SizedBox(height: 18),

            // 2x3 Grid of 6 Live Tools Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                _buildToolCard(
                  icon: Icons.settings_rounded,
                  iconColor: const Color(0xFF2979FF),
                  title: 'Live Tools',
                  subtitle: 'Room settings,\nmic, camera, effects',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Opening Live Tools settings...')));
                  },
                ),
                _buildToolCard(
                  icon: Icons.flash_on_rounded,
                  iconColor: const Color(0xFFFF2D78),
                  title: 'PK Info',
                  subtitle: 'PK settings,\ninvite, schedule',
                  onTap: () {
                    Navigator.pop(context);
                    if (onPkSettingsTap != null) onPkSettingsTap!();
                  },
                ),
                _buildToolCard(
                  icon: Icons.people_rounded,
                  iconColor: const Color(0xFF00E5FF),
                  title: 'Guests',
                  subtitle: 'Invite, manage,\nremove guests',
                  onTap: () {
                    Navigator.pop(context);
                    if (onGuestsTap != null) onGuestsTap!();
                  },
                ),
                _buildToolCard(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFFFD600),
                  title: 'Ranking',
                  subtitle: 'Live ranking,\ncontribution list',
                  onTap: () {
                    Navigator.pop(context);
                    if (onRankingTap != null) onRankingTap!();
                  },
                ),
                _buildToolCard(
                  icon: Icons.article_rounded,
                  iconColor: const Color(0xFF448AFF),
                  title: 'Rules',
                  subtitle: 'Live room rules,\ncommunity guidelines',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('PK Battle & Live room rules active.')));
                  },
                ),
                _buildToolCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFFF1744),
                  title: 'Report',
                  subtitle: 'Report user,\nblock, safety tools',
                  onTap: () {
                    Navigator.pop(context);
                    if (onReportTap != null) {
                      onReportTap!();
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Safety tools & Report panel opened.')));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Bottom Badges: Safe Live, Better Interaction, Bigger Community
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSafetyBadge(Icons.verified_user_rounded, 'Safe Live', const Color(0xFF2979FF)),
                _buildSafetyBadge(Icons.groups_rounded, 'Better Interaction', const Color(0xFFBA43F6)),
                _buildSafetyBadge(Icons.military_tech_rounded, 'Bigger Community', const Color(0xFFFFD600)),
              ],
            ),
            const SizedBox(height: 12),

            // Subtle Tagline matching Screenshot 3
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'More Control, More Fun! ',
                  style: TextStyle(
                    color: Color(0xFFFF2D78),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('👑', style: TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E212D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 9.5, height: 1.2, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF191B26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
