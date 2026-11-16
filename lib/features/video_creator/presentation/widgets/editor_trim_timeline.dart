import 'package:flutter/material.dart';

class EditorTrimTimeline extends StatefulWidget {
  final Duration totalDuration;
  final Duration currentPosition;
  final Duration trimStart;
  final Duration trimEnd;
  final void Function(Duration start, Duration end) onTrimChanged;
  final ValueChanged<Duration>? onSeek;

  const EditorTrimTimeline({
    super.key,
    required this.totalDuration,
    required this.currentPosition,
    required this.trimStart,
    required this.trimEnd,
    required this.onTrimChanged,
    this.onSeek,
  });

  @override
  State<EditorTrimTimeline> createState() => _EditorTrimTimelineState();
}

class _EditorTrimTimelineState extends State<EditorTrimTimeline> {
  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.totalDuration.inMilliseconds.clamp(1000, 360000);
    final startRatio = (widget.trimStart.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final endRatio = (widget.trimEnd.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final currentRatio = (widget.currentPosition.inMilliseconds / totalMs).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time readout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_format(widget.currentPosition)} / ${_format(widget.totalDuration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF9D4EDD).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF9D4EDD), width: 0.8),
                ),
                child: Text(
                  'Trimmed: ${_format(widget.trimEnd - widget.trimStart)}',
                  style: const TextStyle(color: Color(0xFFFF80DF), fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Filmstrip with handles
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final leftPx = startRatio * w;
            final rightPx = endRatio * w;
            final scrubberPx = (currentRatio * w).clamp(0.0, w);

            return Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black45,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Instagram-style sleek timeline track
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E1035), Color(0xFF2C1654), Color(0xFF1A1528)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          for (int i = 0; i < 8; i++)
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3D216E).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.movie_creation_outlined,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Dimmed non-selected edges
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: leftPx,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: (w - rightPx).clamp(0.0, w),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                      ),
                    ),
                  ),

                  // Active Highlight Frame
                  Positioned(
                    left: leftPx,
                    width: (rightPx - leftPx).clamp(24.0, w),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF9D4EDD), width: 2.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // Left Trim Handle
                  Positioned(
                    left: (leftPx - 8).clamp(0.0, w - 24),
                    top: 0,
                    bottom: 0,
                    width: 18,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        final newLeft = (leftPx + details.delta.dx).clamp(0.0, rightPx - 20);
                        final newStartMs = (newLeft / w * totalMs).round();
                        widget.onTrimChanged(
                          Duration(milliseconds: newStartMs),
                          widget.trimEnd,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D4EDD),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
                        ),
                        child: const Center(
                          child: Icon(Icons.drag_indicator_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ),

                  // Right Trim Handle
                  Positioned(
                    left: (rightPx - 10).clamp(18.0, w - 18),
                    top: 0,
                    bottom: 0,
                    width: 18,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        final newRight = (rightPx + details.delta.dx).clamp(leftPx + 20, w);
                        final newEndMs = (newRight / w * totalMs).round();
                        widget.onTrimChanged(
                          widget.trimStart,
                          Duration(milliseconds: newEndMs),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D4EDD),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
                        ),
                        child: const Center(
                          child: Icon(Icons.drag_indicator_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ),

                  // Current Position Scrubber Needle
                  Positioned(
                    left: scrubberPx - 1.5,
                    top: -3,
                    bottom: -3,
                    width: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black87, blurRadius: 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
