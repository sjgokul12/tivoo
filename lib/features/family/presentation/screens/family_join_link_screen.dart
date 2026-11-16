import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../controllers/family_controller.dart';

/// Family Joining Link Screen (Invitee Preview Screen).
/// Rendered when an invitee opens a Family join link (e.g. https://tivoo.app/family/join?code=RSTECH2026).
/// Displays family details, logo, leader, member roster, available spots, and a prominent "Join to Family" button.
class FamilyJoinLinkScreen extends ConsumerStatefulWidget {
  const FamilyJoinLinkScreen({super.key});

  @override
  ConsumerState<FamilyJoinLinkScreen> createState() => _FamilyJoinLinkScreenState();
}

class _FamilyJoinLinkScreenState extends ConsumerState<FamilyJoinLinkScreen> {
  bool _justSubmitted = false;

  void _handleJoinRequest(FamilyState state) {
    if (state.isFamilyFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorry, this Family is already at maximum capacity (100/100)!'),
          backgroundColor: Color(0xFFFF2D55),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();

    // Submit join request as applicant (e.g. Kasshvi)
    ref.read(familyControllerProvider.notifier).submitJoinRequest(
      userName: 'Kasshvi',
      userAvatar: AppAssets.avatarDiya,
      userTikiId: 'ID: 10341053',
    );

    setState(() => _justSubmitted = true);

    // Show stylish Facebook-style confirmation dialog
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF141222),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 28, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.black, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                'Join Request Sent! 📩',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your request to join "${state.currentFamily.name}" has been sent to Leader ${state.currentFamily.leaderName}. You will be added to the team once approved.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuxeColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Understood',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyControllerProvider);
    final family = state.currentFamily;
    final isFull = state.isFamilyFull;
    final hasRequested = state.hasRequestedToJoin || _justSubmitted;
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0912),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Family Invitation',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'tivoo.app/family/join?code=${family.name.replaceAll(' ', '')}',
              style: const TextStyle(color: LuxeColors.gold, fontSize: 10.5, fontFamily: 'monospace'),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Preview Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1A33), Color(0xFF131022)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: LuxeColors.gold.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black87, blurRadius: 24, offset: Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Badge Icon
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(family.badgeIcon, style: const TextStyle(fontSize: 38)),
                                ),
                              ),
                              const Positioned(
                                top: -6,
                                right: -4,
                                child: Text('👑', style: TextStyle(fontSize: 20)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Family Name & Top Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                family.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: LuxeColors.gold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'TOP FAMILY',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Leader Details Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomAvatar(radius: 14, assetPath: family.leaderAvatar),
                                const SizedBox(width: 8),
                                Text(
                                  'Leader: ${family.leaderName} 👑',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD54F),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description / Slogan
                          Text(
                            family.slogan,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Metrics & Capacity Row
                    Row(
                      children: [
                        // Members Count Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF151324),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.group_rounded, color: Color(0xFF00E5FF), size: 16),
                                    SizedBox(width: 6),
                                    Text('Members', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${family.memberCount} / 100',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Spots Remaining Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF151324),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isFull
                                    ? const Color(0xFFFF2D55).withValues(alpha: 0.5)
                                    : const Color(0xFF00E676).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isFull ? Icons.lock_rounded : Icons.event_seat_rounded,
                                      color: isFull ? const Color(0xFFFF2D55) : const Color(0xFF00E676),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Available',
                                      style: TextStyle(
                                        color: isFull ? const Color(0xFFFF2D55) : const Color(0xFF00E676),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isFull ? 'CAPACITY FULL' : '${state.spotsRemaining} spots left',
                                  style: TextStyle(
                                    color: isFull ? const Color(0xFFFF2D55) : const Color(0xFF00E676),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 3. Family Benefits Section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141222),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why Join ${family.name}?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _benefitTile(Icons.bolt_rounded, 'PK Battle Co-Op', 'Family members back each other in 1v1 live battles.'),
                          const SizedBox(height: 8),
                          _benefitTile(Icons.verified_rounded, 'Exclusive Badge', 'Display the official Family shield in livestreams & comments.'),
                          const SizedBox(height: 8),
                          _benefitTile(Icons.forum_rounded, 'Creator Network', 'Private chat, strategies, and growth coaching from Leader Rohit.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 4. Privacy Notice for Non-Members
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: LuxeColors.gold, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Member list and clan star rankings are protected and visible to verified Family members.',
                              style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 5. Prominent Bottom Action Bar
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + mq.padding.bottom),
              decoration: const BoxDecoration(
                color: Color(0xFF131122),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: isFull
                  ? Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x33FF2D55),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFF2D55)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock_rounded, color: Color(0xFFFF2D55), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Family is Full (100/100) • Closed',
                            style: TextStyle(color: Color(0xFFFF2D55), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : hasRequested
                      ? Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2B20),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.hourglass_top_rounded, color: Color(0xFF00E676), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Request Sent (Pending Approval) ⏳',
                                style: TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LuxeColors.gold,
                              foregroundColor: Colors.black,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => _handleJoinRequest(state),
                            icon: const Icon(Icons.group_add_rounded, color: Colors.black, size: 20),
                            label: const Text(
                              'Join to Family',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitTile(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: LuxeColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: LuxeColors.gold, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              Text(
                desc,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
