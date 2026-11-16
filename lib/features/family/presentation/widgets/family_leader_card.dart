import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/models/family_team_model.dart';
import 'family_follow_button.dart';
import 'family_stars_badge.dart';

/// Leader Spotlight Card (Rank 1):
/// - Left: Rank 1 + Leader Avatar (touchable to view profile)
/// - Middle: Leader Name (touchable to view profile) + Leader role badge, Follow button below
/// - Right: Big, prominent, highly visible GOLD STARS panel
class FamilyLeaderCard extends StatelessWidget {
  final FamilyMemberModel leader;
  final void Function(FamilyMemberModel member) onProfileTap;

  const FamilyLeaderCard({
    super.key,
    required this.leader,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131024),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44FFD700),
            blurRadius: 14,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank 1 Number
          const SizedBox(
            width: 24,
            child: Text(
              '1',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Color(0xAAFFB300), blurRadius: 10)],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Leader Avatar with Gold Halo (touchable)
          GestureDetector(
            onTap: () => onProfileTap(leader),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFFEA79), Color(0xFFFF8F00)],
                ),
                boxShadow: [BoxShadow(color: Color(0x66FFD700), blurRadius: 8)],
              ),
              child: CustomAvatar(radius: 22, assetPath: leader.avatar),
            ),
          ),
          const SizedBox(width: 10),

          // Leader Name & Follow button placed DOWN BELOW the profile
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onProfileTap(leader),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          leader.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF2DC0), Color(0xFF7B1FA2)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Leader',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // Small workable follow panel down below the profile
                FamilyFollowButton(member: leader),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // RIGHT SIDE: Big, Highly Visible Prominent Stars Panel
          FamilyStarsBadge(stars: leader.contributionStars, isLeader: true),
        ],
      ),
    );
  }
}

