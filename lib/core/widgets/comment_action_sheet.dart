import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/custom_avatar.dart';
import '../../features/live_stream/domain/models/live_comment.dart';

/// Instant Report and Block User Popup:
/// Options:
/// - Report (shows "[ ✓ Comment reported ]" green glowing banner)
/// - Block user (shows "[ 🚫 User blocked ]" red glowing banner and removes user comments)
class CommentActionSheet {
  CommentActionSheet._();

  static Future<void> show(
    BuildContext context, {
    required LiveComment comment,
    bool isCreator = false,
    VoidCallback? onPause,
    VoidCallback? onResume,
    VoidCallback? onDelete,
    VoidCallback? onReported,
    VoidCallback? onBlocked,
  }) async {
    // 1. Immediately pause all moving comments
    onPause?.call();

    try {
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'CommentOptions',
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
        transitionBuilder: (ctx, anim1, anim2, child) {
          final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
          return ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: anim1,
              child: Center(
                child: _InstantReportDialog(
                  comment: comment,
                  onReport: () {
                    Navigator.of(ctx).pop();
                    onReported?.call();
                    showSuccessBanner(
                      context,
                      text: 'Comment reported',
                      icon: Icons.check_rounded,
                      accentColor: const Color(0xFF00E676),
                    );
                  },
                  onBlock: () {
                    Navigator.of(ctx).pop();
                    onBlocked?.call();
                    showSuccessBanner(
                      context,
                      text: 'User blocked',
                      icon: Icons.block_rounded,
                      accentColor: const Color(0xFFFF2D55),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    } finally {
      // 2. Always resume moving comments once dialog is dismissed or completed
      onResume?.call();
    }
  }

  /// Floating Top Success Banner with glowing neon border and dark glass background
  static void showSuccessBanner(
    BuildContext context, {
    required String text,
    required IconData icon,
    required Color accentColor,
  }) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TopSuccessBanner(
        text: text,
        icon: icon,
        accentColor: accentColor,
        onDismiss: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    overlayState.insert(entry);
  }

  /// Backwards compatible helper for reported banner
  static void showReportSuccessBanner(BuildContext context) {
    showSuccessBanner(
      context,
      text: 'Comment reported',
      icon: Icons.check_rounded,
      accentColor: const Color(0xFF00E676),
    );
  }
}

/// Instant Report & Block Dialog
class _InstantReportDialog extends StatelessWidget {
  final LiveComment comment;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  const _InstantReportDialog({
    required this.comment,
    required this.onReport,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isSmall = media.width < 360;
    final dialogWidth = (media.width * 0.84).clamp(280.0, 340.0);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: dialogWidth,
            padding: EdgeInsets.fromLTRB(18, 14, 18, isSmall ? 16 : 20),
            decoration: BoxDecoration(
              color: const Color(0xE6141829),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0x33FF2D55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFFF2D55).withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                    ),
                  ),
                ),

                // Center Glowing Red Shield/Flag Halo
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF2D55).withValues(alpha: 0.45),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFF2D55), Color(0xFFC70039)],
                        radius: 0.85,
                      ),
                      border: Border.all(
                        color: const Color(0xFFFF6B8B),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                const Text(
                  'Comment options',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Comment Snippet Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2036),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      CustomAvatar(
                        radius: 15,
                        imageUrl: comment.userAvatarUrl,
                        assetPath: comment.userAssetPath ?? AppAssets.status4,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.userName,
                              style: const TextStyle(
                                color: Color(0xFFFFDF00),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              comment.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Option 1: Report Button (Primary Red Gradient Pill)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF2D55), Color(0xFFFF5277)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2D55).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag_rounded, color: Colors.white, size: 19),
                          SizedBox(width: 8),
                          Text(
                            'Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Option 2: Block User Button (Frosted Dark Glass with Crimson Accent)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onBlock,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0x1AFF2D55),
                      foregroundColor: const Color(0xFFFF6482),
                      side: BorderSide(
                        color: const Color(0xFFFF2D55).withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block_rounded, color: Color(0xFFFF6482), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Block user',
                          style: TextStyle(
                            color: Color(0xFFFF6482),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
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
  }
}

/// Floating Top Success Banner
class _TopSuccessBanner extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onDismiss;

  const _TopSuccessBanner({
    required this.text,
    required this.icon,
    required this.accentColor,
    required this.onDismiss,
  });

  @override
  State<_TopSuccessBanner> createState() => _TopSuccessBannerState();
}

class _TopSuccessBannerState extends State<_TopSuccessBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _slideAnim = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _animController.forward();

    // Auto dismiss after 2.4 seconds
    Future.delayed(const Duration(milliseconds: 2400), () async {
      if (!mounted) return;
      await _animController.reverse();
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final topPad = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPad + 48.0,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: Opacity(
                opacity: _fadeAnim.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  constraints: BoxConstraints(maxWidth: media.width * 0.74),
                  decoration: BoxDecoration(
                    color: const Color(0xE60D1712),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.accentColor,
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                      const BoxShadow(
                        color: Colors.black87,
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.black,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
