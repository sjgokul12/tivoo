import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../domain/models/camera_filter_model.dart';

/// Modal bottom sheet for switching camera filters in real-time during a live stream.
/// Matches Screen 4 ("Switch Filters During Live").
class LiveFilterBottomSheet extends StatefulWidget {
  final CameraFilterModel selectedFilter;
  final ValueChanged<CameraFilterModel> onSelectFilter;

  const LiveFilterBottomSheet({
    super.key,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  static Future<void> show(
    BuildContext context, {
    required CameraFilterModel selectedFilter,
    required ValueChanged<CameraFilterModel> onSelectFilter,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LiveFilterBottomSheet(
        selectedFilter: selectedFilter,
        onSelectFilter: onSelectFilter,
      ),
    );
  }

  @override
  State<LiveFilterBottomSheet> createState() => _LiveFilterBottomSheetState();
}

class _LiveFilterBottomSheetState extends State<LiveFilterBottomSheet> {
  FilterCategory _selectedCategory = FilterCategory.all;
  late CameraFilterModel _currentFilter = widget.selectedFilter;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final filters = MockFilterData.getFiltersForCategory(_selectedCategory);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 12, 0, bottomPadding > 0 ? bottomPadding + 10 : 20),
          decoration: BoxDecoration(
            color: const Color(0xF20F0B2A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header with title & collapse chevron
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Categories selector
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: FilterCategory.values.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = FilterCategory.values[index];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF7E3CFF) : const Color(0xFF221A50),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF2DC0) : Colors.white12,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(cat.icon, size: 14, color: isSelected ? Colors.white : Colors.white60),
                              const SizedBox(width: 5),
                              Text(
                                cat.label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white60,
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Filter thumbnails carousel
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
                      final isSelected = filter.id == _currentFilter.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _currentFilter = filter);
                          widget.onSelectFilter(filter);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              width: isSelected ? 58 : 52,
                              height: isSelected ? 58 : 52,
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [filter.primaryColor, filter.secondaryColor, const Color(0xFFFFD600)],
                                      )
                                    : const LinearGradient(
                                        colors: [Colors.white24, Colors.white10],
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: filter.primaryColor.withValues(alpha: 0.65),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ClipOval(
                                child: Container(
                                  color: const Color(0xFF1B143D),
                                  child: filter.isNone
                                      ? const Center(
                                          child: Icon(
                                            Icons.block_flipped,
                                            color: Colors.white70,
                                            size: 24,
                                          ),
                                        )
                                      : filter.thumbnailAsset != null
                                          ? Image.asset(
                                              filter.thumbnailAsset!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                filter.fallbackIcon ?? Icons.auto_awesome,
                                                color: filter.primaryColor,
                                                size: 22,
                                              ),
                                            )
                                          : Icon(
                                              filter.fallbackIcon ?? Icons.auto_awesome,
                                              color: filter.primaryColor,
                                              size: 22,
                                            ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 64,
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
      ),
    );
  }
}
