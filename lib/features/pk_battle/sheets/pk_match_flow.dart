// Opponent matchmaking flow (random / search, request, countdown).

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_models.dart';
import 'pk_sheets.dart';

const Color _gold = Color(0xFFFFD600);

/// A creator that can be challenged.
class PkOpponent {
  final String name;
  final String avatarAsset;
  final String videoAsset;
  final String viewers;

  const PkOpponent(this.name, this.avatarAsset, this.videoAsset, this.viewers);
}

/// Opponent search flow:
/// Choose mode → (Random matching → Match found) | (Search & select → Send request → Waiting)
/// → Opponent accepted 3·2·1 → [onMatched].
class PkMatchFlow {
  final BuildContext context;
  final PkHost host;
  final ValueChanged<PkOpponent> onMatched;
  final VoidCallback onOpenSettings;

  PkMatchFlow({required this.context, required this.host, required this.onMatched, required this.onOpenSettings});

  static const List<PkOpponent> _liveCreators = [
    PkOpponent('Riya', AppAssets.status4, AppAssets.video2, '28.4K'),
    PkOpponent('Arjun', AppAssets.status5, AppAssets.video1, '22.1K'),
    PkOpponent('Simran', AppAssets.status1, AppAssets.video3, '18.7K'),
    PkOpponent('Karthik', AppAssets.status2, AppAssets.video4, '16.5K'),
    PkOpponent('Pooja', AppAssets.status3, AppAssets.video5, '14.3K'),
    PkOpponent('Vikram', AppAssets.status5, AppAssets.video6, '12.1K'),
  ];

  static const PkOpponent _randomMatch = PkOpponent('Arjun', AppAssets.status5, AppAssets.video1, '8.3K');

  void start() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ChooseModeSheet(
        onRandom: () => _next(ctx, _showRandomMatching),
        onSearch: () => _next(ctx, _showSearchAndSelect),
        onRules: () => _next(ctx, () => PkSheets.showRules(context)),
        onSettings: () => _next(ctx, onOpenSettings),
      ),
    );
  }

  /// Closes the current route and continues the flow if the screen is still alive.
  void _next(BuildContext routeContext, VoidCallback then) {
    Navigator.pop(routeContext);
    if (context.mounted) then();
  }

  void _showRandomMatching() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (ctx) => _RandomMatchingSheet(onFound: () => _next(ctx, () => _showMatchFound(_randomMatch))),
    );
  }

  void _showMatchFound(PkOpponent rival) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (ctx) => _GoldDialog(
        children: [
          const Text('👥', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          const Text(
            'Match Found!',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Waiting for the other creator to accept...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AvatarWithLabel(asset: host.avatarAsset, name: host.name, subtitle: '💛 ${host.likes}'),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x88FFD600), blurRadius: 10)],
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 14),
              _AvatarWithLabel(asset: rival.avatarAsset, name: rival.name, subtitle: '💛 ${rival.viewers}'),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 2),
              color: const Color(0x33FFD600),
            ),
            child: const Text(
              '15s',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 22),
          PkPrimaryButton(label: 'Accept PK', onPressed: () => _next(ctx, () => _showAcceptedCountdown(rival))),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _next(
              ctx,
              () => PkSheets.showBanner(
                context,
                title: 'PK Declined',
                message: 'You declined the PK match.',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFFF5252),
              ),
            ),
            child: const Text(
              'Decline',
              style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchAndSelect() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) =>
          _SearchSelectSheet(creators: _liveCreators, onChallenge: (c) => _next(ctx, () => _showSendRequest(c))),
    );
  }

  void _showSendRequest(PkOpponent rival) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _GoldDialog(
        children: [
          _GoldRingAvatar(asset: rival.avatarAsset, radius: 44),
          const SizedBox(height: 12),
          Text(
            rival.name,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '💛 ${rival.viewers} viewers',
            style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            'Send PK Request?',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${rival.name} will receive a request to join PK battle.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 12.5),
          ),
          const SizedBox(height: 22),
          PkPrimaryButton(label: 'Send Request', onPressed: () => _next(ctx, () => _showWaiting(rival))),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showWaiting(PkOpponent rival) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (ctx) => _WaitingDialog(rival: rival, onAccepted: () => _next(ctx, () => _showAcceptedCountdown(rival))),
    );
  }

  void _showAcceptedCountdown(PkOpponent rival) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (ctx) => _AcceptedCountdownDialog(rival: rival, onDone: () => _next(ctx, () => onMatched(rival))),
    );
  }
}

class _ChooseModeSheet extends StatelessWidget {
  final VoidCallback onRandom;
  final VoidCallback onSearch;
  final VoidCallback onRules;
  final VoidCallback onSettings;

  const _ChooseModeSheet({
    required this.onRandom,
    required this.onSearch,
    required this.onRules,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return PkSheet(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
              boxShadow: [BoxShadow(color: Color(0x88FFD600), blurRadius: 18, spreadRadius: 2)],
            ),
            child: const Text('⚔️', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 10),
          const Text(
            'PK Battle',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          const Text('Choose a way to find your opponent', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 22),
          _ModeOption(
            leading: const Text('🎲', style: TextStyle(fontSize: 26)),
            title: 'Random Matching',
            subtitle: 'Find a random live creator',
            onTap: onRandom,
          ),
          const SizedBox(height: 14),
          _ModeOption(
            leading: const Icon(Icons.search_rounded, color: _gold, size: 28),
            title: 'Search & Select',
            subtitle: 'Find and invite a specific creator',
            onTap: onSearch,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LinkButton(icon: Icons.shield_outlined, label: 'PK Rules', color: _gold, onTap: onRules),
              const SizedBox(width: 28),
              _LinkButton(icon: Icons.settings_outlined, label: 'Settings', color: Colors.white70, onTap: onSettings),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeOption({required this.leading, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF261D07), Color(0xFF140E02)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x33FFD600), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: _gold.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
              child: leading,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: _gold, size: 16),
          ],
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LinkButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Icon(Icons.chevron_right_rounded, color: color, size: 16),
        ],
      ),
    );
  }
}

class _RandomMatchingSheet extends StatefulWidget {
  final VoidCallback onFound;
  const _RandomMatchingSheet({required this.onFound});

  @override
  State<_RandomMatchingSheet> createState() => _RandomMatchingSheetState();
}

class _RandomMatchingSheetState extends State<_RandomMatchingSheet> {
  static const _nearby = [
    AppAssets.status1,
    AppAssets.status2,
    AppAssets.status3,
    AppAssets.status4,
    AppAssets.status5,
    AppAssets.status1,
  ];

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2800), widget.onFound);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PkSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎲', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 6),
          const Text(
            'Random Matching',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text('Finding a live creator for you...', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 28),
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final (size, alpha) in const [(240.0, 0x33), (170.0, 0x66)])
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _gold.withAlpha(alpha), width: 1.5),
                    ),
                  ),
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
                    boxShadow: [BoxShadow(color: Color(0xAAFFD600), blurRadius: 24, spreadRadius: 2)],
                  ),
                  child: const Text(
                    'Searching...',
                    style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
                for (var i = 0; i < _nearby.length; i++)
                  Transform.translate(
                    offset: Offset.fromDirection(i / _nearby.length * 2 * pi, 95),
                    child: _GoldRingAvatar(asset: _nearby[i], radius: 18, ringWidth: 1.8),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "Please wait, we'll find the best match for you.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          PkSecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _SearchSelectSheet extends StatefulWidget {
  final List<PkOpponent> creators;
  final ValueChanged<PkOpponent> onChallenge;

  const _SearchSelectSheet({required this.creators, required this.onChallenge});

  @override
  State<_SearchSelectSheet> createState() => _SearchSelectSheetState();
}

class _SearchSelectSheetState extends State<_SearchSelectSheet> {
  static const _tabs = ['Live Now', 'Recommended', 'Following'];
  String _selectedTab = _tabs.first;

  @override
  Widget build(BuildContext context) {
    return PkSheet(
      accent: const Color(0x6600E5FF),
      maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      child: Column(
        children: [
          const PkSheetTitle('Search & Select'),
          const SizedBox(height: 14),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF181822),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                SizedBox(width: 10),
                Text('Search creators (name or ID)', style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final tab in _tabs)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TabChip(
                    label: tab,
                    selected: tab == _selectedTab,
                    onTap: () => setState(() => _selectedTab = tab),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: widget.creators.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _CreatorTile(creator: widget.creators[i], onChallenge: () => widget.onChallenge(widget.creators[i])),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _gold : const Color(0xFF1A1A26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _gold : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CreatorTile extends StatelessWidget {
  final PkOpponent creator;
  final VoidCallback onChallenge;

  const _CreatorTile({required this.creator, required this.onChallenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              _GoldRingAvatar(asset: creator.avatarAsset, radius: 22, ringWidth: 1.5, glow: false),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator.name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '💛 ${creator.viewers} viewers',
                  style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              elevation: 4,
              shadowColor: const Color(0x66FFD600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            ),
            onPressed: onChallenge,
            child: const Text('PK', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _WaitingDialog extends StatefulWidget {
  final PkOpponent rival;
  final VoidCallback onAccepted;

  const _WaitingDialog({required this.rival, required this.onAccepted});

  @override
  State<_WaitingDialog> createState() => _WaitingDialogState();
}

class _WaitingDialogState extends State<_WaitingDialog> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), widget.onAccepted);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GoldDialog(
      children: [
        const _GoldOrb(size: 72, child: Text('✈️', style: TextStyle(fontSize: 34))),
        const SizedBox(height: 16),
        const Text(
          'PK Request Sent!',
          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.rival.name} will be notified. Please wait...',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x33FFD600),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold),
          ),
          child: const Text(
            '30s',
            style: TextStyle(color: _gold, fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 22),
        PkSecondaryButton(label: 'Cancel Request', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

class _AcceptedCountdownDialog extends StatefulWidget {
  final PkOpponent rival;
  final VoidCallback onDone;

  const _AcceptedCountdownDialog({required this.rival, required this.onDone});

  @override
  State<_AcceptedCountdownDialog> createState() => _AcceptedCountdownDialogState();
}

class _AcceptedCountdownDialogState extends State<_AcceptedCountdownDialog> {
  int _count = 3;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count > 1) {
        setState(() => _count--);
      } else {
        t.cancel();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GoldDialog(
      children: [
        _GoldRingAvatar(asset: widget.rival.avatarAsset, radius: 36, ringWidth: 2, glow: false),
        const SizedBox(height: 12),
        const Text(
          'Opponent Accepted!',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Get ready! PK is starting...', style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 20),
        _GoldOrb(
          size: 76,
          child: Text(
            '$_count',
            style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _GoldDialog extends StatelessWidget {
  final List<Widget> children;
  const _GoldDialog({required this.children});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF14101E),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _gold, width: 1.8),
          boxShadow: const [BoxShadow(color: Color(0x66FFD600), blurRadius: 28, spreadRadius: 2)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _GoldOrb extends StatelessWidget {
  final double size;
  final Widget child;
  const _GoldOrb({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
        boxShadow: [BoxShadow(color: Color(0xCCFFD600), blurRadius: 22, spreadRadius: 2)],
      ),
      child: child,
    );
  }
}

class _GoldRingAvatar extends StatelessWidget {
  final String asset;
  final double radius;
  final double ringWidth;
  final bool glow;

  const _GoldRingAvatar({required this.asset, required this.radius, this.ringWidth = 2.5, this.glow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _gold, width: ringWidth),
        boxShadow: glow ? const [BoxShadow(color: Color(0x88FFD600), blurRadius: 12)] : null,
      ),
      child: CustomAvatar(radius: radius, assetPath: asset),
    );
  }
}

class _AvatarWithLabel extends StatelessWidget {
  final String asset;
  final String name;
  final String subtitle;

  const _AvatarWithLabel({required this.asset, required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GoldRingAvatar(asset: asset, radius: 36),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
