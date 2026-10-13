import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../controllers/family_controller.dart';

class FamilyTeamScreen extends ConsumerStatefulWidget {
  const FamilyTeamScreen({super.key});

  @override
  ConsumerState<FamilyTeamScreen> createState() => _FamilyTeamScreenState();
}

class _FamilyTeamScreenState extends ConsumerState<FamilyTeamScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyControllerProvider);
    final controller = ref.read(familyControllerProvider.notifier);
    final family = state.currentFamily;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          family.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Family invite link for ${family.name} copied! 🛡️')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Family Hero Banner
            _buildFamilyHeroBanner(family),

            const SizedBox(height: 12),

            // 2. Tab Bar: Members Roster & Leader Requests Tab
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Members (${family.memberCount})'),
                  Tab(text: 'Join Requests (${family.pendingRequests.length})'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Member Roster
                  _buildMembersList(family),

                  // Tab 2: Pending Join Requests with Leader Accept/Decline buttons
                  _buildJoinRequestsList(family, controller),
                ],
              ),
            ),

            // 4. Bottom Join Action (For new users to request joining)
            _buildBottomJoinBar(state, controller),
          ],
        ),
      ),
    );
  }

  /// 1. Family Hero Banner with Leader Avatar, Slogan, Power & Diamonds
  Widget _buildFamilyHeroBanner(dynamic family) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B2E), Color(0xFF12101C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Family Shield Emblem with Leader Crown
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.4), blurRadius: 10),
                      ],
                    ),
                    child: const Center(
                      child: Text('🛡️', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const Positioned(
                    top: -6,
                    right: -2,
                    child: Text('👑', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          family.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'TOP FAMILY',
                            style: TextStyle(color: Colors.black, fontSize: 8.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Leader: ${family.leaderName} 👑',
                      style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Slogan
          Text(
            family.slogan,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
          ),

          const SizedBox(height: 12),

          // Stats: Total Power & Diamonds
          Row(
            children: [
              _buildStatChip('⚡ Power', '${(family.totalPower / 1000).toStringAsFixed(1)}K', const Color(0xFF00B0FF)),
              const SizedBox(width: 10),
              _buildStatChip('💎 Diamonds', '${(family.diamonds / 1000).toStringAsFixed(1)}K', const Color(0xFFFF4081)),
              const SizedBox(width: 10),
              _buildStatChip('👥 Members', '${family.memberCount}', const Color(0xFF00E676)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  /// 2. Members Roster List
  Widget _buildMembersList(dynamic family) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: family.members.length,
      itemBuilder: (context, index) {
        final m = family.members[index];
        final isLeader = m.role.contains('Leader');

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isLeader ? const Color(0x33FFD700) : const Color(0xFF191724),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLeader ? const Color(0xFFFFD700) : Colors.white12,
              width: isLeader ? 1.2 : 0.6,
            ),
          ),
          child: Row(
            children: [
              CustomAvatar(radius: 18, assetPath: m.avatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLeader ? const Color(0xFFFFD700) : Colors.white12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m.role,
                            style: TextStyle(
                              color: isLeader ? Colors.black : Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m.tikiId} • Joined ${m.joinedDate}',
                      style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐ ', style: TextStyle(fontSize: 10)),
                  Text(
                    '${m.contributionStars}',
                    style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 3. Pending Join Requests with Leader Accept/Decline buttons
  Widget _buildJoinRequestsList(dynamic family, FamilyController controller) {
    if (family.pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00E676), size: 42),
            SizedBox(height: 8),
            Text('No pending requests', style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text('New applicant requests will appear here for Leader approval', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: family.pendingRequests.length,
      itemBuilder: (context, index) {
        final req = family.pendingRequests[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B2C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CustomAvatar(radius: 20, assetPath: req.userAvatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.userName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    Text(
                      req.userTikiId,
                      style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const Text('Wants to join Family', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),

              // Accept Button (Green)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  controller.acceptJoinRequest(req.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Accepted ${req.userName} into ${family.name}! 🎉')),
                  );
                },
                child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),

              const SizedBox(width: 6),

              // Decline Button (Dark)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                onPressed: () {
                  controller.declineJoinRequest(req.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Declined ${req.userName}')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 4. Bottom Join Bar for new applicants
  Widget _buildBottomJoinBar(FamilyState state, FamilyController controller) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF14121E),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.hasRequestedToJoin
                      ? Colors.grey.shade800
                      : const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: state.hasRequestedToJoin
                    ? null
                    : () {
                        controller.submitJoinRequest(
                          userName: 'Kasshvi',
                          userAvatar: AppAssets.status1,
                          userTikiId: 'ID: 10341053',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Join request sent to Leader Rohit Rajdhani! ⏳'),
                          ),
                        );
                      },
                icon: Icon(
                  state.hasRequestedToJoin ? Icons.hourglass_top_rounded : Icons.group_add_rounded,
                  color: state.hasRequestedToJoin ? Colors.white60 : Colors.black,
                  size: 18,
                ),
                label: Text(
                  state.hasRequestedToJoin ? 'Join Request Sent (Pending) ⏳' : 'Request to Join Family',
                  style: TextStyle(
                    color: state.hasRequestedToJoin ? Colors.white60 : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
