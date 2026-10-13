import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/luxury_atmosphere_background.dart';
import '../../../live_stream/data/mock_live_comments.dart';
import '../../../live_stream/domain/models/live_comment.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_stars_overlay.dart';
import '../../../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../../../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import '../../../live_stream/presentation/widgets/live_bottom_input_bar.dart';
import '../../../live_stream/presentation/widgets/live_chat_list_view.dart';
import '../../../live_stream/presentation/widgets/star_up_bottom_sheet.dart';

class MultiCallLiveScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MultiCallLiveScreen({super.key, this.onBack});

  @override
  State<MultiCallLiveScreen> createState() => _MultiCallLiveScreenState();
}

class _MultiCallLiveScreenState extends State<MultiCallLiveScreen> {
  final GlobalKey<ActiveGiftAnimationOverlayState> _activeGiftKey = GlobalKey();
  final GlobalKey<FloatingHeartsOverlayState> _heartsKey = GlobalKey();
  final GlobalKey<FloatingStarsOverlayState> _starsKey = GlobalKey();

  late final List<LiveComment> _comments;
  Timer? _commentTimer;
  bool _isMicOn = true;
  int _diamondsCount = 888450;

  final List<String> _simulatedChatters = [
    'Alina: Your smile just made my day so much better ✨',
    'Kiara: Can\'t stop watching, this room is so fun!',
    'Alex Martin: Welcome everyone, good vibes tonight! 🎵',
    'Vera Jones: Love the multi-call setup 💕',
    'Marcus: Hello host & all guests!',
    'David: SSVIP king in the room 👑',
  ];
  int _simulatedIndex = 0;

  // 6 Interactive Seats Data
  final List<Map<String, dynamic>> _seats = [
    {'name': 'Alex Martin', 'diamonds': '5,099', 'asset': AppAssets.status2, 'isSSVIP': true, 'isSpeaking': true},
    {'name': 'Evelyn', 'diamonds': '6,921', 'asset': AppAssets.status3, 'isSSVIP': true, 'isSpeaking': false},
    {'name': 'Hulda Lewis', 'diamonds': '3,194', 'asset': AppAssets.status4, 'isSSVIP': false, 'isSpeaking': false},
    {'name': 'Kiara Fox', 'diamonds': '4,850', 'asset': AppAssets.status1, 'isSSVIP': false, 'isSpeaking': true},
    {'name': 'Leo Vance', 'diamonds': '2,410', 'asset': AppAssets.status5, 'isSSVIP': false, 'isSpeaking': false},
    {'name': 'Empty Seat', 'diamonds': '', 'asset': null, 'isSSVIP': false, 'isSpeaking': false, 'isEmpty': true},
  ];

  @override
  void initState() {
    super.initState();
    _comments = List<LiveComment>.from(MockLiveComments.initialComments);

    _commentTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final raw = _simulatedChatters[_simulatedIndex % _simulatedChatters.length];
      _simulatedIndex++;
      final parts = raw.split(': ');
      setState(() {
        _comments.add(
          LiveComment(
            id: 'multi_auto_${DateTime.now().millisecondsSinceEpoch}',
            userName: parts[0],
            message: parts[1],
            timestamp: DateTime.now(),
          ),
        );
      });
      _heartsKey.currentState?.addHeart();
    });
  }

  @override
  void dispose() {
    _commentTimer?.cancel();
    super.dispose();
  }

  void _handleStarTap() {
    StarUpBottomSheet.show(
      context,
      streamerName: 'Royan & Guests',
      onSendStars: (multiplier) {
        setState(() {
          _diamondsCount += multiplier * 10;
          _comments.add(
            LiveComment(
              id: 'star_${DateTime.now().millisecondsSinceEpoch}',
              userName: 'You',
              message: 'sent $multiplier Stars to Multi-Call! ⭐',
              type: LiveCommentType.star,
              starsCount: multiplier,
              timestamp: DateTime.now(),
            ),
          );
        });
        _starsKey.currentState?.addStars(multiplier.clamp(1, 10));
      },
    );
  }

  void _handleGiftTap() {
    GiftBottomSheet.show(context, (gift) {
      setState(() {
        _diamondsCount += gift.diamonds;
        _comments.add(
          LiveComment(
            id: 'gift_${DateTime.now().millisecondsSinceEpoch}',
            userName: 'You',
            message: 'sent ${gift.name} ${gift.icon} to room!',
            type: LiveCommentType.gift,
            timestamp: DateTime.now(),
          ),
        );
      });
      _activeGiftKey.currentState?.playGift(gift);
      _heartsKey.currentState?.addHeart();
      _heartsKey.currentState?.addHeart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You sent ${gift.name} to the multi-call room! 🎁'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void _handleSendComment(String text) {
    setState(() {
      _comments.add(
        LiveComment(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          userName: 'You',
          message: text,
          timestamp: DateTime.now(),
        ),
      );
    });
    _heartsKey.currentState?.addHeart();
  }

  void _handleSeatTap(int index) {
    if (_seats[index]['isEmpty'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mic request sent! Host will invite you to the stage.'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viewing ${_seats[index]['name']}\'s profile & gifts 🌟'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActiveGiftAnimationOverlay(
      key: _activeGiftKey,
      child: FloatingStarsOverlay(
        key: _starsKey,
        child: FloatingHeartsOverlay(
          key: _heartsKey,
          child: LuxuryAtmosphereBackground(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Subtle ambient glow
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.22),
                    ),
                  ),
                ),

                // Content Area
                SafeArea(
                  child: Column(
                    children: [
                      // 1. Top Bar (Host info, ID, Bonus Center, Viewers)
                      _buildTopHeader(),

                      const SizedBox(height: 8),

                      // 2. Multi-Person Video/Seat Grid (Image 2) & Upward Flowing Live Chat
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Multi-person grid (6-9 seats)
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: _buildSeatsGrid()),

                            const SizedBox(height: 6),

                            // Upward-Flowing Live Comments Feed ("malla poga")
                            Expanded(child: LiveChatListView(comments: _comments)),
                          ],
                        ),
                      ),

                      // 3. Downside Input Bar with Comment, Star, Gift, and Mic Toggle
                      Row(
                        children: [
                          Expanded(
                            child: LiveBottomInputBar(
                              onSendComment: _handleSendComment,
                              onStarTap: _handleStarTap,
                              onGiftTap: _handleGiftTap,
                            ),
                          ),
                          // Mic Button
                          Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isMicOn = !_isMicOn);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_isMicOn ? 'Mic unmuted 🎤' : 'Mic muted 🔇'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isMicOn ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isMicOn ? const Color(0xFF00E676) : const Color(0xFFFF5252)).withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(_isMicOn ? Icons.mic : Icons.mic_off, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Host Capsule: Royan + ID + Crown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0x99512DA8), Color(0x99311B92)]),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFB388FF), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomAvatar(radius: 16, assetPath: AppAssets.status1),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Royan',
                          style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        Text('ID 10026092', style: TextStyle(color: Colors.white70, fontSize: 9.5)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rate_rounded, color: Color(0xFFFFD700), size: 16),
                  ],
                ),
              ),

              // Right: Viewers & Close
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomAvatar(radius: 10, assetPath: AppAssets.status2),
                  const SizedBox(width: 3),
                  const CustomAvatar(radius: 10, assetPath: AppAssets.status3),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      '9423',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black45),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Sub-bar: Diamonds & Bonus Center
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: const Color(0x99D500F9), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      '${(_diamondsCount / 1000).toStringAsFixed(1)}K',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: const Color(0x9900B0FF), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎁', style: TextStyle(fontSize: 11)),
                    SizedBox(width: 4),
                    Text(
                      'Bonus Center',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.84,
      ),
      itemCount: _seats.length,
      itemBuilder: (context, index) {
        final seat = _seats[index];
        final isEmpty = seat['isEmpty'] == true;

        if (isEmpty) {
          return GestureDetector(
            onTap: () => _handleSeatTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline_rounded, color: Color(0xFFB388FF), size: 30),
                  SizedBox(height: 6),
                  Text(
                    'Take Seat',
                    style: TextStyle(color: Color(0xFFB388FF), fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _handleSeatTap(index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: seat['isSpeaking'] == true
                    ? const Color(0xFF00E676)
                    : const Color(0xFFB388FF).withValues(alpha: 0.4),
                width: seat['isSpeaking'] == true ? 2 : 1,
              ),
              boxShadow: seat['isSpeaking'] == true
                  ? [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.4), blurRadius: 10)]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(seat['asset'], fit: BoxFit.cover),
                  // Dark bottom gradient for name & diamonds readability
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xD9000000)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.45, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // SSVIP Badge at top left
                  if (seat['isSSVIP'] == true)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6F00)]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SSVIP',
                          style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),

                  // Mic Icon top right
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: Icon(
                        seat['isSpeaking'] == true ? Icons.mic : Icons.mic_off,
                        color: seat['isSpeaking'] == true ? const Color(0xFF00E676) : Colors.white60,
                        size: 11,
                      ),
                    ),
                  ),

                  // Diamonds and Name at bottom
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (seat['diamonds'].isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('💎', style: TextStyle(fontSize: 9)),
                              const SizedBox(width: 2),
                              Text(
                                seat['diamonds'],
                                style: const TextStyle(
                                  color: Color(0xFFFFDF00),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        Text(
                          seat['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
