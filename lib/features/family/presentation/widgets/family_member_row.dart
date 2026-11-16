import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/models/family_team_model.dart';
import 'family_follow_button.dart';
import 'family_stars_badge.dart';

/// Member Row (Rank 2+):
/// - Left: Rank number + Member Avatar (touchable to view profile)
/// - Middle: Member Name (touchable) + Elder badge (if any), Follow button below
/// - Right: Big, prominent, highly visible STARS panel
class FamilyMemberRow extends StatelessWidget {
  final FamilyMemberModel member;
  final int rank;
  final void Function(FamilyMemberModel member) onProfileTap;

  const FamilyMemberRow({
    super.key,
    required this.member,
    required this.rank,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131122),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank Number
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: rank <= 3 ? const Color(0xFFFFD54F) : Colors.white60,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Member Avatar (touchable)
          GestureDetector(
            onTap: () => onProfileTap(member),
            child: CustomAvatar(radius: 20, assetPath: member.avatar),
          ),
          const SizedBox(width: 10),

          // Member Name & Follow button down below the profile
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onProfileTap(member),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (member.role.contains('Elder')) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x33FFD54F),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Elder',
                            style: TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // Small workable follow panel down below the profile
                FamilyFollowButton(member: member),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // RIGHT SIDE: Big, Highly Visible Prominent Stars Panel
          FamilyStarsBadge(stars: member.contributionStars, isLeader: false),
        ],
      ),
    );
  }
}

