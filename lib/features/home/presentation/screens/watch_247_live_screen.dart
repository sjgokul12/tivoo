import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/reel_media_view.dart';
import '../../../live_stream/data/mock_live_comments.dart';
import '../../../live_stream/domain/models/gift_item.dart';
import '../../../live_stream/domain/models/live_comment.dart';
import '../../../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_stars_overlay.dart';
import '../../../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import '../../../live_stream/presentation/widgets/live_bottom_input_bar.dart';
import '../../../live_stream/presentation/widgets/live_chat_list_view.dart';
import '../../../live_stream/presentation/widgets/star_up_bottom_sheet.dart';

class Watch247LiveScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const Watch247LiveScreen({super.key, this.onBack});

  @override
  State<Watch247LiveScreen> createState() => _Watch247LiveScreenState();
}

class _Watch247LiveScreenState extends State<Watch247LiveScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ActiveGiftAnimationOverlayState> _activeGiftKey = GlobalKey();
  final GlobalKey<FloatingHeartsOverlayState> _heartsKey = GlobalKey();
  final GlobalKey<FloatingStarsOverlayState> _starsKey = GlobalKey();

  late final List<LiveComment> _comments;
  bool _isFollowing = false;
  bool _isCommentsPaused = false;
  GiftItem? _activeGiftBanner;
  Timer? _commentTimer;
  int _diamondsCount = 888450;

  final List<String> _simulatedChatters = [
    'Sophia: Welcome everyone! 💕',
    'Julia: This room is on fire 🔥',
    'Layla: Amazing streamer!',
    'Admin Maya: love your energy today ✨',
    'Alex: Sent you love from Tokyo!',
    'Noah: Top 1 streamer in Tivoo 👑',
    'Emma: That song was breathtaking!',
  ];
  int _simulatedIndex = 0;

  @override
  void initState() {
    super.initState();
    _comments = List<LiveComment>.from(MockLiveComments.initialComments);

    // Auto-stream comments periodically down side
    _commentTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _isCommentsPaused) return;
      final raw = _simulatedChatters[_simulatedIndex % _simulatedChatters.length];
      _simulatedIndex++;
      final parts = raw.split(': ');
      setState(() {
        _comments.add(
          LiveComment(
            id: 'auto_${DateTime.now().millisecondsSinceEpoch}',
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
      streamerName: 'Cordelia',
      onSendStars: (multiplier) {
        setState(() {
          _diamondsCount += multiplier * 10;
          _comments.add(
            LiveComment(
              id: 'star_${DateTime.now().millisecondsSinceEpoch}',
              userName: 'You',
              message: 'sent $multiplier Stars! ⭐✨',
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
        _activeGiftBanner = gift;
        _comments.add(
          LiveComment(
            id: 'gift_${DateTime.now().millisecondsSinceEpoch}',
            userName: 'You',
            message: 'sent ${gift.name} ${gift.icon} (x8291)!',
            type: LiveCommentType.gift,
            timestamp: DateTime.now(),
          ),
        );
      });
      _activeGiftKey.currentState?.playGift(gift);
      _heartsKey.currentState?.addHeart();
      _heartsKey.currentState?.addHeart();

      Future.delayed(const Duration(milliseconds: 3800), () {
        if (mounted) setState(() => _activeGiftBanner = null);
      });
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

  @override
  Widget build(BuildContext context) {
    return ActiveGiftAnimationOverlay(
      key: _activeGiftKey,
      child: FloatingStarsOverlay(
        key: _starsKey,
        child: FloatingHeartsOverlay(
          key: _heartsKey,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Live Video / Cover Background
              const Positioned.fill(
                child: ReelMediaView(
                  videoAssetPath: AppAssets.video1,
                  coverAssetPath: AppAssets.status1,
                  isActive: true,
                ),
              ),

              // 2. Cinematic Vignette Gradient
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xB3000000), Colors.transparent, Colors.transparent, Color(0xEB000000)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.18, 0.50, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Top Info Overlay (Streamer info, Bonus Center, Viewers)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Streamer Capsule (Avatar + Name + Heat + Follow)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CustomAvatar(radius: 16, assetPath: AppAssets.status1),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Cordelia',
                                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'ID: UID-849201',
                                    style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _isFollowing = !_isFollowing);
                                },
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _isFollowing
                                        ? const LinearGradient(colors: [Colors.grey, Colors.blueGrey])
                                        : const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
                                  ),
                                  child: Icon(_isFollowing ? Icons.check : Icons.add, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right: Viewers Avatars Stack + Count + Close
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTopViewersStack(),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                '999',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: widget.onBack,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Sub-Row: Diamonds Counter & Bonus Center
                    Row(
                      children: [
                        // Diamonds / Stars Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0x99AA00FF), Color(0x996200EA)]),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFF4081), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('💎', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 5),
                              Text(
                                '${(_diamondsCount / 1000).toStringAsFixed(1)}K',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Bonus Center Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0x9900B0FF), Color(0x990091EA)]),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF40C4FF), width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🎁', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 4),
                              Text(
                                'Bonus Center',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Lucky Win Ticker ("Isaac Douglas win 88888 from...")
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xB31B5E20), Color(0x80004D40)]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF69F0AE), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8F00)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '500 TIMES',
                              style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const CustomAvatar(radius: 9, assetPath: AppAssets.status2),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              'Isaac Douglas win 88888 from Wheel ✨',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Dynamic Gift Animation Banner Overlay (Image 1 & 5)
              Positioned(
                left: 14,
                right: 14,
                bottom: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_activeGiftBanner != null) ...[
                      _buildSVIPGiftFlyover('You', _activeGiftBanner!.name, _activeGiftBanner!.icon, 'x8291'),
                      const SizedBox(height: 8),
                    ],
                    // Default SVIP banner from Image 1
                    _buildSVIPGiftFlyover('Ray', 'helicopter', '🚁', 'x8291', badge: '600 TIMES'),
                  ],
                ),
              ),

              // 5. Downside Live Comments Feed & Controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Live Comments Feed down side
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: SizedBox(
                            height: 250,
                            width: MediaQuery.sizeOf(context).width * 0.78,
                            child: LiveChatListView(
                              comments: _comments,
                              onPauseComments: () => setState(() => _isCommentsPaused = true),
                              onResumeComments: () => setState(() => _isCommentsPaused = false),
                              onDeleteComment: (id) => setState(() => _comments.removeWhere((c) => c.id == id)),
                              onReportComment: (id) => setState(() {
                                final idx = _comments.indexWhere((c) => c.id == id);
                                if (idx != -1) {
                                  _comments[idx] = _comments[idx].copyWith(
                                    message: 'This comment has been reported',
                                    isReported: true,
                                  );
                                }
                              }),
                              onBlockUser: (userName) => setState(() {
                                _comments.removeWhere((c) => c.userName == userName);
                              }),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Bottom Bar with Comment input, separate Star, separate Gift
                      LiveBottomInputBar(
                        onSendComment: _handleSendComment,
                        onStarTap: _handleStarTap,
                        onGiftTap: _handleGiftTap,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopViewersStack() {
    const avatars = [AppAssets.status2, AppAssets.status3, AppAssets.status4];
    return SizedBox(
      width: 48,
      height: 24,
      child: Stack(
        children: List.generate(avatars.length, (i) {
          return Positioned(
            left: i * 12.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: CustomAvatar(radius: 9, assetPath: avatars[i]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSVIPGiftFlyover(String sender, String giftName, String giftIcon, String combo, {String? badge}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xEB4A148C), Color(0xCC880E4F), Color(0x99000000)]),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0x66FF2D55), blurRadius: 16, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomAvatar(radius: 14, assetPath: AppAssets.status5),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$sender send $giftName',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              if (badge != null)
                Text(
                  badge,
                  style: const TextStyle(color: Color(0xFFFFDF00), fontSize: 10, fontWeight: FontWeight.w900),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Text(giftIcon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            combo,
            style: const TextStyle(
              color: Color(0xFFFF4081),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
