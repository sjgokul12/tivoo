import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/tivoo_logo.dart';
import '../../../../core/widgets/tivoo_share_sheet.dart';
import '../../../home/domain/models/live_stream_card_model.dart';
import '../../../home/presentation/widgets/streamer_id_profile_sheet.dart';
import '../controllers/family_controller.dart';
import '../../domain/models/family_team_model.dart';
import '../widgets/family_hero_card.dart';
import '../widgets/family_leader_card.dart';
import '../widgets/family_member_row.dart';
import '../widgets/family_stars_badge.dart';

/// "View Family" Screen matching the reference design for Leader & Members:
/// - Top bar: TIVOO 👑 Family Team, Share icon, Leave Family button, and Member count badge
/// - Hero Banner: Crest, Family Name ("Tivoo Angels ✨"), Region | Language, Slogan, Total Family Stars
/// - Leader Spotlight Card: Rank 1, Leader details (touch to view profile), Follow button below, Big Golden Stars on right
/// - Members List: Rank 2+, Member Avatar + Name (touch to view profile), Follow pill below, Big Stars on right
/// - Bottom bar: Removed for members (already in family). If isMember == false, shows "Join to Family".
class ViewFamilyDetailsScreen extends ConsumerStatefulWidget {
  final FamilyTeamModel? family;
  final bool isMember;

  const ViewFamilyDetailsScreen({
    super.key,
    this.family,
    this.isMember = true,
  });

  @override
  ConsumerState<ViewFamilyDetailsScreen> createState() => _ViewFamilyDetailsScreenState();
}

class _ViewFamilyDetailsScreenState extends ConsumerState<ViewFamilyDetailsScreen> {
  void _shareFamily(BuildContext context, FamilyTeamModel family) {
    final link = 'https://tivoo.app/family/join?code=${family.name.replaceAll(' ', '')}2026';
    TivooShareSheet.show(
      context,
      title: 'Share Family',
      subtitle: 'Invite creators to join ${family.name} on Tivoo',
      shareUrl: link,
      shareText: '🛡️ Join our Family team "${family.name}" on Tivoo! Tap the link to view details and request to join: $link',
    );
  }

  void _confirmLeaveFamily(BuildContext context, FamilyTeamModel family) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181330),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Colors.white24, width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5252), size: 24),
            SizedBox(width: 8),
            Text(
              'Leave Family?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to leave "${family.name}"? You will lose access to team benefits, clan stars, and PK battle support.',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D55),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(familyControllerProvider.notifier).leaveFamily();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You have left "${family.name}" 👋'),
                  backgroundColor: const Color(0xFF2E1A29),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Leave', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _openMemberProfile(BuildContext context, FamilyMemberModel member) {
    HapticFeedback.lightImpact();
    StreamerIdProfileSheet.show(
      context,
      stream: LiveStreamCardModel(
        id: member.id,
        userId: member.tikiId.isNotEmpty ? member.tikiId : '8084806861',
        streamerName: member.name,
        streamerBio: member.role.contains('Leader')
            ? 'Family Leader of Tivoo Angels ✨'
            : 'Proud member of Tivoo Angels ✨',
        streamerAssetPath: member.avatar,
        category: member.role,
        diamondsCount: '${member.contributionStars}',
        viewersCount: '1.2K',
        isLive: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final isSmallScreen = screenWidth < 360;
    final bottomInset = mq.padding.bottom > 0 ? mq.padding.bottom : 12.0;

    final state = ref.watch(familyControllerProvider);
    final family = widget.family ?? state.currentFamily;
    final members = family.members;
    final totalStars = family.totalFamilyStars > 0 ? family.totalFamilyStars : family.totalPower;

    final leader = members.isNotEmpty
        ? members.first
        : FamilyMemberModel(
            id: 'leader_default',
            name: family.leaderName,
            avatar: family.leaderAvatar,
            role: 'Leader 👑',
            joinedDate: 'Jan 2026',
            contributionStars: 142500,
            tikiId: 'ID: 8084806861',
            isFollowing: true,
          );

    final otherMembers = members.length > 1 ? members.sublist(1) : <FamilyMemberModel>[];

    return Scaffold(
      backgroundColor: const Color(0xFF090812),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 52,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              // 1. Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 17),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Responsive Center Title with FittedBox (scales smoothly, ZERO overflow)
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TivooLogo(fontSize: isSmallScreen ? 18 : 20),
                      const SizedBox(width: 6),
                      const Text('👑', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 5),
                      Text(
                        isSmallScreen ? 'Family' : 'Family Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: isSmallScreen ? 14.5 : 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 3. Compact Action Controls: Share, Leave, Member count
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Share Family Link
                  GestureDetector(
                    onTap: () => _shareFamily(context, family),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.share_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Leave Family button (for members/leader)
                  if (widget.isMember) ...[
                    GestureDetector(
                      onTap: () => _confirmLeaveFamily(context, family),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D55).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF2D55).withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout_rounded, color: Color(0xFFFF5252), size: 11),
                            SizedBox(width: 3),
                            Text(
                              'Leave',
                              style: TextStyle(
                                color: Color(0xFFFF5252),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Member Count Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF2D55).withValues(alpha: 0.6),
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          '${members.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: widget.isMember,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Family Hero Banner Card
                    FamilyHeroCard(family: family, totalStars: totalStars),

                    const SizedBox(height: 14),

                    // 2. Leader Spotlight Card (Rank 1)
                    FamilyLeaderCard(
                      leader: leader,
                      onProfileTap: (m) => _openMemberProfile(context, m),
                    ),

                    const SizedBox(height: 18),

                    // 3. Section Header: Members Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Members (${members.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0x33FFD54F),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x66FFD54F)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${formatFamilyStars(totalStars)} Total',
                                style: const TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 4. Members List (Rank 2+)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: otherMembers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final member = otherMembers[index];
                        final rank = index + 2;
                        return FamilyMemberRow(
                          member: member,
                          rank: rank,
                          onProfileTap: (m) => _openMemberProfile(context, m),
                        );
                      },
                    ),

                    // Safe scroll clearance above system navigation bar
                    SizedBox(height: 16 + (widget.isMember ? bottomInset : 8)),
                  ],
                ),
              ),
            ),

            // 5. Bottom Panel: Only shown for non-members who opened via shared link!
            if (!widget.isMember) _buildBottomJoinButton(context, state, bottomInset),
          ],
        ),
      ),
    );
  }

  /// Bottom button only shown for visitors/non-members with responsive insets
  Widget _buildBottomJoinButton(BuildContext context, FamilyState state, double bottomInset) {
    final hasRequested = state.hasRequestedToJoin;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0E18),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: hasRequested ? const Color(0xFF231E3A) : LuxeColors.gold,
            foregroundColor: hasRequested ? LuxeColors.gold : Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: hasRequested ? 0 : 6,
            shadowColor: const Color(0x66FFD700),
          ),
          onPressed: hasRequested
              ? null
              : () {
                  HapticFeedback.heavyImpact();
                  ref.read(familyControllerProvider.notifier).submitJoinRequest();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🛡️ Request sent to Family Leader!'),
                      backgroundColor: Color(0xFF192233),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasRequested ? Icons.check_circle_rounded : Icons.person_add_rounded,
                  color: hasRequested ? LuxeColors.gold : Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasRequested ? 'Request Sent' : 'Join to Family',
                  style: TextStyle(
                    color: hasRequested ? LuxeColors.gold : Colors.black,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
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
