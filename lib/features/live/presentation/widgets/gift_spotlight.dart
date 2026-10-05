import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../data/models/chat_message.dart';

/// Animated card showcasing the latest gift. With [autoHide] it disappears
/// a few seconds after each gift (live room); otherwise it stays (PK).
class GiftSpotlight extends StatefulWidget {
  const GiftSpotlight({super.key, required this.message, this.autoHide = false});

  final ChatMessage? message;
  final bool autoHide;

  @override
  State<GiftSpotlight> createState() => _GiftSpotlightState();
}

class _GiftSpotlightState extends State<GiftSpotlight> {
  static const _visibleFor = Duration(seconds: 3);

  Timer? _hideTimer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void didUpdateWidget(GiftSpotlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message?.id != widget.message?.id) {
      _visible = true;
      _scheduleHide();
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!widget.autoHide || widget.message == null) return;
    _hideTimer = Timer(_visibleFor, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final gift = message?.gift;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: (message == null || gift == null || !_visible)
          ? const SizedBox.shrink()
          : GlassContainer(
              key: ValueKey(message.id),
              borderRadius: 22,
              glowColor: AppColors.pink,
              glowBlur: 16,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC3A1A6B), Color(0xCC140C33)],
              ),
              borderGradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xAAFF8AD0), Color(0x338DA2FF)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(gift.emoji, style: const TextStyle(fontSize: 46)),
                  const SizedBox(height: 4),
                  Text(
                    gift.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '🪙 x${message.giftCount}',
                    style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    message.senderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
    );
  }
}
