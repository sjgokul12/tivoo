import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/luxe_tivoo_logo.dart';
import '../data/chat_room_data.dart';
import 'chat_room_common.dart';

/// Step 5: "Chat Room Ended" summary — illustration, host card, four stats and Back to Home.
class RoomEndedView extends StatefulWidget {
  final ChatRoom room;
  final int totalStars;
  final VoidCallback onHome;

  const RoomEndedView({super.key, required this.room, required this.totalStars, required this.onHome});

  @override
  State<RoomEndedView> createState() => _RoomEndedViewState();
}

class _RoomEndedViewState extends State<RoomEndedView> with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  static String _thousands(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return LayoutBuilder(
      builder: (context, c) {
        final art = (c.maxHeight * 0.2).clamp(110.0, 160.0);
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        const LuxeTivooLogo(size: 30, showTagline: false, showEmblem: true),
                        const SizedBox(height: 14),
                        AnimatedBuilder(
                          animation: _float,
                          builder: (_, child) =>
                              Transform.translate(offset: Offset(0, -6 + _float.value * 12), child: child),
                          child: Image.asset(
                            AppAssets.endChat,
                            height: art,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => _EndedEmblem(size: art),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Thank you everyone\nfor being part of this room!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: LuxeColors.textMuted, fontSize: 13.5, height: 1.35),
                        ),
                        const SizedBox(height: 16),
                        _HostCard(room: room),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.45,
                          children: [
                            _StatCard(
                              icon: Icons.star_rounded,
                              color: LuxeColors.gold,
                              value: _thousands(widget.totalStars),
                              label: 'Total Stars',
                            ),
                            const _StatCard(
                              icon: Icons.access_time_filled_rounded,
                              color: Color(0xFF3DDC97),
                              value: '2h 35m',
                              label: 'Total Duration',
                            ),
                            const _StatCard(
                              icon: Icons.groups_rounded,
                              color: LuxeColors.pink,
                              value: '128',
                              label: 'Total Members',
                            ),
                            const _StatCard(
                              icon: Icons.remove_red_eye_rounded,
                              color: Color(0xFF6FA8FF),
                              value: '3,620',
                              label: 'Total Views',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ChatPillButton(
                  label: 'Back to Home',
                  icon: Icons.home_rounded,
                  height: 50,
                  onTap: widget.onHome,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Drawn stand-in for assets/endchat.png: gold mic medallion with a crown and a ribbon.
class _EndedEmblem extends StatelessWidget {
  final double size;
  const _EndedEmblem({required this.size});

  @override
  Widget build(BuildContext context) {
    final medal = size * 0.66;
    return SizedBox(
      height: size,
      width: size * 1.7,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: size * 0.1,
            child: Container(
              width: medal,
              height: medal,
              padding: EdgeInsets.all(medal * 0.05),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [LuxeColors.goldLight, LuxeColors.goldDeep, LuxeColors.gold, LuxeColors.goldLight],
                ),
                boxShadow: [BoxShadow(color: Color(0x88FFC928), blurRadius: 26)],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Color(0xFF3A2A8C), Color(0xFF120D3A)]),
                ),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: LuxeColors.goldGradient.createShader,
                  child: Icon(Icons.mic_rounded, color: Colors.white, size: medal * 0.55),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Icon(
              Icons.workspace_premium_rounded,
              color: LuxeColors.gold,
              size: size * 0.24,
              shadows: const [Shadow(color: Color(0xAAFFC928), blurRadius: 10)],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: size * 0.16, vertical: size * 0.045),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [LuxeColors.purple, LuxeColors.violet, LuxeColors.purple]),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: LuxeColors.gold, width: 1.4),
                boxShadow: const [BoxShadow(color: Color(0x667B4DFF), blurRadius: 12)],
              ),
              child: Text(
                'CHAT ROOM ENDED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostCard extends StatelessWidget {
  final ChatRoom room;
  const _HostCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return LuxePanel(
      radius: 20,
      borderColors: LuxeColors.goldToNeon,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              GoldRingAvatar(asset: room.avatar, radius: 26),
              Positioned(
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                  decoration: LuxeDecor.goldButton(radius: 8),
                  child: const Text(
                    'Host',
                    style: TextStyle(color: kGoldInk, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        room.hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (room.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, color: LuxeColors.gold, size: 15),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                GoldTagPill(text: room.tag, icon: room.tagIcon, fontSize: 10.5),
                const SizedBox(height: 4),
                Text(
                  room.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: LuxeColors.textMuted, fontSize: 11.5),
                ),
                const SizedBox(height: 2),
                const Text('Sep 16, 2026 10:45 PM', style: TextStyle(color: LuxeColors.textDim, fontSize: 10.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return LuxePanel(
      radius: 20,
      glow: 8,
      borderColors: [color.withValues(alpha: 0.85), LuxeColors.purple.withValues(alpha: 0.6)],
      padding: const EdgeInsets.all(8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 34,
              shadows: [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 10)],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: const TextStyle(color: LuxeColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
