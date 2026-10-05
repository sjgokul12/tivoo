import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/asset_video_player.dart';
import '../../../../core/widgets/crown_icon.dart';
import '../../../../core/widgets/floating_hearts.dart';
import '../../../../core/widgets/gloss.dart';
import '../../../../core/widgets/neon_ribbons.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../data/models/live_stream.dart';
import '../../../gifts/presentation/gift_sheet.dart';
import '../../providers/live_room_controller.dart';
import 'chat_input_bar.dart';
import 'gift_spotlight.dart';
import 'live_chat_list.dart';
import 'live_commands_bar.dart';
import 'live_gift_widgets.dart';
import 'live_top_bar.dart';

/// One full-screen live room inside the vertical feed. Every dynamic piece
/// is its own Consumer selecting just the slice it shows, so a new chat
/// message doesn't rebuild the video, top bar or buttons.
class LiveRoomPage extends ConsumerWidget {
  const LiveRoomPage({
    super.key,
    required this.stream,
    required this.isActive,
    required this.onOpenPk,
  });

  final LiveStream stream;
  final bool isActive;
  final VoidCallback onOpenPk;

  LiveRoomController _room(WidgetRef ref) => ref.read(liveRoomProvider(stream.id).notifier);

  void _sendSelection(BuildContext context, WidgetRef ref, GiftSelection selection) {
    if (!_room(ref).sendGift(selection)) {
      context.showAppSnackBar('Not enough coins for this gift');
    }
  }

  Future<void> _openGiftSheet(BuildContext context, WidgetRef ref) async {
    final selection = await GiftSheet.show(context);
    if (selection == null || !context.mounted) return;
    _sendSelection(context, ref, selection);
  }

  void _onCommand(BuildContext context, WidgetRef ref, LiveCommand command) {
    switch (command) {
      case LiveCommand.like:
        _room(ref).like();
      case LiveCommand.gift:
        _openGiftSheet(context, ref);
      case LiveCommand.follow:
        _room(ref).toggleFollow();
      case LiveCommand.share:
        copyLiveLink(context, stream.id);
    }
  }

  void _onSubmit(BuildContext context, WidgetRef ref, String text) {
    _room(ref).sendMessage(text);
    final command = LiveCommand.parse(text);
    if (command != null) _onCommand(context, ref, command);
  }

  /// "…" → glass sheet with the live chat commands.
  void _openCommands(BuildContext context, WidgetRef ref) {
    _showGlassSheet(
      context,
      title: 'Live Commands',
      child: LiveCommandsBar(
        onCommand: (command) {
          Navigator.of(context).pop();
          _onCommand(context, ref, command);
        },
      ),
    );
  }

  /// "⋮" → share / leave.
  void _openMenu(BuildContext context) {
    _showGlassSheet(
      context,
      title: stream.streamer.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetAction(
            icon: Icons.shortcut_rounded,
            label: 'Share live',
            onTap: () {
              Navigator.of(context).pop();
              copyLiveLink(context, stream.id);
            },
          ),
          _SheetAction(
            icon: Icons.logout_rounded,
            label: 'Leave live',
            onTap: () {
              Navigator.of(context)
                ..pop()
                ..maybePop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = liveRoomProvider(stream.id);
    final chatMaxHeight = (context.screenSize.height * 0.32).clamp(140.0, 320.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onDoubleTap: () => _room(ref).like(),
          child: AssetVideoPlayer(
            asset: stream.videoAsset,
            isActive: isActive,
            placeholder: AppImage(path: stream.thumbnail, cacheWidth: 400),
          ),
        ),
        const IgnorePointer(child: _Scrims()),
        const Positioned(left: 0, right: 0, bottom: 0, height: 220, child: NeonRibbons()),
        Builder(
          // Only the overlay reacts to the keyboard; the video stays put.
          builder: (context) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                child: Column(
                  children: [
                    LiveTopBar(stream: stream, onMenu: () => _openMenu(context)),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer(
                                  builder: (_, ref, _) => GiftBanner(
                                    message: ref.watch(provider.select((s) => s.lastGift)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: chatMaxHeight),
                                    child: Consumer(
                                      builder: (_, ref, _) => LiveChatList(
                                        messages: ref.watch(provider.select((s) => s.messages)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 112,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Both halves shrink on short screens instead of overflowing.
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.bottomRight,
                                    child: _SideActions(
                                      streamId: stream.id,
                                      onPk: onOpenPk,
                                      onGift: () => _openGiftSheet(context, ref),
                                      onShare: () => copyLiveLink(context, stream.id),
                                      onLike: () => _room(ref).like(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.bottomRight,
                                    child: Consumer(
                                      builder: (_, ref, _) => GiftSpotlight(
                                        message: ref.watch(provider.select((s) => s.lastGift)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.72,
                        child: ChatInputBar(onSubmit: (text) => _onSubmit(context, ref, text)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _RoundButton(icon: Icons.more_horiz_rounded, onTap: () => _openCommands(context, ref)),
                        const SizedBox(width: 10),
                        _RoundButton(icon: Icons.shortcut_rounded, onTap: () => copyLiveLink(context, stream.id)),
                        const Spacer(),
                        Flexible(
                          flex: 6,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: QuickGiftBar(
                              onSend: (gift, quantity) => _sendSelection(
                                context,
                                ref,
                                GiftSelection(gift: gift, quantity: quantity),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 300,
          width: 70,
          height: 320,
          child: Consumer(
            builder: (_, ref, _) => FloatingHearts(count: ref.watch(provider.select((s) => s.likes))),
          ),
        ),
      ],
    );
  }
}

class _SideActions extends StatelessWidget {
  const _SideActions({
    required this.streamId,
    required this.onPk,
    required this.onGift,
    required this.onShare,
    required this.onLike,
  });

  final String streamId;
  final VoidCallback onPk;
  final VoidCallback onGift;
  final VoidCallback onShare;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlowOrb(color: AppColors.gold, onTap: onPk, child: const CrownIcon(size: 22)),
        _GlowOrb(color: AppColors.pink, onTap: onGift, child: Image.asset(AppAssets.giftPink, width: 40)),
        _GlowOrb(
          color: AppColors.blue,
          onTap: onShare,
          child: const Icon(Icons.shortcut_rounded, color: Color(0xFF7DD3FC), size: 26),
        ),
        _GlowOrb(
          color: AppColors.pink,
          onTap: onLike,
          child: const Icon(Icons.favorite_rounded, color: Color(0xFFFF5FB8), size: 26),
        ),
        Consumer(
          builder: (_, ref, _) => Text(
            Formatters.compact(ref.watch(liveRoomProvider(streamId).select((s) => s.likes))),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Dark glass sphere with a neon rim and glow.
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.onTap, required this.child});

  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pressable(
        onTap: onTap,
        scale: 0.85,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.5),
              colors: [Color(0xFF2A2260), Color(0xFF0A0820)],
            ),
            border: Border.all(color: color.withValues(alpha: 0.8), width: 1.4),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 14, blurStyle: BlurStyle.outer)],
          ),
          foregroundDecoration: const BoxDecoration(shape: BoxShape.circle, gradient: Gloss.sheen),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.85,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xCC0B0A22),
          border: Border.all(color: const Color(0x668DA2FF)),
          boxShadow: const [BoxShadow(color: Color(0x408B5CF6), blurRadius: 10, blurStyle: BlurStyle.outer)],
        ),
        foregroundDecoration: const BoxDecoration(shape: BoxShape.circle, gradient: Gloss.sheen),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

/// Small frosted bottom sheet shared by the live-room menus.
void _showGlassSheet(BuildContext context, {required String title, required Widget child}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF2221654), Color(0xF20A0A22)],
          ),
          border: Border.all(color: const Color(0x66B44CFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    ),
  );
}

class _Scrims extends StatelessWidget {
  const _Scrims();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x99000000), Color(0x00000000), Color(0x00000000), Color(0xD905041A)],
          stops: [0, 0.22, 0.45, 1],
        ),
      ),
    );
  }
}
