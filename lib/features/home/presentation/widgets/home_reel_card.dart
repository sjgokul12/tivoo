import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/comment_action_sheet.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../core/widgets/reel_media_view.dart';
import '../../../live_stream/data/mock_live_comments.dart';
import '../../../live_stream/domain/models/live_comment.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import '../../../live_stream/presentation/widgets/star_up_bottom_sheet.dart';
import '../../domain/models/live_stream_card_model.dart';
import 'streamer_id_profile_sheet.dart';

class HomeReelCard extends StatefulWidget {
  final LiveStreamCardModel stream;
  final bool isActive;
  final VoidCallback? onCardTap;
  final VoidCallback? onFollowTap;

  const HomeReelCard({super.key, required this.stream, this.isActive = true, this.onCardTap, this.onFollowTap});

  @override
  State<HomeReelCard> createState() => _HomeReelCardState();
}

class _HomeReelCardState extends State<HomeReelCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FloatingHeartsOverlayState> _heartsKey = GlobalKey();
  bool _isLiked = false;
  bool _isMuted = true;
  bool _isCommentsPaused = false;
  Timer? _commentsTicker;
  late final AnimationController _likeAnimController;
  late final Animation<double> _likeScaleAnimation;
  late final List<LiveComment> _comments;
  late final ScrollController _commentsScrollController;

  @override
  void initState() {
    super.initState();
    _commentsScrollController = ScrollController();
    _comments = List<LiveComment>.from(MockLiveComments.initialComments);

    _likeAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeAnimController, curve: Curves.easeInOut));

    // Initial scroll to bottom of comments after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_commentsScrollController.hasClients) {
        _commentsScrollController.jumpTo(_commentsScrollController.position.maxScrollExtent);
      }
    });

    _startCommentsTicker();
  }

  @override
  void didUpdateWidget(covariant HomeReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startCommentsTicker();
      } else {
        _commentsTicker?.cancel();
      }
    }
  }

  void _startCommentsTicker() {
    _commentsTicker?.cancel();
    if (!widget.isActive) return;
    _commentsTicker = Timer.periodic(const Duration(milliseconds: 3800), (_) {
      if (!mounted || _isCommentsPaused || !widget.isActive) return;
      final pool = MockLiveComments.automatedIncomingPool;
      final template = pool[DateTime.now().second % pool.length];
      setState(() {
        _comments.add(
          LiveComment(
            id: 'auto_video_${DateTime.now().millisecondsSinceEpoch}',
            userName: template.userName,
            userAvatarUrl: template.userAvatarUrl,
            message: template.message,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToLatestComment();
    });
  }

  void _handleHoldComment(LiveComment comment) {
    CommentActionSheet.show(
      context,
      comment: comment,
      onPause: () {
        setState(() => _isCommentsPaused = true);
      },
      onResume: () {
        setState(() => _isCommentsPaused = false);
      },
      onReported: () {
        setState(() {
          final idx = _comments.indexWhere((c) => c.id == comment.id);
          if (idx != -1) {
            _comments[idx] = _comments[idx].copyWith(
              message: 'This comment has been reported',
              isReported: true,
            );
          }
        });
      },
      onBlocked: () {
        setState(() {
          _comments.removeWhere((c) => c.userName == comment.userName);
        });
      },
    );
  }

  @override
  void dispose() {
    _commentsTicker?.cancel();
    _commentsScrollController.dispose();
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _comments.add(
          LiveComment(
            id: 'like_${DateTime.now().millisecondsSinceEpoch}',
            userName: 'You',
            message: 'liked the LIVE ❤️',
            type: LiveCommentType.like,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToLatestComment();
    }
    _likeAnimController.forward(from: 0.0);
    _heartsKey.currentState?.addHeart();
    _heartsKey.currentState?.addHeart();
  }

  void _handleLikeToggle() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _comments.add(
          LiveComment(
            id: 'like_${DateTime.now().millisecondsSinceEpoch}',
            userName: 'You',
            message: 'liked the LIVE ❤️',
            type: LiveCommentType.like,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
    if (_isLiked) {
      _likeAnimController.forward(from: 0.0);
      _heartsKey.currentState?.addHeart();
      _scrollToLatestComment();
    }
  }

  void _scrollToLatestComment() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_commentsScrollController.hasClients) {
        _commentsScrollController.animateTo(
          _commentsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleStarTap() {
    StarUpBottomSheet.show(
      context,
      streamerName: widget.stream.streamerName,
      onSendStars: (multiplier) {
        setState(() {
          _comments.add(
            LiveComment(
              id: 'star_${DateTime.now().millisecondsSinceEpoch}',
              userName: 'You',
              message: 'sent $multiplier Stars! ⭐',
              type: LiveCommentType.star,
              starsCount: multiplier,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToLatestComment();
        _heartsKey.currentState?.addHeart();
      },
    );
  }

  void _handleGiftTap() {
    GiftBottomSheet.show(context, (gift) {
      setState(() {
        _comments.add(
          LiveComment(
            id: 'gift_${DateTime.now().millisecondsSinceEpoch}',
            userName: 'You',
            message: 'sent ${gift.name} ${gift.icon}!',
            type: LiveCommentType.gift,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToLatestComment();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent ${gift.name} ${gift.icon} to ${widget.stream.streamerName}! 🎁'),
          duration: const Duration(seconds: 1),
        ),
      );
      _heartsKey.currentState?.addHeart();
    });
  }

  void _handleCommentTap() {
    _showLiveCommentInputSheet();
  }

  void _showLiveCommentInputSheet() {
    final textController = TextEditingController();
    final sheetScrollController = ScrollController();
    const quickEmojis = [
      '❤️', '😍', '🔥', '👏', '⭐', '🎉', '🌹', '💯', '😂', '✨',
      '🙌', '🥰', '🥳', '😎', '💖', '🤩', '👍', '🎁', '👑', '💃',
    ];

    setState(() => _isCommentsPaused = true);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xF5101424),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void insertEmoji(String emoji) {
              final text = textController.text;
              final selection = textController.selection;
              if (selection.start >= 0 && selection.end >= 0) {
                final newText = text.replaceRange(selection.start, selection.end, emoji);
                textController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: selection.start + emoji.length),
                );
              } else {
                textController.text += emoji;
                textController.selection = TextSelection.collapsed(offset: textController.text.length);
              }
            }

            return Container(
              height: MediaQuery.sizeOf(context).height * 0.65,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(ctx).bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Drag Handle
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header with Comment count and close
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Comments',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_comments.length}',
                                style: const TextStyle(color: AppColors.primaryYellow, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 16),

                  // Comments List (Hold to report or delete!)
                  Expanded(
                    child: _comments.isEmpty
                        ? const Center(
                            child: Text(
                              'No comments yet. Say something! 💬',
                              style: TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            controller: sheetScrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            itemCount: _comments.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return GestureDetector(
                                onLongPress: () {
                                  _handleHoldComment(comment);
                                  setModalState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomAvatar(
                                        radius: 15,
                                        imageUrl: comment.userAvatarUrl,
                                        assetPath: comment.userAssetPath ?? AppAssets.status4,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  comment.userName,
                                                  style: const TextStyle(
                                                    color: AppColors.primaryYellow,
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  '• Just now',
                                                  style: TextStyle(color: Colors.white38, fontSize: 10.5),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              comment.message,
                                              style: TextStyle(
                                                color: comment.isReported ? Colors.white54 : Colors.white,
                                                fontStyle: comment.isReported ? FontStyle.italic : FontStyle.normal,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Column(
                                        children: [
                                          Icon(Icons.favorite_border_rounded, size: 16, color: Colors.white38),
                                          SizedBox(height: 2),
                                          Text('0', style: TextStyle(color: Colors.white38, fontSize: 10)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Input Bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF161B2E),
                      border: Border(top: BorderSide(color: Colors.white12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick Emojis
                        SizedBox(
                          height: 32,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: quickEmojis.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 6),
                            itemBuilder: (context, index) {
                              final emoji = quickEmojis[index];
                              return GestureDetector(
                                onTap: () => insertEmoji(emoji),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(emoji, style: const TextStyle(fontSize: 16)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: textController,
                                autofocus: false,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.08),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                ),
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    _postComment(val.trim());
                                    textController.clear();
                                    setModalState(() {});
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send_rounded, color: AppColors.primaryYellow),
                              onPressed: () {
                                if (textController.text.trim().isNotEmpty) {
                                  _postComment(textController.text.trim());
                                  textController.clear();
                                  setModalState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() => _isCommentsPaused = false);
    });
  }

  void _postComment(String message) {
    setState(() {
      _comments.add(
        LiveComment(
          id: 'home_c_${DateTime.now().millisecondsSinceEpoch}',
          userName: 'You',
          message: message,
          timestamp: DateTime.now(),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_commentsScrollController.hasClients) {
        _commentsScrollController.animateTo(
          _commentsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comment posted to ${widget.stream.streamerName}\'s live! 💬'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleShareTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied to share ${widget.stream.streamerName}\'s live!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Full-screen edge-to-edge live video card (no inset box, no border, pure reels UX)
    return FloatingHeartsOverlay(
      key: _heartsKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _handleDoubleTap,
        onTap: widget.onCardTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-Bleed Live Video / Image Media
            Positioned.fill(child: _buildCoverMedia()),

            // 2. Cinematic Vignette Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x88000000), Colors.transparent, Colors.transparent, Color(0xCC000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.2, 0.50, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Top Badges: LIVE, Viewers (100M), Diamonds (24.2K), Mute (Positioned below upside live broadcasters)
            Positioned(
              top: MediaQuery.of(context).padding.top + 135,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: LIVE + Viewers Count + Active Viewers Photos
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.stream.isLive) ...[const LiveBadge(), const SizedBox(width: 5)],
                          MetricBadge(
                            text: widget.stream.viewersCount,
                            icon: const Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 5),
                          // Upside Active Viewers' Profile Photos ("malla yaru yella pakuragalo avuga photo varanu")
                          _buildViewersAvatarStack(),
                        ],
                      ),
                    ),
                  ),

                  // Right: Diamonds + Mute Toggle
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MetricBadge(
                        text: widget.stream.diamondsCount,
                        icon: const Text('💎', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() => _isMuted = !_isMuted);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.55),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                          ),
                          child: Icon(
                            _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Center Double-Tap Pop Heart Animation
            Center(
              child: ScaleTransition(
                scale: _likeScaleAnimation,
                child: _likeAnimController.isAnimating
                    ? const Icon(Icons.favorite_rounded, color: Color(0xFFFF2D55), size: 96)
                    : const SizedBox.shrink(),
              ),
            ),

            // 5. Right Action Column: Like, Live Chat, Gift, Share
            Positioned(
              right: 12,
              bottom: 96,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Like Button
                  _buildActionButton(
                    icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: _isLiked ? const Color(0xFFFF2D55) : Colors.white,
                    label: widget.stream.diamondsCount,
                    onTap: _handleLikeToggle,
                  ),
                  const SizedBox(height: 12),

                  // Separate Star Button (⭐)
                  _buildActionButton(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFFD700),
                    label: 'Star',
                    onTap: _handleStarTap,
                  ),
                  const SizedBox(height: 12),

                  // Separate Gift Button (🎁)
                  _buildActionButton(
                    icon: Icons.card_giftcard_rounded,
                    iconColor: const Color(0xFFFF4081),
                    label: 'Gift',
                    onTap: _handleGiftTap,
                  ),
                  const SizedBox(height: 12),

                  // Comment Button
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: Colors.white,
                    label: 'Chat',
                    onTap: _handleCommentTap,
                  ),
                  const SizedBox(height: 12),

                  // Share Button
                  _buildActionButton(
                    icon: Icons.share_rounded,
                    iconColor: Colors.white,
                    label: 'Share',
                    onTap: _handleShareTap,
                  ),
                ],
              ),
            ),

            // 6. Streamer Profile Pic, LIVE Button & Live Comments Overlay
            Positioned(
              left: 14,
              right: 80,
              bottom: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Streamer Avatar + Bottom LIVE Comment Button ("athukulla killa live button iruku atha click pana comment varu")
                  Row(
                    children: [
                      // Profile Pic (Tap opens Creator ID Profile)
                      GestureDetector(
                        key: const Key('streamer_avatar_button'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          StreamerIdProfileSheet.show(context, stream: widget.stream);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFDF00), width: 2.0),
                            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 2))],
                          ),
                          child: CustomAvatar(
                            radius: 20,
                            assetPath: widget.stream.streamerAssetPath,
                            imageUrl: widget.stream.streamerAvatarUrl,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Bottom LIVE Button for Comments
                      GestureDetector(
                        key: const Key('live_chat_open_button'),
                        onTap: _handleCommentTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFF2D55), Color(0xFFFF5252)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: Color(0x66FF2D55), blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 13),
                              SizedBox(width: 5),
                              Text(
                                'LIVE Chat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Live Comments Overlay
                  _buildLiveCommentsOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Viewers Profile Photos Stack ("malla yaru yella pakuragalo avuga photo varanu")
  Widget _buildViewersAvatarStack() {
    const viewerAssets = [AppAssets.status1, AppAssets.status2, AppAssets.status4];

    return SizedBox(
      height: 22,
      width: 42,
      child: Stack(
        children: List.generate(viewerAssets.length, (i) {
          return Positioned(
            left: i * 11.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 3)],
              ),
              child: CustomAvatar(radius: 8.5, assetPath: viewerAssets[i]),
            ),
          );
        }),
      ),
    );
  }

  /// Real-time live comments overlay directly on the live stream video card
  Widget _buildLiveCommentsOverlay() {
    return SizedBox(
      height: 115,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black, Colors.black],
          stops: [0.0, 0.25, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          controller: _commentsScrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _comments.length,
          itemBuilder: (context, index) {
            final comment = _comments[index];

            // Star sent comment pill ("star poduraga athulaiyavaruna provide like that")
            if (comment.type == LiveCommentType.star) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () => _handleHoldComment(comment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0x99FFDF00), Color(0x66E65100)]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFDF00), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFDF00), size: 15),
                          const SizedBox(width: 5),
                          Flexible(
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${comment.userName} ',
                                    style: const TextStyle(
                                      color: Color(0xFFFFDF00),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: comment.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // Like sent comment pill ("like poduravuga name varanu")
            if (comment.type == LiveCommentType.like) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () => _handleHoldComment(comment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0x66FF2D55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x99FF2D55), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_rounded, color: Color(0xFFFF2D55), size: 13),
                          const SizedBox(width: 5),
                          Flexible(
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${comment.userName} ',
                                    style: const TextStyle(
                                      color: Color(0xFFFF6482),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: comment.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // Regular Chat comment
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onLongPress: () => _handleHoldComment(comment),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomAvatar(radius: 10, imageUrl: comment.userAvatarUrl, assetPath: comment.userAssetPath),
                        const SizedBox(width: 6),
                        Flexible(
                          child: RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${comment.userName}: ',
                                  style: const TextStyle(
                                    color: AppColors.primaryYellow,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: comment.message,
                                  style: TextStyle(
                                    color: comment.isReported ? Colors.white54 : Colors.white,
                                    fontStyle: comment.isReported ? FontStyle.italic : FontStyle.normal,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    shadows: const [Shadow(color: Colors.black87, blurRadius: 3)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCoverMedia() {
    return ReelMediaView(
      videoAssetPath: widget.stream.videoAssetPath,
      coverAssetPath: widget.stream.coverAssetPath,
      coverImageUrl: widget.stream.coverImageUrl,
      isActive: widget.isActive,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}
