// Comment section: outer glassmorphic panel with tubular neon comment capsules,
// the star gift portal with floating 3D hearts, and the glowing input bar matching Image 1.

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../../live_stream/domain/models/live_comment.dart';
import '../core/pk_common_widgets.dart';
import '../core/pk_models.dart';

/// Lower part of the screen:
///   ┌ grand glassmorphic neon panel ─────────┐
///   │ (comment pills ...)        ♥  ♥        │
///   │                          (★ portal)    │
///   └────────────────────────────────────────┘
///   [😊 Type a messa... 😊]  (Like) (Share)
class PkLowerSection extends StatelessWidget {
  final Widget commandList;
  final Widget rightColumn;
  final Widget inputBar;

  const PkLowerSection({super.key, required this.commandList, required this.rightColumn, required this.inputBar});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final viewInsetsBottom = media.viewInsets.bottom;
    final isKeyboardOpen = viewInsetsBottom > 50;
    final isSmall = media.size.width < 376;
    final isShort = media.size.height < 700;
    final bottomPadding = media.padding.bottom;
    final effectiveBottom = isKeyboardOpen
        ? 4.0
        : (bottomPadding > 0 ? (bottomPadding + 2.0).clamp(4.0, 24.0) : (isSmall ? 4.0 : 6.0));
    final horizontalPad = isSmall ? 8.0 : 10.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutQuad,
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontalPad, 0, horizontalPad, effectiveBottom),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final circle = (constraints.maxWidth / 9.8).clamp(34.0, 42.0);
            final rightWidth = circle;
            // While typing only the input bar is shown. The input bar must stay
            // the last child of this same Column in both states: moving it to
            // another parent rebuilds the TextField and closes the keyboard.
            final hasEnoughHeight = !isKeyboardOpen && constraints.maxHeight >= (circle + 36.0);
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasEnoughHeight)
                  Expanded(
                    child: _GlassCommentPanel(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: commandList),
                          const SizedBox(width: 8.0),
                          SizedBox(width: rightWidth, child: rightColumn),
                        ],
                      ),
                    ),
                  ),
                if (hasEnoughHeight) SizedBox(height: isShort ? 4.0 : (isSmall ? 6.0 : 8.0)),
                KeyedSubtree(key: const ValueKey('pk_input_bar'), child: inputBar),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Grand outer glassmorphic container enclosing both the comments and the star gift portal,
/// with deep frosted glass blur, dual-tone cyan/magenta neon border, and curved specular reflections.
class _GlassCommentPanel extends StatelessWidget {
  final Widget child;
  const _GlassCommentPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(4, 2, 0, 2), child: child);
  }
}

/// Live comments as pills, newest at the bottom, fading out at the top of the panel.
class PkCommandList extends StatelessWidget {
  final List<LiveComment> comments;
  final ScrollController controller;
  final ValueChanged<LiveComment>? onUserTap;
  final ValueChanged<LiveComment>? onUserLongPress;
  final VoidCallback? onLiveTap;

  const PkCommandList({
    super.key,
    required this.comments,
    required this.controller,
    this.onUserTap,
    this.onUserLongPress,
    this.onLiveTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.white, Colors.white],
        stops: [0, 0.08, 1],
      ).createShader,
      child: ListView.builder(
        controller: controller,
        reverse: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: comments.length,
        itemBuilder: (_, index) {
          final comment = comments[comments.length - 1 - index];
          final gift = PkGiftEvent.fromChatMessage(
            id: index,
            sender: comment.userName,
            avatar: comment.userAssetPath ?? AppAssets.status4,
            message: comment.message,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: gift != null
                  ? _GiftCommentPill(
                      gift: gift,
                      onTap: () => onUserTap?.call(comment),
                      onLongPress: () => onUserLongPress?.call(comment),
                    )
                  : _CommentPill(
                      comment: comment,
                      onTap: () => onUserTap?.call(comment),
                      onLongPress: () => onUserLongPress?.call(comment),
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Neon style per viewer (stable for the same name): pill border colours and name colour.
typedef _NeonStyle = ({List<Color> border, Color name});

const List<_NeonStyle> _styles = [
  (border: [Color(0xFFFF5CE1), Color(0xFFB04DFF)], name: Color(0xFFFF82DC)), // pink/magenta (Sneha)
  (border: [Color(0xFF00E5FF), Color(0xFF2E7BFF)], name: Color(0xFF00E5FF)), // cyan/blue (Vicky)
  (border: [Color(0xFF9E47FF), Color(0xFF00E5FF)], name: Color(0xFFC4B5FD)), // purple/blue (Ananya)
  (border: [Color(0xFF00E5FF), Color(0xFFFF2DC0)], name: Color(0xFFFF82DC)), // cyan/magenta (Meena)
];

_NeonStyle _styleFor(String name) {
  if (name == 'System') {
    return (border: const [Color(0xFFFFD600), Color(0xFFFF2DC0)], name: const Color(0xFFFFD600));
  }
  return _styles[name.codeUnits.fold<int>(0, (a, b) => a + b) % _styles.length];
}

/// Pill with the neon tubular gradient border, glassmorphism fill and top specular gloss.
class _Pill extends StatelessWidget {
  final String avatar;
  final Widget content;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final List<Color> border;
  const _Pill({
    required this.avatar,
    required this.content,
    required this.onTap,
    this.onLongPress,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    const avatarRadius = 13.5;
    final primaryColor = border.first;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(1.3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: border),
          boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.45), blurRadius: 10, spreadRadius: 0.5)],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xDD121652), Color(0xBB0A0D32)],
              stops: [0, 1],
            ),
          ),
          child: Stack(
            children: [
              // Specular curved glass gloss reflection on the upper curve
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.35), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(3, 3, 10, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1.2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: border),
                        boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.5), blurRadius: 6)],
                      ),
                      child: CustomAvatar(radius: avatarRadius, assetPath: avatar),
                    ),
                    const SizedBox(width: 7),
                    Flexible(child: content),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// (avatar) Name 👑 / message
class _CommentPill extends StatelessWidget {
  final LiveComment comment;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _CommentPill({required this.comment, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final isVip = PkDemoData.vipNames.contains(comment.userName);
    final style = _styleFor(comment.userName);
    return _Pill(
      avatar: comment.userAssetPath ?? AppAssets.status4,
      onTap: onTap,
      onLongPress: onLongPress,
      border: style.border,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  comment.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: style.name, fontSize: 12.0, fontWeight: FontWeight.w800, height: 1.15),
                ),
              ),
              if (comment.userName == 'System') ...[
                const SizedBox(width: 3.5),
                const Icon(Icons.verified_rounded, color: Color(0xFFFFD600), size: 12),
              ] else if (isVip) ...[
                const SizedBox(width: 3.5),
                const PkGoldCrown(size: 11),
              ],
            ],
          ),
          Text(
            comment.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: comment.isReported ? Colors.white54 : Colors.white,
              fontStyle: comment.isReported ? FontStyle.italic : FontStyle.normal,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// (avatar) Name sent Oce... 💎 x1
class _GiftCommentPill extends StatelessWidget {
  final PkGiftEvent gift;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _GiftCommentPill({required this.gift, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    const iconSize = 18.0;
    final giftIcon = gift.giftImage != null
        ? Image.asset(
            gift.giftImage!,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(gift.emoji, style: const TextStyle(fontSize: iconSize * 0.8)),
          )
        : Text(gift.emoji, style: const TextStyle(fontSize: iconSize * 0.8));

    final style = _styleFor(gift.sender);
    return _Pill(
      avatar: gift.senderAvatar,
      onTap: onTap,
      onLongPress: onLongPress,
      border: style.border,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: gift.sender,
                    style: TextStyle(color: style.name, fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: ' sent ${gift.giftName}'),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 4),
          giftIcon,
          const SizedBox(width: 3),
          Text(
            'x${gift.count}',
            style: const TextStyle(
              color: Color(0xFFFFD23F),
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              shadows: [Shadow(color: Color(0x99FFB300), blurRadius: 8)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Input row: [😊 Type a messa... 😊] (Like) (Share) (Wallet)
class PkInputBar extends StatefulWidget {
  final VoidCallback onEmojiTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onWalletTap;
  final ValueChanged<String>? onSend;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const PkInputBar({
    super.key,
    required this.onEmojiTap,
    this.onLikeTap,
    this.onShareTap,
    this.onMoreTap,
    this.onWalletTap,
    this.onSend,
    this.controller,
    this.focusNode,
  });

  @override
  State<PkInputBar> createState() => _PkInputBarState();
}

class _PkInputBarState extends State<PkInputBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isKeyboard = MediaQuery.viewInsetsOf(context).bottom > 50;
        final circle = (constraints.maxWidth / 9.8).clamp(36.0, 42.0);
        const emojiColor = Color(0xFFFFD600);

        return Row(
          children: [
            Expanded(
              child: Container(
                height: circle,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(circle / 2),
                  border: Border.all(color: _hasText ? const Color(0xFFFFD23F) : const Color(0xFF00E5FF), width: 1.5),
                  gradient: const LinearGradient(colors: [Color(0xDD0D113C), Color(0xBB080B28)]),
                  boxShadow: const [BoxShadow(color: Color(0x5500E5FF), blurRadius: 10, spreadRadius: 0.5)],
                ),
                child: Stack(
                  children: [
                    // Specular curved glass gloss along top half of the input capsule
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: circle * 0.45,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(circle / 2)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white.withValues(alpha: 0.30), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _InlineIcon(
                          size: circle - 4,
                          label: 'Emoji',
                          onTap: widget.onEmojiTap,
                          child: Icon(Icons.sentiment_satisfied_alt_outlined, color: emojiColor, size: circle * 0.52),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            cursorColor: const Color(0xFFFFD23F),
                            cursorWidth: 2.2,
                            textAlignVertical: TextAlignVertical.center,
                            keyboardAppearance: Brightness.dark,
                            textInputAction: TextInputAction.send,
                            keyboardType: TextInputType.text,
                            enableSuggestions: true,
                            autocorrect: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Color(0xFF8E9BCC), fontSize: 13.5),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _hasText
                              ? _InlineIcon(
                                  key: const ValueKey('send'),
                                  size: circle - 4,
                                  label: 'Send',
                                  onTap: _send,
                                  child: const Icon(Icons.send_rounded, color: Color(0xFFFFD23F), size: 18),
                                )
                              : const SizedBox(key: ValueKey('none'), width: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!isKeyboard) ...[
              SizedBox(width: circle * 0.14),
              _LabeledCircle(
                size: circle,
                label: 'Share',
                ring: const Color(0xFF00E5FF),
                fill: const [Color(0xFF2E6BE0), Color(0xFF102A80)],
                onTap: widget.onShareTap,
                icon: Icon(Icons.shortcut_rounded, color: Colors.white, size: circle * 0.44),
              ),
              if (widget.onMoreTap != null) ...[
                SizedBox(width: circle * 0.14),
                _LabeledCircle(
                  size: circle,
                  label: 'More',
                  ring: const Color(0xFFFFD54F),
                  fill: const [Color(0xFF38236B), Color(0xFF19103C)],
                  onTap: widget.onMoreTap,
                  icon: Icon(Icons.more_horiz_rounded, color: const Color(0xFFFFD54F), size: circle * 0.5),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

/// Emoji / send button inside the message pill.
class _InlineIcon extends StatelessWidget {
  final double size;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  const _InlineIcon({super.key, required this.size, required this.label, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Round neon button with the icon above a small label (Like / Share / Wallet).
class _LabeledCircle extends StatelessWidget {
  final double size;
  final String label;
  final Color ring;
  final List<Color> fill;
  final Widget icon;
  final VoidCallback? onTap;

  const _LabeledCircle({
    required this.size,
    required this.label,
    required this.ring,
    required this.fill,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: fill),
            border: Border.all(color: ring, width: 1.6),
            boxShadow: [BoxShadow(color: ring.withValues(alpha: 0.7), blurRadius: 10)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(height: size * 0.02),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(color: Colors.white, fontSize: size * 0.19, fontWeight: FontWeight.w700, height: 1.05),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
