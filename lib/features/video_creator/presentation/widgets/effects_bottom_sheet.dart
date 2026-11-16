import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VisualEffectItem {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> gradient;

  const VisualEffectItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradient,
  });
}

class EffectsBottomSheet extends StatelessWidget {
  final String? activeEffectId;
  final ValueChanged<String?> onSelectEffect;

  const EffectsBottomSheet({
    super.key,
    required this.activeEffectId,
    required this.onSelectEffect,
  });

  static const List<VisualEffectItem> effects = [
    VisualEffectItem(
      id: 'none',
      name: 'None',
      icon: Icons.block_flipped,
      gradient: [Color(0xFF2B2844), Color(0xFF161427)],
    ),
    VisualEffectItem(
      id: 'sparkles',
      name: 'Sparkles',
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFFFFD700), Color(0xFFFF2DC0)],
    ),
    VisualEffectItem(
      id: 'light_leak',
      name: 'Light Leak',
      icon: Icons.wb_sunny_rounded,
      gradient: [Color(0xFFFF9100), Color(0xFFFF2A85)],
    ),
    VisualEffectItem(
      id: 'bokeh_hearts',
      name: 'Hearts',
      icon: Icons.favorite_rounded,
      gradient: [Color(0xFFFF2DC0), Color(0xFF9D4EDD)],
    ),
    VisualEffectItem(
      id: 'neon_aura',
      name: 'Neon Aura',
      icon: Icons.blur_circular_rounded,
      gradient: [Color(0xFF00E5FF), Color(0xFFFF007F)],
    ),
    VisualEffectItem(
      id: 'stardust',
      name: 'Stardust',
      icon: Icons.flare_rounded,
      gradient: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
    ),
    VisualEffectItem(
      id: 'glitch_vhs',
      name: 'VHS Glitch',
      icon: Icons.tv_rounded,
      gradient: [Color(0xFF00E5FF), Color(0xFFFF2DC0)],
    ),
    VisualEffectItem(
      id: 'film_grain',
      name: 'Film Grain',
      icon: Icons.camera_roll_rounded,
      gradient: [Color(0xFF8D6E63), Color(0xFF4E342E)],
    ),
  ];

  static void show(
    BuildContext context, {
    required String? activeEffectId,
    required ValueChanged<String?> onSelectEffect,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EffectsBottomSheet(
        activeEffectId: activeEffectId,
        onSelectEffect: onSelectEffect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xF2121020),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0x33FF2DC0), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            const SizedBox(height: 14),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF2DC0), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Visual Effects',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid of effects
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: effects.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, i) {
                final item = effects[i];
                final isSelected = activeEffectId == item.id ||
                    (item.id == 'none' && (activeEffectId == null || activeEffectId == 'none'));

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectEffect(item.id == 'none' ? null : item.id);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: item.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF2DC0) : Colors.white24,
                            width: isSelected ? 2.5 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                    color: Color(0x88FF2DC0),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          item.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFFF8AE6) : Colors.white70,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

