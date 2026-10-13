// Command section: Command List, input bar and the lower panel.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../../live_stream/domain/models/live_comment.dart';
import '../core/pk_common_widgets.dart';
import '../core/pk_models.dart';

/// Full-width bottom area on one background that runs to the screen edge:
///   [Command List ...............] [Gift card | ♥ Like | ↪ Share]
///   [😊] [Type a message...] [•••]
class PkLowerSection extends StatelessWidget {
  final Widget commandList;
  final Widget rightColumn;
  final Widget inputBar;

  const PkLowerSection({super.key, required this.commandList, required this.rightColumn, required this.inputBar});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 8 + bottomInset),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF0171340), LuxeColors.bg, LuxeColors.bgBottom],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: const Color(0x77FFC928)),
        boxShadow: const [
          BoxShadow(color: Color(0x447B4DFF), blurRadius: 24, offset: Offset(0, -4)),
          BoxShadow(color: Color(0x22FFC928), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rightWidth = (constraints.maxWidth * 0.27).clamp(92.0, 130.0);
          return Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: commandList),
                    const SizedBox(width: 8),
                    SizedBox(width: rightWidth, child: rightColumn),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              inputBar,
            ],
          );
        },
      ),
    );
  }
}

/// "Command List" panel: header with a Live pill, then comments (newest at the bottom).
class PkCommandList extends StatelessWidget {
  final List<LiveComment> comments;
  final ScrollController controller;
  final VoidCallback onLiveTap;

  const PkCommandList({super.key, required this.comments, required this.controller, required this.onLiveTap});

  @override
  Widget build(BuildContext context) {
    return PkNeonBox(
      radius: 22,
      borderColors: LuxeColors.goldToNeon,
      glow: const Color(0x337B4DFF),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  const PkGradientIcon(
                    Icons.sms_outlined,
                    size: 22,
                    colors: [LuxeColors.goldLight, LuxeColors.goldDeep],
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Comment List',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _LivePill(onTap: onLiveTap),
                ],
              ),
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
              child: ListView.separated(
                controller: controller,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                itemCount: comments.length,
                separatorBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(left: 46),
                  child: Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                ),
                itemBuilder: (_, index) => _CommandRow(comment: comments[comments.length - 1 - index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  final VoidCallback onTap;
  const _LivePill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
        decoration: BoxDecoration(
          color: LuxeColors.gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2EE59D),
                boxShadow: [BoxShadow(color: Color(0xAA2EE59D), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Live',
              style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  final LiveComment comment;
  const _CommandRow({required this.comment});

  static final DateFormat _time = DateFormat('hh:mm a');
  static const _ringColors = [LuxeColors.gold, LuxeColors.violet, LuxeColors.blue, LuxeColors.pink];

  bool get _isGift => comment.type == LiveCommentType.gift || comment.message.startsWith('sent ');
  bool get _isVip => PkDemoData.vipNames.contains(comment.userName);

  @override
  Widget build(BuildContext context) {
    final ring = _ringColors[comment.userName.codeUnits.fold<int>(0, (a, b) => a + b) % _ringColors.length];
    final messageColor = _isGift ? LuxeColors.gold : const Color(0xFFCDBBFF);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(1.8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 1.8),
              boxShadow: [BoxShadow(color: ring.withValues(alpha: 0.45), blurRadius: 8)],
            ),
            child: CustomAvatar(radius: 15, assetPath: comment.userAssetPath ?? AppAssets.status4),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (_isVip) ...[const SizedBox(width: 5), const PkGoldCrown(size: 13)],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: messageColor, fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _time.format(comment.timestamp),
              style: const TextStyle(color: LuxeColors.textDim, fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// [😊] [Type a message...] [•••]
class PkInputBar extends StatelessWidget {
  final VoidCallback onEmojiTap;
  final VoidCallback onMessageTap;
  final VoidCallback onMoreTap;

  const PkInputBar({super.key, required this.onEmojiTap, required this.onMessageTap, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return PkNeonBox(
      radius: 32,
      borderColors: LuxeColors.goldToNeon,
      padding: const EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final circle = (constraints.maxWidth / 8.2).clamp(36.0, 46.0);
          return Row(
            children: [
              PkPanelCircle(
                size: circle,
                accent: LuxeColors.gold,
                onTap: onEmojiTap,
                label: 'Emoji',
                child: Icon(Icons.sentiment_satisfied_alt_rounded, color: LuxeColors.gold, size: circle * 0.62),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onMessageTap,
                  child: Container(
                    height: circle,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E0B2C),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: LuxeColors.purple.withValues(alpha: 0.55)),
                    ),
                    child: const Text(
                      'Type a message...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: LuxeColors.textDim, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PkPanelCircle(
                size: circle,
                accent: LuxeColors.violet,
                onTap: onMoreTap,
                label: 'More',
                child: Icon(Icons.more_horiz_rounded, color: Colors.white, size: circle * 0.55),
              ),
            ],
          );
        },
      ),
    );
  }
}
