// Opponent matchmaking flow: Random PK & Search PK.
// Conforms to Image 2 (Random PK flow) and Image 3 (Search PK flow).

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_models.dart';
import '../pk_battle_live_screen.dart';
import 'pk_sheets.dart';

const Color _gold = Color(0xFFFFD600);
const Color _neonBlue = Color(0xFF2E9BFF);

/// A creator that can be challenged or matched in PK.
class PkOpponent {
  final String name;
  final String avatarAsset;
  final String videoAsset;
  final String viewers;

  const PkOpponent(this.name, this.avatarAsset, this.videoAsset, this.viewers);
}

/// Matchmaking flow for PK Battle (Host perspective):
/// 1. PK Menu (Random PK / Search PK / Following Live)
/// 2. Duration selection (3m / 5m / 10m)
/// 3A. Random PK -> Searching radar -> Match found (3·2·1) -> Battle start
/// 3B. Search PK -> Creators list (search & filters) -> Send Request -> Opponent accepted -> (3·2·1) -> Battle start
class PkMatchFlow {
  final BuildContext context;
  final PkHost host;
  final ValueChanged<PkOpponent>? onMatched;
  final VoidCallback? onOpenSettings;

  PkMatchFlow({required this.context, required this.host, this.onMatched, this.onOpenSettings});

  static const List<PkOpponent> liveCreators = [
    PkOpponent('Anitha', AppAssets.status4, AppAssets.video2, '2.5K watching'),
    PkOpponent('Karthik', AppAssets.status2, AppAssets.video4, '980 watching'),
    PkOpponent('Vicky', AppAssets.status5, AppAssets.video6, '860 watching'),
    PkOpponent('Nila', AppAssets.avatarSneha, AppAssets.video1, '1.1K watching'),
    PkOpponent('Saran', AppAssets.avatarSaran, AppAssets.video3, '640 watching'),
    PkOpponent('Arjun', AppAssets.status5, AppAssets.video1, '8.3K watching'),
    PkOpponent('Priya', AppAssets.avatarPriya, AppAssets.video2, '12.4K watching'),
  ];

  static const PkOpponent randomRival = PkOpponent('Arjun', AppAssets.status5, AppAssets.video1, '8.3K');

  void start() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PkMenuSheet(
        onRandom: () => _next(ctx, () => _openDuration(isRandom: true)),
        onSearch: () => _next(ctx, () => _openDuration(isRandom: false)),
        onFollowing: () => _next(ctx, () => _openDuration(isRandom: false)),
      ),
    );
  }

  void _next(BuildContext routeContext, VoidCallback then) {
    Navigator.pop(routeContext);
    if (context.mounted) then();
  }

  void _openDuration({required bool isRandom}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PkDurationSheet(
        isRandom: isRandom,
        onDurationSelected: (seconds) {
          if (isRandom) {
            _next(ctx, () => _startRandomSearching(seconds));
          } else {
            _next(ctx, () => _openCreatorsList(seconds));
          }
        },
      ),
    );
  }

  void _startRandomSearching(int durationSeconds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _PkSearchingSheet(
        durationSeconds: durationSeconds,
        onFound: () => _next(ctx, () => _showMatchFound(randomRival, durationSeconds)),
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _openCreatorsList(int durationSeconds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PkCreatorsListSheet(
        durationSeconds: durationSeconds,
        creators: liveCreators,
        onSelectCreator: (rival) => _next(ctx, () => _showSendRequest(rival, durationSeconds)),
      ),
    );
  }

  void _showSendRequest(PkOpponent rival, int durationSeconds) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _PkSendRequestDialog(
        rival: rival,
        durationSeconds: durationSeconds,
        onSend: () => _next(ctx, () => _simulateInviteResponse(rival, durationSeconds)),
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _simulateInviteResponse(PkOpponent rival, int durationSeconds) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('🎉 ${rival.name} accepted your PK Battle invitation!'),
          backgroundColor: const Color(0xFF00C853),
          duration: const Duration(seconds: 2),
        ),
      );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (context.mounted) {
        _showMatchFound(rival, durationSeconds);
      }
    });
  }

  void _showMatchFound(PkOpponent rival, int durationSeconds) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (ctx) => _PkMatchFoundDialog(
        host: host,
        rival: rival,
        durationSeconds: durationSeconds,
        onStartBattle: () {
          Navigator.pop(ctx);
          _startBattle(rival, durationSeconds);
        },
      ),
    );
  }

  void _startBattle(PkOpponent rival, int durationSeconds) {
    if (onMatched != null) {
      onMatched!(rival);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PkBattleLiveScreen(
          match: PkMatch(
            id: 'pk_${host.name.toLowerCase()}_${rival.name.toLowerCase()}',
            left: host,
            right: PkHost(
              name: rival.name,
              avatarAsset: rival.avatarAsset,
              videoAsset: rival.videoAsset,
              likes: rival.viewers,
              viewers: rival.viewers,
            ),
            status: PkMatchStatus.ongoing,
            viewers: '12.4K',
            cover: AppAssets.pkCoverPriyaAnu,
            leftScore: 12540,
            rightScore: 9870,
            secondsLeft: durationSeconds,
          ),
          // The host started this battle, so they get the streamer screen.
          isCreator: true,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Step 2: PK Menu Sheet (Image 2 & 3 Step 2)
// -----------------------------------------------------------------------------

class _PkMenuSheet extends StatelessWidget {
  final VoidCallback onRandom;
  final VoidCallback onSearch;
  final VoidCallback onFollowing;

  const _PkMenuSheet({required this.onRandom, required this.onSearch, required this.onFollowing});

  @override
  Widget build(BuildContext context) {
    return PkSheet(
      accent: _gold,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(AppAssets.pkTopBanner, height: 38, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MenuCard(
            gradientColors: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            icon: Icons.shuffle_rounded,
            title: 'Random PK',
            subtitle: 'Auto match with live creators',
            isHighlighted: true,
            onTap: onRandom,
          ),
          const SizedBox(height: 12),
          _MenuCard(
            gradientColors: const [Color(0xFF0072FF), Color(0xFF00C6FF)],
            icon: Icons.search_rounded,
            title: 'Search PK',
            subtitle: 'Find and invite your opponent',
            onTap: onSearch,
          ),
          const SizedBox(height: 12),
          _MenuCard(
            gradientColors: const [Color(0xFF00897B), Color(0xFF43A047)],
            icon: Icons.favorite_rounded,
            title: 'Following Live',
            subtitle: 'PK with your followers',
            onTap: onFollowing,
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _MenuCard({
    required this.gradientColors,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF16152B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted ? _gold : Colors.white.withValues(alpha: 0.12),
            width: isHighlighted ? 1.8 : 1,
          ),
          boxShadow: isHighlighted ? [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 14)] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: gradientColors),
                boxShadow: [BoxShadow(color: gradientColors.first.withValues(alpha: 0.5), blurRadius: 10)],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12.5)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Step 3: Select Duration Sheet (Image 2 & 3 Step 3)
// -----------------------------------------------------------------------------

class _PkDurationSheet extends StatefulWidget {
  final bool isRandom;
  final ValueChanged<int> onDurationSelected;

  const _PkDurationSheet({required this.isRandom, required this.onDurationSelected});

  @override
  State<_PkDurationSheet> createState() => _PkDurationSheetState();
}

class _PkDurationSheetState extends State<_PkDurationSheet> {
  int _selectedMinutes = 5;

  @override
  Widget build(BuildContext context) {
    return PkSheet(
      accent: _gold,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.isRandom ? 'Random PK' : 'Search PK',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Select PK Duration',
                style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            _durationTile(3, '3 Minutes'),
            const SizedBox(height: 12),
            _durationTile(5, '5 Minutes'),
            const SizedBox(height: 12),
            _durationTile(10, '10 Minutes'),
            const SizedBox(height: 12),
            _durationTile(15, '15 Minutes'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isRandom
                          ? 'You will be matched with other creators who also selected $_selectedMinutes Minutes.'
                          : 'This duration will be sent with your PK request.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 6,
                  shadowColor: _gold.withValues(alpha: 0.5),
                ),
                onPressed: () => widget.onDurationSelected(_selectedMinutes * 60),
                child: Text(
                  widget.isRandom ? 'Start Random PK' : 'Next',
                  style: const TextStyle(color: Color(0xFF1F1400), fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _durationTile(int minutes, String label) {
    final isSelected = _selectedMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _selectedMinutes = minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF281335) : const Color(0xFF16152B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _gold : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: _gold.withValues(alpha: 0.3), blurRadius: 10)] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? _gold : Colors.white54, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            const Icon(Icons.access_time_rounded, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Step 4A: Finding Match Sheet (Image 2 Step 4)
// -----------------------------------------------------------------------------

class _PkSearchingSheet extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onFound;
  final VoidCallback onCancel;

  const _PkSearchingSheet({required this.durationSeconds, required this.onFound, required this.onCancel});

  @override
  State<_PkSearchingSheet> createState() => _PkSearchingSheetState();
}

class _PkSearchingSheetState extends State<_PkSearchingSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _searchTimer = Timer(const Duration(milliseconds: 2600), widget.onFound);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.durationSeconds ~/ 60;
    return PkSheet(
      accent: _neonBlue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Searching for PK Match...',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 26),
          // Radar pulse with shuffle icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final val = _pulseController.value;
              return SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90 + 50 * val,
                      height: 90 + 50 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF8E2DE2).withValues(alpha: 1 - val), width: 2),
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                        boxShadow: [BoxShadow(color: const Color(0xFF8E2DE2).withValues(alpha: 0.6), blurRadius: 18)],
                      ),
                      child: const Icon(Icons.shuffle_rounded, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _checkItem('Looking for live creators'),
          const SizedBox(height: 8),
          _checkItem('Matching same duration ($minutes Minutes)'),
          const SizedBox(height: 8),
          _checkItem('Please wait...'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: widget.onCancel,
              child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _checkItem(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Step 4B: Live Creators List (Image 3 Step 4)
// -----------------------------------------------------------------------------

class _PkCreatorsListSheet extends StatefulWidget {
  final int durationSeconds;
  final List<PkOpponent> creators;
  final ValueChanged<PkOpponent> onSelectCreator;

  const _PkCreatorsListSheet({required this.durationSeconds, required this.creators, required this.onSelectCreator});

  @override
  State<_PkCreatorsListSheet> createState() => _PkCreatorsListSheetState();
}

class _PkCreatorsListSheetState extends State<_PkCreatorsListSheet> {
  String _searchQuery = '';
  String _activeTab = 'All Live';

  List<PkOpponent> get _filteredCreators {
    return widget.creators.where((c) {
      if (_searchQuery.isNotEmpty && !c.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PkSheet(
      accent: _neonBlue,
      maxHeight: MediaQuery.sizeOf(context).height * 0.84,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Search PK',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Search box
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1A30),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (q) => setState(() => _searchQuery = q),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search creator...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13.5),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Category tabs
          Row(
            children: ['All Live', 'Following', 'Popular'].map((tab) {
              final active = _activeTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? _gold : const Color(0xFF1B1A30),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: active ? [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 8)] : null,
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: active ? const Color(0xFF1F1400) : Colors.white,
                        fontSize: 12.5,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Creators list
          Expanded(
            child: ListView.separated(
              itemCount: _filteredCreators.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final creator = _filteredCreators[index];
                return _creatorRow(creator);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _creatorRow(PkOpponent creator) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16152B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [_gold, _neonBlue]),
            ),
            child: CustomAvatar(radius: 20, assetPath: creator.avatarAsset),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator.name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(creator.viewers, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              elevation: 4,
              shadowColor: _gold.withValues(alpha: 0.4),
            ),
            onPressed: () => widget.onSelectCreator(creator),
            child: const Text(
              'Invite',
              style: TextStyle(color: Color(0xFF1F1400), fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Step 5B: Send Request Confirmation Dialog (Image 3 Step 5)
// -----------------------------------------------------------------------------

class _PkSendRequestDialog extends StatelessWidget {
  final PkOpponent rival;
  final int durationSeconds;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const _PkSendRequestDialog({
    required this.rival,
    required this.durationSeconds,
    required this.onSend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = durationSeconds ~/ 60;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF16152B),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _gold, width: 1.5),
          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send PK Request',
              style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_gold, _neonBlue]),
              ),
              child: CustomAvatar(radius: 36, assetPath: rival.avatarAsset),
            ),
            const SizedBox(height: 10),
            Text(
              rival.name,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(rival.viewers, style: const TextStyle(color: Colors.white54, fontSize: 12.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, color: _gold, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'PK Duration: $minutes Minutes',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                  elevation: 6,
                  shadowColor: _gold.withValues(alpha: 0.5),
                ),
                onPressed: onSend,
                child: const Text(
                  'Send Request',
                  style: TextStyle(color: Color(0xFF1F1400), fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Step 5A / 7B: Match Found & Countdown Dialog (Image 2 Step 5 & Image 3 Step 7)
// -----------------------------------------------------------------------------

class _PkMatchFoundDialog extends StatefulWidget {
  final PkHost host;
  final PkOpponent rival;
  final int durationSeconds;
  final VoidCallback onStartBattle;

  const _PkMatchFoundDialog({
    required this.host,
    required this.rival,
    required this.durationSeconds,
    required this.onStartBattle,
  });

  @override
  State<_PkMatchFoundDialog> createState() => _PkMatchFoundDialogState();
}

class _PkMatchFoundDialogState extends State<_PkMatchFoundDialog> {
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        widget.onStartBattle();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.durationSeconds ~/ 60;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF141026),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _gold, width: 2),
          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 24)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Match Found!',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 22),
            // Face-off row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Host
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _gold, width: 2),
                      ),
                      child: CustomAvatar(radius: 34, assetPath: widget.host.avatarAsset),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.host.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    Text('$minutes Minutes', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 16),
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
                const SizedBox(width: 16),
                // Opponent
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _neonBlue, width: 2),
                      ),
                      child: CustomAvatar(radius: 34, assetPath: widget.rival.avatarAsset),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.rival.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    Text('$minutes Minutes', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text(
                    'PK Starts In',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_countdown',
                    style: const TextStyle(color: _gold, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
