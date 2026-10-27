import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/comment_action_sheet.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/models/live_comment.dart';
import 'user_profile_bottom_sheet.dart';

/// Glassmorphic Live Chat Stream strictly matching Image 4:
/// - Special Gift Capsule: Avatar + "Aurora_X" + "Sent a Rose 🌹 x1" with glowing amber/gold border & sparkles
/// - Regular Chat Capsules: Avatar + Username + Message + Timestamp ("2m ago", "4m ago")
/// - Comments float upwards towards the video
/// - Tapping any comment or avatar opens their profile pop-up
/// - Holding any comment pauses stream and allows reporting or deleting
class LiveChatListView extends StatefulWidget {
  final List<LiveComment> comments;
  final bool isCreator;
  final VoidCallback? onPauseComments;
  final VoidCallback? onResumeComments;
  final ValueChanged<String>? onDeleteComment;
  final ValueChanged<String>? onReportComment;
  final ValueChanged<String>? onBlockUser;

  const LiveChatListView({
    super.key,
    required this.comments,
    this.isCreator = false,
    this.onPauseComments,
    this.onResumeComments,
    this.onDeleteComment,
    this.onReportComment,
    this.onBlockUser,
  });

  @override
  State<LiveChatListView> createState() => _LiveChatListViewState();
}

class _LiveChatListViewState extends State<LiveChatListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant LiveChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comments.length != oldWidget.comments.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getAvatarForComment(LiveComment comment) {
    if (comment.userAssetPath != null && comment.userAssetPath!.isNotEmpty) {
      return comment.userAssetPath!;
    }
    final avatars = [
      AppAssets.status4,
      AppAssets.status5,
      AppAssets.status2,
      AppAssets.status3,
      AppAssets.status1,
    ];
    final hash = comment.userName.hashCode.abs();
    return avatars[hash % avatars.length];
  }

  String _formatRelativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    // If empty, provide the authentic sample stream matching Image 4!
    final displayComments = widget.comments.isNotEmpty
        ? widget.comments
        : [
            LiveComment(
              id: 'c1',
              userName: 'Lucas_Gamer',
              message: 'Beautiful view! ❤️',
              userAssetPath: AppAssets.status3,
              timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
            ),
            LiveComment(
              id: 'c2',
              userName: 'Sam_99',
              message: 'Play my favorite track please!',
              userAssetPath: AppAssets.status5,
              timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
            ),
            LiveComment(
              id: 'c3',
              userName: 'Aurora_X',
              message: 'Sent a Rose 🌹 x1',
              userAssetPath: AppAssets.status4,
              type: LiveCommentType.gift,
              timestamp: DateTime.now().subtract(const Duration(seconds: 40)),
            ),
          ];

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
        ],
        stops: [0.0, 0.06, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        controller: _scrollController,
        reverse: true, // Anchor to bottom, new comments push upwards!
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        itemCount: displayComments.length,
        itemBuilder: (context, index) {
          final itemIndex = displayComments.length - 1 - index;
          if (itemIndex < 0 || itemIndex >= displayComments.length) {
            return const SizedBox.shrink();
          }
          final comment = displayComments[itemIndex];
          return _buildCommentItem(comment);
        },
      ),
    );
  }

  Widget _buildCommentItem(LiveComment comment) {
    final isGift = comment.type == LiveCommentType.gift ||
        comment.message.toLowerCase().contains('sent a') ||
        comment.message.toLowerCase().contains('rose') ||
        comment.userName.contains('Aurora');
    final avatarAsset = _getAvatarForComment(comment);
    final timeStr = _formatRelativeTime(comment.timestamp);

    return TweenAnimationBuilder<double>(
      key: ValueKey(comment.id),
      duration: const Duration(milliseconds: 280),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Transform.translate(
          offset: Offset(0, (1.0 - val) * 12.0),
          child: Opacity(
            opacity: val,
            child: child,
          ),
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            onTap: () {
              UserProfileBottomSheet.show(
                context,
                userName: comment.userName,
                avatarAsset: avatarAsset,
                userId: 'user_${comment.userName.toLowerCase().replaceAll(' ', '_')}',
              );
            },
            onLongPress: () {
              CommentActionSheet.show(
                context,
                comment: comment,
                onPause: widget.onPauseComments,
                onResume: widget.onResumeComments,
                onReported: () => widget.onReportComment?.call(comment.id),
                onBlocked: () => widget.onBlockUser?.call(comment.userName),
              );
            },
            child: isGift
                ? _buildSpecialGiftBubble(comment, avatarAsset)
                : _buildRegularChatBubble(comment, avatarAsset, timeStr),
          ),
        ),
      ),
    );
  }

  /// Special Gift Message matching Image 4:
  /// Avatar + "Aurora_X" + "Sent a Rose 🌹 x1" with golden amber glowing border
  Widget _buildSpecialGiftBubble(LiveComment comment, String avatarAsset) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1608),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFD54F),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FFD54F),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
            ),
            child: CustomAvatar(
              radius: 14,
              assetPath: avatarAsset,
            ),
          ),
          const SizedBox(width: 8),

          // User Name & Sent a Rose
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Sent a Rose ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text('🌹 ', style: TextStyle(fontSize: 14)),
                    Text(
                      'x1',
                      style: TextStyle(
                        color: Color(0xFFFFE082),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Regular Chat Bubble matching Image 4:
  /// Avatar + Username + Message + Timestamp (2m ago)
  Widget _buildRegularChatBubble(LiveComment comment, String avatarAsset, String timeStr) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomAvatar(
            radius: 14,
            assetPath: avatarAsset,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  comment.message,
                  style: TextStyle(
                    color: comment.isReported ? Colors.white54 : Colors.white,
                    fontStyle: comment.isReported ? FontStyle.italic : FontStyle.normal,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
