import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import '../../../live_stream/presentation/widgets/purchase_stars_sheet.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../domain/models/live_stream_card_model.dart';

/// Interactive Streamer ID Profile Sheet.
///
/// Opened directly when tapping the streamer avatar / ID on the live stream.
/// Presents the creator's ID, verification status, full bio, stats, and
/// quick actions (Follow, Send Stars, Send Gifts, View Full Profile).
class StreamerIdProfileSheet extends StatefulWidget {
  final LiveStreamCardModel stream;

  const StreamerIdProfileSheet({super.key, required this.stream});

  static Future<void> show(BuildContext context, {required LiveStreamCardModel stream}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StreamerIdProfileSheet(stream: stream),
    );
  }

  @override
  State<StreamerIdProfileSheet> createState() => _StreamerIdProfileSheetState();
}

class _StreamerIdProfileSheetState extends State<StreamerIdProfileSheet> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.stream.isFollowing;
  }

  void _copyUserId() {
    Clipboard.setData(ClipboardData(text: widget.stream.displayUserId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied User ID: ${widget.stream.displayUserId} 📋'),
        backgroundColor: const Color(0xFF1E2840),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.stream;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D111A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0x33FFDF00), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 30, offset: Offset(0, -6))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Drag Handle & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Streamer Avatar with Gold Border & Live Indicator
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFDF00), width: 2.2),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFDF00).withValues(alpha: 0.35), blurRadius: 16)],
                  ),
                  child: CustomAvatar(
                    radius: 40,
                    assetPath: stream.streamerAssetPath,
                    imageUrl: stream.streamerAvatarUrl,
                  ),
                ),
                if (stream.isLive)
                  Positioned(
                    bottom: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                          SizedBox(width: 3),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Streamer Name & Verified Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stream.streamerName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                if (stream.isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, color: Color(0xFFFFDF00), size: 19),
                ],
              ],
            ),

            const SizedBox(height: 6),

            // Prominent User ID Pill with Copy Action
            GestureDetector(
              onTap: _copyUserId,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF161E30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x66FFDF00), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.badge_outlined, color: Color(0xFFFFDF00), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'User ID: ${stream.displayUserId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy_rounded, color: Colors.white70, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Bio / Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                stream.streamerBio,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 18),

            // 4 Key Statistics Cards
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF121724),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Followers', '120.4K'),
                  _buildDivider(),
                  _buildStatItem('Following', '142'),
                  _buildDivider(),
                  _buildStatItem('Diamonds', stream.diamondsCount),
                  _buildDivider(),
                  _buildStatItem('Viewers', stream.viewersCount),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Action Buttons: Follow + Send Stars + Send Gift
            Row(
              children: [
                // Follow / Following Toggle Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _isFollowing = !_isFollowing);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isFollowing
                                ? 'Now following ${stream.streamerName}!'
                                : 'Unfollowed ${stream.streamerName}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing ? const Color(0xFF222B3D) : const Color(0xFFFFDF00),
                      foregroundColor: _isFollowing ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isFollowing ? Icons.check : Icons.person_add_rounded, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _isFollowing ? 'Following' : 'Follow',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // StarUp / Send Stars Button
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PurchaseStarsSheet.show(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFDF00),
                      side: const BorderSide(color: Color(0xFFFFDF00), width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 16),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Send Stars',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Gift Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    GiftBottomSheet.show(context, (gift) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sent ${gift.name} to ${stream.streamerName}! 🎁'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2338),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.card_giftcard_rounded, color: AppColors.primaryPink, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // View Full Profile Action
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Full Profile',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 22, color: Colors.white12);
  }
}
