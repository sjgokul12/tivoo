import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import 'live_stream_viewers_sheet.dart';

/// Top Bar for Live Stream screen strictly matching Image 1:
/// - [((•)) LIVE] vibrant red pill badge with broadcast waves
/// - [👁 85.4K] dark translucent pill (tapping opens Viewers List sheet)
/// - Overlapping viewer photos stack + [+3] badge (tapping opens Viewers List)
/// - Close [✕] circular button on the top right
class LiveStreamTopBar extends StatelessWidget {
  final String viewersCount;
  final VoidCallback onCloseTap;

  const LiveStreamTopBar({
    super.key,
    this.viewersCount = '85.4K',
    required this.onCloseTap,
  });

  void _openViewerList(BuildContext context) {
    LiveStreamViewersSheet.show(
      context,
      totalViewersCount: '85,432',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 1. LIVE Pill Badge: ((•)) LIVE (Image 1 Screen 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF1744),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x88FF1744),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.sensors_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 2. Viewers Count Pill: 👁 85.4K (Tap opens viewers list!)
          GestureDetector(
            onTap: () => _openViewerList(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    viewersCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. Viewers Avatar Stack + (+3) badge (Tap opens viewers list matching Image 1 Step 1 -> Step 2)
          GestureDetector(
            onTap: () => _openViewerList(context),
            child: _buildViewersAvatarStack(context),
          ),

          const Spacer(),

          // 4. Close Button [✕]
          GestureDetector(
            onTap: onCloseTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.55),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewersAvatarStack(BuildContext context) {
    const viewerData = [
      {'name': 'Karthik', 'asset': AppAssets.status5},
      {'name': 'Aurora_X', 'asset': AppAssets.status4},
      {'name': 'Sam_99', 'asset': AppAssets.status2},
    ];

    return SizedBox(
      height: 30,
      width: 86,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 3 Overlapping Viewers
          for (int i = 0; i < viewerData.length; i++)
            Positioned(
              left: i * 18.0,
              top: 1,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomAvatar(
                    radius: 13,
                    assetPath: viewerData[i]['asset']!,
                  ),
                ),
              ),
            ),

          // [+3] Badge with Glowing Golden/Orange Halo Ring (Overlapping avatar 3 like Image 1)
          Positioned(
            left: 54.0,
            top: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141724),
                border: Border.all(
                  color: const Color(0xFFFFB300),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.85),
                    blurRadius: 10,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '+3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
