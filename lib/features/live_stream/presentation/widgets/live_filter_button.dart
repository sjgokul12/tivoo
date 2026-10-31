import 'dart:ui';
import 'package:flutter/material.dart';

/// Supported Live Filter Types in Tivoo Design System
enum LiveFilterType {
  beauty,
  face,
  skin,
  hair,
  makeup,
  effects,
  background,
  brightness,
  contrast,
  reset,
}

/// Helper method to return active ColorFilter matrix for each filter type
ColorFilter? getLiveColorFilter(LiveFilterType type) {
  switch (type) {
    case LiveFilterType.beauty:
      return const ColorFilter.matrix([
        1.10, 0, 0, 0, 16,
        0, 1.04, 0, 0, 12,
        0, 0, 1.06, 0, 14,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.face:
      return const ColorFilter.matrix([
        1.15, 0, 0, 0, 5,
        0, 1.15, 0, 0, 5,
        0, 0, 1.20, 0, 10,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.skin:
      return const ColorFilter.matrix([
        1.06, 0, 0, 0, 22,
        0, 1.03, 0, 0, 14,
        0, 0, 0.98, 0, 8,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.hair:
      return const ColorFilter.matrix([
        1.22, 0, 0, 0, -8,
        0, 1.16, 0, 0, -8,
        0, 0, 1.30, 0, 4,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.makeup:
      return const ColorFilter.matrix([
        1.20, 0, 0, 0, 28,
        0, 0.98, 0, 0, 6,
        0, 0, 1.10, 0, 18,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.effects:
      return const ColorFilter.matrix([
        0.85, 0.25, 0.1, 0, 12,
        0.1, 1.15, 0.2, 0, 22,
        0.15, 0.2, 1.45, 0, 32,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.background:
      return const ColorFilter.matrix([
        0.90, 0, 0, 0, -15,
        0, 0.90, 0, 0, -15,
        0, 0, 1.08, 0, 6,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.brightness:
      return const ColorFilter.matrix([
        1.20, 0, 0, 0, 36,
        0, 1.20, 0, 0, 36,
        0, 0, 1.20, 0, 36,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.contrast:
      return const ColorFilter.matrix([
        1.38, 0, 0, 0, -42,
        0, 1.38, 0, 0, -42,
        0, 0, 1.38, 0, -42,
        0, 0, 0, 1.0, 0,
      ]);
    case LiveFilterType.reset:
      return null;
  }
}

/// Metadata definition for each item in the 10-icon Tivoo Filter Set
class FilterIconItem {
  final LiveFilterType type;
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final Color glowColor;

  const FilterIconItem({
    required this.type,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.glowColor,
  });
}

const List<FilterIconItem> kTivooFilterIconSet = [
  FilterIconItem(
    type: LiveFilterType.beauty,
    title: 'Beauty',
    icon: Icons.auto_awesome_rounded,
    gradient: [Color(0xFFFF2F7D), Color(0xFFFF80AB), Color(0xFFFFD21F)],
    glowColor: Color(0xFFFF2F7D),
  ),
  FilterIconItem(
    type: LiveFilterType.face,
    title: 'Face',
    icon: Icons.face_retouching_natural_rounded,
    gradient: [Color(0xFF168CFF), Color(0xFF00E5FF), Color(0xFF7B3CFF)],
    glowColor: Color(0xFF168CFF),
  ),
  FilterIconItem(
    type: LiveFilterType.skin,
    title: 'Skin',
    icon: Icons.spa_rounded,
    gradient: [Color(0xFFFFAB91), Color(0xFFFF8A80), Color(0xFFFFD21F)],
    glowColor: Color(0xFFFF8A80),
  ),
  FilterIconItem(
    type: LiveFilterType.hair,
    title: 'Hair',
    icon: Icons.waves_rounded,
    gradient: [Color(0xFF9C27B0), Color(0xFF7B3CFF), Color(0xFFFF2F7D)],
    glowColor: Color(0xFF7B3CFF),
  ),
  FilterIconItem(
    type: LiveFilterType.makeup,
    title: 'Makeup',
    icon: Icons.brush_rounded,
    gradient: [Color(0xFFFF1744), Color(0xFFFF2F7D), Color(0xFFFF4081)],
    glowColor: Color(0xFFFF1744),
  ),
  FilterIconItem(
    type: LiveFilterType.effects,
    title: 'Effects',
    icon: Icons.bolt_rounded,
    gradient: [Color(0xFF00E5FF), Color(0xFF168CFF), Color(0xFF00E676)],
    glowColor: Color(0xFF00E5FF),
  ),
  FilterIconItem(
    type: LiveFilterType.background,
    title: 'Background',
    icon: Icons.wallpaper_rounded,
    gradient: [Color(0xFF3F51B5), Color(0xFF2196F3), Color(0xFF7B3CFF)],
    glowColor: Color(0xFF2196F3),
  ),
  FilterIconItem(
    type: LiveFilterType.brightness,
    title: 'Brightness',
    icon: Icons.light_mode_rounded,
    gradient: [Color(0xFFFFD21F), Color(0xFFFFEA00), Color(0xFFFFFFFF)],
    glowColor: Color(0xFFFFD21F),
  ),
  FilterIconItem(
    type: LiveFilterType.contrast,
    title: 'Contrast',
    icon: Icons.tonality_rounded,
    gradient: [Color(0xFFFFFFFF), Color(0xFF90A4AE), Color(0xFF168CFF)],
    glowColor: Color(0xFF90A4AE),
  ),
  FilterIconItem(
    type: LiveFilterType.reset,
    title: 'Reset',
    icon: Icons.restart_alt_rounded,
    gradient: [Color(0xFFFF5252), Color(0xFFB0BEC5), Color(0xFF37474F)],
    glowColor: Color(0xFFFF5252),
  ),
];

/// Premium Cyberpunk Neon Filter Icon Button for Tivoo Live Streaming
class LiveFilterButton extends StatefulWidget {
  final bool initialActive;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final void Function(LiveFilterType type, ColorFilter? colorFilter)? onFilterSelected;
  final double size;

  const LiveFilterButton({
    super.key,
    this.initialActive = false,
    this.onToggle,
    this.onTap,
    this.onFilterSelected,
    this.size = 38.0,
  });

  @override
  State<LiveFilterButton> createState() => _LiveFilterButtonState();
}

class _LiveFilterButtonState extends State<LiveFilterButton>
    with SingleTickerProviderStateMixin {
  late bool _isActive;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  LiveFilterType _currentFilter = LiveFilterType.effects;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialActive;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isActive = !_isActive;
    });
    widget.onToggle?.call(_isActive);
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      _showFilterOptionsSheet(context);
    }
  }

  void _showFilterOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TivooFilterSetSheet(
        activeFilter: _currentFilter,
        onSelectFilter: (type) {
          setState(() {
            _currentFilter = type;
            _isActive = type != LiveFilterType.reset;
          });
          Navigator.pop(ctx);
          final cf = getLiveColorFilter(type);
          widget.onFilterSelected?.call(type, cf);

          final item = kTivooFilterIconSet.firstWhere((e) => e.type == type);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ ${item.title} Filter Active on Live Streams!'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF101827),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowScale = _isActive ? _glowAnimation.value : 1.0;

        return GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xCC101827),
              border: Border.all(
                color: _isActive
                    ? const Color(0xFFFF2F7D).withValues(alpha: 0.85)
                    : const Color(0xFF168CFF).withValues(alpha: 0.35),
                width: _isActive ? 1.4 : 1.0,
              ),
              boxShadow: [
                if (_isActive) ...[
                  BoxShadow(
                    color: const Color(0xFFFF2F7D).withValues(alpha: 0.40 * glowScale),
                    blurRadius: 12 * glowScale,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFF7B3CFF).withValues(alpha: 0.35 * glowScale),
                    blurRadius: 16 * glowScale,
                    offset: const Offset(-2, -2),
                  ),
                  BoxShadow(
                    color: const Color(0xFF168CFF).withValues(alpha: 0.30 * glowScale),
                    blurRadius: 14 * glowScale,
                    offset: const Offset(2, 2),
                  ),
                ] else ...[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isActive
                                ? [
                                    const Color(0x40168CFF),
                                    const Color(0x407B3CFF),
                                    const Color(0x40FF2F7D),
                                  ]
                                : [
                                    const Color(0x22101827),
                                    const Color(0x2207111F),
                                  ],
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: Size(widget.size * 0.52, widget.size * 0.52),
                      painter: _NeonFilterIconPainter(isActive: _isActive),
                    ),
                    if (_isActive)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 5.5,
                          height: 5.5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFD21F),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFFD21F),
                                blurRadius: 6,
                                spreadRadius: 1,
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
    );
  }
}

/// Custom Canvas Painter for the Clean Filter Symbol
class _NeonFilterIconPainter extends CustomPainter {
  final bool isActive;

  _NeonFilterIconPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.10, h * 0.18);
    path.lineTo(w * 0.90, h * 0.18);
    path.lineTo(w * 0.58, h * 0.56);
    path.lineTo(w * 0.58, h * 0.88);
    path.lineTo(w * 0.42, h * 0.88);
    path.lineTo(w * 0.42, h * 0.56);
    path.close();

    if (isActive) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
        ..shader = const LinearGradient(
          colors: [Color(0xFF168CFF), Color(0xFF7B3CFF), Color(0xFFFF2F7D)],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawPath(path, glowPaint);
    }

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = isActive
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFF00E5FF),
                Color(0xFF7B3CFF),
                Color(0xFFFF2F7D),
              ],
              stops: [0.0, 0.35, 0.70, 1.0],
            ).createShader(Rect.fromLTWH(0, 0, w, h))
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFB0BEC5)],
            ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, fillPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.90);

    canvas.drawLine(
      Offset(w * 0.28, h * 0.34),
      Offset(w * 0.72, h * 0.34),
      linePaint,
    );

    if (isActive) {
      final goldAccent = Paint()
        ..color = const Color(0xFFFFD21F)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.50, h * 0.88), 1.5, goldAccent);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonFilterIconPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}

/// Complete 10-Item Filter Set Selection Bottom Sheet
class _TivooFilterSetSheet extends StatelessWidget {
  final LiveFilterType activeFilter;
  final ValueChanged<LiveFilterType> onSelectFilter;

  const _TivooFilterSetSheet({
    required this.activeFilter,
    required this.onSelectFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xF507111F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0x44168CFF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x9907111F),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Live Stream Filters & Effects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFD21F),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x66FFD21F), width: 0.8),
                    ),
                    child: const Text(
                      'Tivoo Studio',
                      style: TextStyle(
                        color: Color(0xFFFFD21F),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Horizontal Scrollable Filter Icon Set (10 Items)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: kTivooFilterIconSet.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = kTivooFilterIconSet[index];
                    final isSelected = item.type == activeFilter;

                    return GestureDetector(
                      onTap: () => onSelectFilter(item.type),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glassmorphic Icon Container with Unique Neon Gradient Glow
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xCC101827),
                              border: Border.all(
                                color: isSelected
                                    ? item.gradient.first
                                    : item.gradient.first.withValues(alpha: 0.35),
                                width: isSelected ? 2.0 : 1.2,
                              ),
                              boxShadow: [
                                if (isSelected) ...[
                                  BoxShadow(
                                    color: item.glowColor.withValues(alpha: 0.65),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ] else ...[
                                  BoxShadow(
                                    color: item.glowColor.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Gradient Overlay
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: item.gradient
                                                .map((c) => c.withValues(alpha: isSelected ? 0.35 : 0.15))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // White Icon Detail with Shader
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: isSelected
                                            ? [Colors.white, item.gradient.first]
                                            : [Colors.white, Colors.white70],
                                      ).createShader(bounds),
                                      child: Icon(
                                        item.icon,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    // Active Golden Sparkle on top-right
                                    if (isSelected)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFFFD21F),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFFFFD21F),
                                                blurRadius: 6,
                                                spreadRadius: 1,
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
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60,
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white60,
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
