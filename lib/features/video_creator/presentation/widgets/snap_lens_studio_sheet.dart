import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../broadcast/domain/models/camera_filter_model.dart';

const Color _snapYellow = Color(0xFFFFFC00);
const Color _snapDarkBg = Color(0xF2121020);

/// Interactive Snap Lens Studio Sheet inspired by Snapchat Camera Kit / Snap Lens Studio
/// (https://developers.snap.com/lens-studio/home).
///
/// Features authentic Snap branding, category filtering, live preview thumbnails,
/// and instant AR lens selection.
class SnapLensStudioSheet extends StatefulWidget {
  final CameraFilterModel? selectedLens;
  final ValueChanged<CameraFilterModel> onSelectLens;

  const SnapLensStudioSheet({
    super.key,
    CameraFilterModel? selectedLens,
    CameraFilterModel? activeLens,
    required this.onSelectLens,
  }) : selectedLens = selectedLens ?? activeLens;

  CameraFilterModel? get activeLens => selectedLens;

  static Future<void> show(
    BuildContext context, {
    CameraFilterModel? selectedLens,
    CameraFilterModel? activeLens,
    required ValueChanged<CameraFilterModel> onSelectLens,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SnapLensStudioSheet(
        selectedLens: selectedLens ?? activeLens,
        onSelectLens: onSelectLens,
      ),
    );
  }

  @override
  State<SnapLensStudioSheet> createState() => _SnapLensStudioSheetState();
}

class _SnapLensStudioSheetState extends State<SnapLensStudioSheet> {
  FilterCategory _selectedCategory = FilterCategory.all;

  static const Color snapYellow = _snapYellow;
  // ignore: unused_field
  static const Color snapDarkBg = _snapDarkBg;

  @override
  Widget build(BuildContext context) {
    final filtered = MockFilterData.getFiltersForCategory(_selectedCategory);

    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: const BoxDecoration(
        color: _snapDarkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33FFFC00), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Snap Lens Studio Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _snapYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _snapYellow.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SNAP LENS STUDIO',
                            style: TextStyle(
                              color: _snapYellow,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.verified_rounded,
                            color: _snapYellow,
                            size: 14,
                          ),
                        ],
                      ),
                      Text(
                        'Interactive AR Lenses & Camera Filters',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.selectedLens != null && !widget.selectedLens!.isNone)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 14),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onSelectLens(MockFilterData.noneFilter);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Category Chips Bar
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildCategoryChip(FilterCategory.all, '🔥 Trending'),
                _buildCategoryChip(FilterCategory.fun, '🐶 Animals'),
                _buildCategoryChip(FilterCategory.beauty, '💖 Beauty'),
                _buildCategoryChip(FilterCategory.anime, '🐱 Anime'),
                _buildCategoryChip(FilterCategory.style, '🤖 Cyber & Style'),
                _buildCategoryChip(FilterCategory.nature, '🌸 Nature & Fantasy'),
                _buildCategoryChip(FilterCategory.love, '💘 Love'),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 16),

          // Lenses Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final lens = filtered[index];
                final isSelected = widget.selectedLens?.id == lens.id ||
                    (widget.selectedLens == null && lens.isNone);

                return _LensGridTile(
                  lens: lens,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onSelectLens(lens);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(FilterCategory cat, String label) {
    final isSelected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        selected: isSelected,
        selectedColor: snapYellow,
        backgroundColor: const Color(0xFF1F1C36),
        side: BorderSide(
          color: isSelected ? snapYellow : Colors.white12,
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onSelected: (val) {
          if (val) {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = cat);
          }
        },
      ),
    );
  }
}

class _LensGridTile extends StatelessWidget {
  final CameraFilterModel lens;
  final bool isSelected;
  final VoidCallback onTap;

  const _LensGridTile({
    required this.lens,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNone = lens.isNone;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Preview Ring
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFFC00)
                    : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 3.0 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      const BoxShadow(
                        color: Color(0x66FFFC00),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isNone
                        ? [const Color(0xFF2A283E), const Color(0xFF161426)]
                        : [lens.primaryColor, lens.secondaryColor],
                  ),
                ),
                child: Center(
                  child: lens.fallbackIcon != null
                      ? Icon(
                          lens.fallbackIcon,
                          color: Colors.white,
                          size: 32,
                        )
                      : const Icon(
                          Icons.face_retouching_natural_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Lens Name
          Text(
            lens.name,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFFC00) : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          // Snap Lens Studio  
          Text(
            isNone ? 'Camera' : 'Snap Lens',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
