import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../domain/models/camera_filter_model.dart';

/// Pre-live filter studio panel matching Screen 2 ("Go Live Screen - Filter Selection").
/// Displays mode tabs (Filters, Effects, Background), category pills, circular filter thumbnails,
/// and the primary "Go Live" action button.
class FilterSelectionCarousel extends StatefulWidget {
  final CameraFilterModel selectedFilter;
  final ValueChanged<CameraFilterModel> onSelectFilter;
  final VoidCallback onGoLiveTap;

  const FilterSelectionCarousel({
    super.key,
    required this.selectedFilter,
    required this.onSelectFilter,
    required this.onGoLiveTap,
  });

  @override
  State<FilterSelectionCarousel> createState() => _FilterSelectionCarouselState();
}

class _FilterSelectionCarouselState extends State<FilterSelectionCarousel> {
  int _selectedMode = 0; // 0 = Filters, 1 = Effects, 2 = Background
  FilterCategory _selectedCategory = FilterCategory.all;

  static const _modes = [
    {'label': 'Filters', 'icon': Icons.auto_awesome_rounded},
    {'label': 'Effects', 'icon': Icons.flare_rounded},
    {'label': 'Background', 'icon': Icons.image_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final filters = MockFilterData.getFiltersForCategory(_selectedCategory);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xE60E0A28),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // Grab handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 1. Mode Tabs: [ Filters | Effects | Background ]
                _buildModeTabs(),
                const SizedBox(height: 10),

                // 2. Filter Categories Horizontal Row
                _buildCategoryPills(),
                const SizedBox(height: 12),

                // 3. Filter Circular Thumbnails Carousel
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = filter.id == widget.selectedFilter.id;
                      return _FilterThumbnailItem(
                        filter: filter,
                        isSelected: isSelected,
                        onTap: () => widget.onSelectFilter(filter),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 4. "Go Live" Primary Action Button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    bottomPadding > 0 ? bottomPadding + 8 : 16,
                  ),
                  child: _buildGoLiveButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF19133D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: List.generate(_modes.length, (index) {
            final mode = _modes[index];
            final isSelected = _selectedMode == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedMode = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2C2263) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: const Color(0x66FF2DC0), width: 1.2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0x33FF2DC0),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mode['icon'] as IconData,
                        size: 15,
                        color: isSelected ? const Color(0xFFFF2DC0) : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mode['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: FilterCategory.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = FilterCategory.values[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7E3CFF) : const Color(0xFF1E1748),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF2DC0) : Colors.white.withValues(alpha: 0.1),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0x667E3CFF),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 15,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoLiveButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B2CFF), Color(0xFFFF2DC0), Color(0xFFFF5282)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FF2DC0),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x448B2CFF),
            blurRadius: 24,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: widget.onGoLiveTap,
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sensors_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Go Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular filter thumbnail with neon selection ring matching Screenshot 2.
class _FilterThumbnailItem extends StatelessWidget {
  final CameraFilterModel filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterThumbnailItem({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: isSelected ? 60 : 54,
            height: isSelected ? 60 : 54,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? LinearGradient(
                      colors: [filter.primaryColor, filter.secondaryColor, const Color(0xFFFFD600)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.white.withValues(alpha: 0.25), Colors.white.withValues(alpha: 0.08)],
                    ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: filter.primaryColor.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Container(
                color: const Color(0xFF151030),
                child: filter.isNone
                    ? const Center(
                        child: Icon(
                          Icons.block_flipped,
                          color: Colors.white70,
                          size: 26,
                        ),
                      )
                    : filter.thumbnailAsset != null
                        ? Image.asset(
                            filter.thumbnailAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                filter.fallbackIcon ?? Icons.auto_awesome,
                                color: filter.primaryColor,
                                size: 24,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              filter.fallbackIcon ?? Icons.auto_awesome,
                              color: filter.primaryColor,
                              size: 24,
                            ),
                          ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 66,
            child: Text(
              filter.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? LuxeColors.gold : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                height: 1.2,
                shadows: isSelected
                    ? [
                        Shadow(color: filter.primaryColor.withValues(alpha: 0.8), blurRadius: 6),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
