import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import 'video_filters.dart';

/// Horizontally scrollable Instagram Reels-style filter carousel with:
/// - Circular preview thumbnails showing the live color grade on the model's portrait
/// - Glowing neon ring indicator on selected filter
/// - Highlighted filter title
/// - Floating intensity slider when any non-Original filter is selected
class FilterCarousel extends StatelessWidget {
  final List<VideoFilterItem> filters;
  final String selectedFilterId;
  final double intensity;
  final ValueChanged<String> onSelectFilter;
  final ValueChanged<double> onIntensityChanged;

  const FilterCarousel({
    super.key,
    required this.filters,
    required this.selectedFilterId,
    required this.intensity,
    required this.onSelectFilter,
    required this.onIntensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFilter = filters.firstWhere(
      (f) => f.id == selectedFilterId,
      orElse: () => filters.first,
    );
    final showIntensitySlider = !selectedFilter.isOriginal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Filter Intensity Slider (Visible when any filter except 'Original' is selected)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(sizeFactor: animation, child: child),
            );
          },
          child: showIntensitySlider
              ? Container(
                  key: ValueKey('intensity_${selectedFilter.id}'),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFFF2DC0).withValues(alpha: 0.4),
                      width: 1.1,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33FF2DC0), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, color: Color(0xFFFF8AE6), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${selectedFilter.name}  ${(intensity * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
                        height: 24,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFFFF2DC0),
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                            overlayColor: const Color(0x33FF2DC0),
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: intensity,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (val) {
                              onIntensityChanged(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Horizontal Carousel
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = filters[index];
              final isSelected = selectedFilterId == item.id;
              final previewFilter = item.getColorFilter(1.0);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectFilter(item.id);
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circular Thumbnail
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF2DC0) : Colors.white30,
                          width: isSelected ? 2.6 : 1.1,
                        ),
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: Color(0x99FF2DC0),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                ),
                                const BoxShadow(
                                  color: Color(0x669D4EDD),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipOval(
                        child: ColorFiltered(
                          colorFilter: previewFilter ??
                              const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                          child: Image.network(
                            item.coverUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 140,
                            cacheHeight: 140,
                            errorBuilder: (_, _, _) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    item.previewColor.withValues(alpha: 0.8),
                                    const Color(0xFF131526),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Icon(Icons.auto_awesome_rounded, color: item.previewColor, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Filter Name
                    Text(
                      item.name,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFFF8AE6) : Colors.white,
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        shadows: const [
                          Shadow(color: Colors.black87, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

