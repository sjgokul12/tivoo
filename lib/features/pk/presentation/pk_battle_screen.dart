import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/snackbar.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/crown_icon.dart';
import '../../../core/widgets/floating_hearts.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_icon_button.dart';
import '../../../core/widgets/gradient_mask.dart';
import '../../../core/widgets/state_message.dart';
import '../../../data/models/pk_battle.dart';
import '../../gifts/presentation/gift_sheet.dart';
import '../../live/presentation/widgets/chat_input_bar.dart';
import '../../live/presentation/widgets/gift_spotlight.dart';
import '../../live/presentation/widgets/live_chat_list.dart';
import '../../live/presentation/widgets/live_commands_bar.dart';
import '../../shell/providers/shell_tab_provider.dart';
import '../providers/pk_battle_controller.dart';
import 'widgets/marquee_text.dart';
import 'widgets/pk_header.dart';
import 'widgets/pk_result_overlay.dart';
import 'widgets/pk_video_panel.dart';

class PkBattleScreen extends ConsumerWidget {
  const PkBattleScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const PkBattleScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The battle itself never changes once loaded, so this only rebuilds on load/error.
    final battle = ref.watch(pkBattleProvider.select((a) => a.whenData((s) => s.battle)));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: battle.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: StateMessage(
              icon: Icons.wifi_off_rounded,
              title: 'Could not join the PK battle',
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(pkBattleProvider),
            ),
          ),
          data: (battle) => _PkBody(battle: battle),
        ),
      ),
    );
  }
}

class _PkBody extends ConsumerWidget {
  const _PkBody({required this.battle});

  final PkBattle battle;

  // Height of every fixed row in the layout (header, ticker, bars, buttons...).
  static const _fixedHeight = 360.0;
  static const _minChatHeight = 150.0;

  PkBattleController _controller(WidgetRef ref) => ref.read(pkBattleProvider.notifier);

  Future<void> _sendGift(BuildContext context, WidgetRef ref) async {
    final selection = await GiftSheet.show(
      context,
      recipients: ['Team ${battle.left.streamer.name}', 'Team ${battle.right.streamer.name}'],
    );
    if (selection == null || !context.mounted) return;
    if (!_controller(ref).sendGift(selection)) {
      final finished = ref.read(pkBattleProvider).value?.isFinished ?? false;
      context.showAppSnackBar(finished ? 'This battle has ended' : 'Not enough coins for this gift');
    }
  }

  void _onCommand(BuildContext context, WidgetRef ref, LiveCommand command) {
    switch (command) {
      case LiveCommand.like:
        _controller(ref).like();
      case LiveCommand.gift:
        _sendGift(context, ref);
      case LiveCommand.follow:
        context.showAppSnackBar('You followed ${battle.left.streamer.name} & ${battle.right.streamer.name} 💖');
      case LiveCommand.share:
        copyLiveLink(context, battle.id);
    }
  }

  /// Leaves the battle and lands on the Home tab, wherever PK was opened from.
  void _goHome(BuildContext context, WidgetRef ref) {
    ref.read(shellTabProvider.notifier).select(ShellTab.home);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onSubmit(BuildContext context, WidgetRef ref, String text) {
    _controller(ref).sendMessage(text);
    final command = LiveCommand.parse(text);
    if (command != null) _onCommand(context, ref, command);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gap = SizedBox(height: 8);

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final available = constraints.maxHeight - _fixedHeight;
        final panelHeight = math.min(width / 2 * 1.3, math.max(160.0, available - _minChatHeight));
        // Very short screens: scroll instead of squeezing the chat to nothing.
        final scrollable = available - panelHeight < _minChatHeight;

        final chatRow = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GlassContainer(
                borderRadius: 22,
                color: const Color(0x800C0C28),
                borderColor: Colors.white.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Consumer(
                  builder: (_, ref, _) => LiveChatList(
                    messages: ref.watch(pkBattleProvider.select((a) => a.value?.messages ?? const [])),
                    showTime: true,
                    bubbles: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: math.max(84, width * 0.23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Consumer(
                        builder: (_, ref, _) => GiftSpotlight(
                          message: ref.watch(pkBattleProvider.select((a) => a.value?.lastGift)),
                        ),
                      ),
                    ),
                  ),
                  // Shrinks instead of overflowing when the chat row is short.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RoundAction(
                            color: AppColors.pink,
                            onTap: () => _controller(ref).like(),
                            child: const Icon(Icons.favorite_rounded, color: AppColors.pink, size: 22),
                          ),
                          _RoundAction(
                            color: AppColors.gold,
                            onTap: () => _sendGift(context, ref),
                            child: Image.asset(AppAssets.giftPink, width: 34),
                          ),
                          _RoundAction(
                            onTap: () => copyLiveLink(context, battle.id),
                            child: const Icon(Icons.shortcut_rounded, color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final column = Column(
          children: [
            PkHeader(battle: battle),
            gap,
            Row(
              children: [
                GlassIconButton(
                  size: 36,
                  tooltip: 'Back to Home',
                  onTap: () => _goHome(context, ref),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(child: _BattleTicker(battle: battle)),
              ],
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: PkTeamBar(
                    name: battle.left.streamer.name,
                    supporters: battle.leftSupporters,
                    side: PkSide.left,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PkTeamBar(
                    name: battle.right.streamer.name,
                    supporters: battle.rightSupporters,
                    side: PkSide.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: panelHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(child: PkVideoPanel(stream: battle.left, side: PkSide.left, cover: battle.leftCover)),
                      const SizedBox(width: 8),
                      Expanded(child: PkVideoPanel(stream: battle.right, side: PkSide.right, cover: battle.rightCover)),
                    ],
                  ),
                  // Sits a little above centre so it never covers the score plates.
                  Align(
                    alignment: const Alignment(0, -0.45),
                    child: _VsEmblem(size: math.min(124, panelHeight * 0.48)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _SupportersRow(battle: battle),
            gap,
            LiveCommandsBar(onCommand: (c) => _onCommand(context, ref, c)),
            gap,
            if (scrollable) SizedBox(height: _minChatHeight, child: chatRow) else Expanded(child: chatRow),
            gap,
            _BottomBar(
              onLeave: () => _goHome(context, ref),
              onSubmit: (text) => _onSubmit(context, ref, text),
              onGift: () => _sendGift(context, ref),
              onShare: () => copyLiveLink(context, battle.id),
            ),
          ],
        );

        return scrollable ? SingleChildScrollView(child: column) : column;
      },
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                  child: Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 6), child: body),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 140,
          width: 80,
          height: 320,
          child: Consumer(
            builder: (_, ref, _) => FloatingHearts(
              count: ref.watch(pkBattleProvider.select((a) => a.value?.likes ?? 0)),
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, _) {
            final finished = ref.watch(pkBattleProvider.select((a) => a.value?.isFinished ?? false));
            if (!finished) return const SizedBox.shrink();
            final state = ref.watch(pkBattleProvider).requireValue;
            return PkResultOverlay(
              battle: battle,
              winner: state.leader,
              leftScore: state.leftScore,
              rightScore: state.rightScore,
              onRematch: () => _controller(ref).rematch(),
              onLeave: () => _goHome(context, ref),
            );
          },
        ),
      ],
    );
  }
}

class _BattleTicker extends ConsumerWidget {
  const _BattleTicker({required this.battle});

  final PkBattle battle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leader = ref.watch(pkBattleProvider.select((a) => a.value?.leader));
    final headline = switch (leader) {
      PkSide.left => '🔥 ${battle.left.streamer.name} is leading the battle!',
      PkSide.right => '🔥 ${battle.right.streamer.name} is leading the battle!',
      null => '🔥 Neck and neck — every gift counts!',
    };
    return GlassContainer(
      borderRadius: 18,
      color: const Color(0x99101030),
      borderGradient: const LinearGradient(colors: [AppColors.gold, AppColors.purple, AppColors.cyan]),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: MarqueeText(
                text: '$headline  •  Send gifts to power up your team  •  Top supporter earns a crown 👑',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VsEmblem extends StatelessWidget {
  const _VsEmblem({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Breathing(
          scale: 0.07,
          period: const Duration(milliseconds: 1400),
          child: Image.asset(AppAssets.pkVs, width: size, cacheWidth: (size * dpr).round()),
        ),
        const _Countdown(),
      ],
    );
  }
}

class _Countdown extends ConsumerWidget {
  const _Countdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(pkBattleProvider.select((a) => a.value?.remaining ?? Duration.zero));
    final urgent = remaining.inSeconds <= 10;
    return GlassContainer(
      borderRadius: 20,
      color: const Color(0xE60B0B24),
      borderColor: urgent ? AppColors.live : Colors.white.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 18, color: urgent ? AppColors.live : Colors.white),
          const SizedBox(width: 6),
          Text(
            Formatters.countdown(remaining),
            style: TextStyle(
              color: urgent ? AppColors.live : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportersRow extends StatelessWidget {
  const _SupportersRow({required this.battle});

  final PkBattle battle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Supporters(urls: battle.leftSupporters),
        const Expanded(child: Center(child: _CommandsTitle())),
        _Supporters(urls: battle.rightSupporters),
      ],
    );
  }
}

class _Supporters extends StatelessWidget {
  const _Supporters({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarStack(images: urls, size: 30, overlap: 0.15),
        const SizedBox(height: 3),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CrownIcon(size: 10),
            SizedBox(width: 4),
            Text('Top Supporters', style: TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

/// Gold-rimmed "⚡ LIVE COMMANDS ⚡" title with a sweeping shine.
class _CommandsTitle extends StatelessWidget {
  const _CommandsTitle();

  @override
  Widget build(BuildContext context) {
    const bolt = Icon(
      Icons.bolt_rounded,
      color: AppColors.gold,
      size: 18,
      shadows: [Shadow(color: Color(0xFFFFB020), blurRadius: 10)],
    );
    return const ShimmerSweep(
      period: Duration(milliseconds: 3000),
      color: Color(0x66FFF4B0),
      child: GlassContainer(
        borderRadius: 22,
        borderWidth: 1.5,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC2A1D08), Color(0xE60B0A1E)],
        ),
        borderGradient: LinearGradient(colors: [Color(0xFFFFF0A8), Color(0xFFFFB020), Color(0xFFFF4FB0)]),
        shadows: [BoxShadow(color: Color(0x80FFB020), blurRadius: 14, blurStyle: BlurStyle.outer)],
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              bolt,
              SizedBox(width: 6),
              GradientText(
                'LIVE COMMANDS',
                gradient: LinearGradient(colors: [Color(0xFFFFF4B0), Color(0xFFFFC83D)]),
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 0.8),
              ),
              SizedBox(width: 6),
              bolt,
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.onTap, required this.child, this.color});

  final VoidCallback onTap;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GlassIconButton(size: 44, glowColor: color, onTap: onTap, child: child),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onSubmit, required this.onGift, required this.onShare, required this.onLeave});

  final ValueChanged<String> onSubmit;
  final VoidCallback onGift;
  final VoidCallback onShare;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIconButton(
          size: 52,
          glowColor: AppColors.pink,
          tooltip: 'PK',
          onTap: () => context.showAppSnackBar('Go live to start your own PK battle 👑'),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CrownIcon(size: 13),
              GradientText(
                'PK',
                gradient: AppColors.goldGradient,
                style: TextStyle(fontSize: 14, height: 1.1, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: ChatInputBar(onSubmit: onSubmit)),
        const SizedBox(width: 6),
        _GiftButton(onTap: onGift),
        const SizedBox(width: 6),
        GlassIconButton(
          size: 42,
          tooltip: 'Share',
          onTap: onShare,
          child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 6),
        PopupMenuButton<VoidCallback>(
          tooltip: 'More',
          color: const Color(0xF21A1640),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          onSelected: (action) => action(),
          itemBuilder: (_) => [
            PopupMenuItem(value: onShare, child: const Text('Share battle')),
            PopupMenuItem(value: onLeave, child: const Text('Leave battle')),
          ],
          child: IgnorePointer(
            child: GlassIconButton(
              size: 42,
              onTap: () {},
              child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

/// 3D gift box artwork with a "Gift" label, floating gently.
class _GiftButton extends StatelessWidget {
  const _GiftButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Pressable(
      onTap: onTap,
      scale: 0.88,
      child: SizedBox.square(
        dimension: 58,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Breathing(
              float: 2,
              scale: 0.05,
              child: Image.asset(AppAssets.giftPink, width: 64, cacheWidth: (64 * dpr).round()),
            ),
            const Positioned(
              bottom: 2,
              child: Text(
                'Gift',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
