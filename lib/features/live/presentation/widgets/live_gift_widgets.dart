import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gloss.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../data/models/chat_message.dart';

/// "Karthik sent Rose 🌹 x1" pill that slides in for each new gift and
/// slides away a few seconds later.
class GiftBanner extends StatefulWidget {
  const GiftBanner({super.key, required this.message});

  final ChatMessage? message;

  @override
  State<GiftBanner> createState() => _GiftBannerState();
}

class _GiftBannerState extends State<GiftBanner> {
  static const _visibleFor = Duration(milliseconds: 3200);

  Timer? _timer;
  bool _visible = false;

  @override
  void didUpdateWidget(GiftBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != null && oldWidget.message?.id != widget.message?.id) {
      _visible = true;
      _timer?.cancel();
      _timer = Timer(_visibleFor, () {
        if (mounted) setState(() => _visible = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final gift = message?.gift;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween(begin: const Offset(-1.1, 0), end: Offset.zero).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: (!_visible || message == null || gift == null)
          ? const SizedBox(key: ValueKey('none'), height: 0)
          : ShimmerSweep(
              key: ValueKey(message.id),
              period: const Duration(milliseconds: 1800),
              color: const Color(0x66FFF4B0),
              child: GlassContainer(
                borderRadius: 24,
                borderWidth: 1.5,
                gradient: const LinearGradient(colors: [Color(0xE63A1670), Color(0xCC14102E)]),
                borderGradient: const LinearGradient(colors: [Color(0xFFFF8AD8), Color(0xFFB44CFF), Color(0xFFFFC83D)]),
                shadows: const [BoxShadow(color: Color(0x99B44CFF), blurRadius: 16, blurStyle: BlurStyle.outer)],
                padding: const EdgeInsets.fromLTRB(4, 3, 14, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppAssets.giftPink, width: 34),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${message.senderName}  ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: 'sent ${gift.name} ${gift.emoji} '),
                            TextSpan(
                              text: 'x${message.giftCount}',
                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// One-tap gift buttons: Rose ×1, Crown ×10, Rocket ×50, Love ×100.
class QuickGiftBar extends StatelessWidget {
  const QuickGiftBar({super.key, required this.onSend});

  final void Function(Gift gift, int quantity) onSend;

  static const _presets = [('rose', 1), ('crown', 10), ('rocket', 50), ('love', 100)];

  @override
  Widget build(BuildContext context) {
    final gifts = {for (final g in MockData.gifts) g.id: g};
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (id, quantity) in _presets)
          if (gifts[id] case final gift?)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _QuickGift(gift: gift, quantity: quantity, onTap: () => onSend(gift, quantity)),
            ),
      ],
    );
  }
}

class _QuickGift extends StatelessWidget {
  const _QuickGift({required this.gift, required this.quantity, required this.onTap});

  final Gift gift;
  final int quantity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.5),
                colors: [Color(0xFF3A2470), Color(0xFF0E0A26)],
              ),
              border: Border.all(color: const Color(0xAAB44CFF), width: 1.4),
              boxShadow: const [BoxShadow(color: Color(0x80B44CFF), blurRadius: 12, blurStyle: BlurStyle.outer)],
            ),
            foregroundDecoration: const BoxDecoration(shape: BoxShape.circle, gradient: Gloss.sheen),
            alignment: Alignment.center,
            child: Text(gift.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 3),
          Text(
            gift.name.split(' ').first,
            style: const TextStyle(color: Colors.white, fontSize: 10.5, height: 1.15),
          ),
          Text(
            'x$quantity',
            style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w600, height: 1.15),
          ),
        ],
      ),
    );
  }
}
