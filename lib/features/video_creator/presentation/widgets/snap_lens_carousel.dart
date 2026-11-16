import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../broadcast/domain/models/camera_filter_model.dart';

/// Horizontal Snapchat-style AR Lens Carousel rendered in the camera viewfinder.
/// Enables seamless one-tap switching between Snap AR lenses with live animated preview.
class SnapLensCarousel extends StatelessWidget {
  final List<CameraFilterModel> lenses;
  final CameraFilterModel? selectedLens;
  final ValueChanged<CameraFilterModel> onSelectLens;
  final VoidCallback onOpenStudio;

  const SnapLensCarousel({
    super.key,
    required this.lenses,
    required this.selectedLens,
    required this.onSelectLens,
    required this.onOpenStudio,
  });

  static const Color snapYellow = Color(0xFFFFFC00);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lens Studio Header Pill & Quick Open Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onOpenStudio();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: snapYellow.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: snapYellow.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: snapYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.black,
                          size: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Snap Lens Studio',
                        style: TextStyle(
                          color: snapYellow,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: snapYellow,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Horizontally Scrollable Circular Lens Icons
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: lenses.length,
            itemBuilder: (context, index) {
              final lens = lenses[index];
              final isSelected = selectedLens?.id == lens.id ||
                  (selectedLens == null && lens.isNone);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectLens(lens);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: isSelected ? 58 : 50,
                        height: isSelected ? 58 : 50,
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? snapYellow : Colors.white.withValues(alpha: 0.25),
                            width: isSelected ? 2.8 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: snapYellow.withValues(alpha: 0.5),
                                    blurRadius: 12,
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
                                colors: lens.isNone
                                    ? [const Color(0xFF2A283E), const Color(0xFF161426)]
                                    : [lens.primaryColor, lens.secondaryColor],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                lens.fallbackIcon ?? Icons.face_rounded,
                                color: Colors.white,
                                size: isSelected ? 28 : 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 58,
                        child: Text(
                          lens.name,
                          style: TextStyle(
                            color: isSelected ? snapYellow : Colors.white70,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

