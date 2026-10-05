import 'package:flutter/material.dart';

/// Endlessly scrolling single-line text (news-ticker style).
class MarqueeText extends StatefulWidget {
  const MarqueeText({super.key, required this.text, required this.style, this.pixelsPerSecond = 40});

  final String text;
  final TextStyle style;
  final double pixelsPerSecond;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  static const _gap = 40.0;

  late final AnimationController _controller = AnimationController(vsync: this);
  double _cycleWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _measure();
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) _measure();
  }

  void _measure() {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    _cycleWidth = painter.width + _gap;
    painter.dispose();
    _controller
      ..duration = Duration(milliseconds: (_cycleWidth / widget.pixelsPerSecond * 1000).round())
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(widget.text, style: widget.style, maxLines: 1, softWrap: false);
    return RepaintBoundary(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) => Transform.translate(
            offset: Offset(-_controller.value * _cycleWidth, 0),
            child: child,
          ),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [text, const SizedBox(width: _gap), text, const SizedBox(width: _gap), text],
            ),
          ),
        ),
      ),
    );
  }
}
