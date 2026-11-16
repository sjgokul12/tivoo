import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../profile/domain/models/creator_verification_model.dart';
import '../../domain/models/family_team_model.dart';

class FamilyState {
  final CreatorVerificationModel verification;
  final List<FamilyTeamModel> allFamilies;
  final FamilyTeamModel currentFamily;
  final bool hasRequestedToJoin;

  static const int maxMembers = 100;

  bool get isFamilyFull => currentFamily.members.length >= maxMembers;
  int get spotsRemaining => (maxMembers - currentFamily.members.length).clamp(0, maxMembers);

  const FamilyState({
    required this.verification,
    required this.allFamilies,
    required this.currentFamily,
    this.hasRequestedToJoin = false,
  });

  FamilyState copyWith({
    CreatorVerificationModel? verification,
    List<FamilyTeamModel>? allFamilies,
    FamilyTeamModel? currentFamily,
    bool? hasRequestedToJoin,
  }) {
    return FamilyState(
      verification: verification ?? this.verification,
      allFamilies: allFamilies ?? this.allFamilies,
      currentFamily: currentFamily ?? this.currentFamily,
      hasRequestedToJoin: hasRequestedToJoin ?? this.hasRequestedToJoin,
    );
  }
}

class FamilyController extends StateNotifier<FamilyState> {
  FamilyController() : super(_initialState());

  static FamilyState _initialState() {
    final rsTechMembers = [
      const FamilyMemberModel(
        id: 'member_1',
        name: 'Ananya ✨',
        avatar: AppAssets.avatarNeha,
        role: 'Leader 👑',
        joinedDate: 'Jan 2026',
        contributionStars: 142500,
        tikiId: 'ID: 8084806861',
        isFollowing: true,
      ),
      const FamilyMemberModel(
        id: 'member_2',
        name: 'Karthik',
        avatar: AppAssets.avatarKarthik,
        role: 'Elder ⭐',
        joinedDate: 'Jan 2026',
        contributionStars: 98400,
        tikiId: 'ID: 412091',
        isFollowing: false,
      ),
      const FamilyMemberModel(
        id: 'member_3',
        name: 'Priya',
        avatar: AppAssets.avatarPriya,
        role: 'Member',
        joinedDate: 'Feb 2026',
        contributionStars: 84200,
        tikiId: 'ID: 4892104',
        isFollowing: true,
      ),
      const FamilyMemberModel(
        id: 'member_4',
        name: 'Arun',
        avatar: AppAssets.avatarArun,
        role: 'Member',
        joinedDate: 'Feb 2026',
        contributionStars: 76500,
        tikiId: 'ID: 994012',
        isFollowing: false,
      ),
      const FamilyMemberModel(
        id: 'member_5',
        name: 'Maya',
        avatar: AppAssets.avatarSneha,
        role: 'Member',
        joinedDate: 'Feb 2026',
        contributionStars: 65300,
        tikiId: 'ID: 558291',
        isFollowing: false,
        isRequested: true,
      ),
      const FamilyMemberModel(
        id: 'member_6',
        name: 'Saran',
        avatar: AppAssets.avatarSaran,
        role: 'Member',
        joinedDate: 'Feb 2026',
        contributionStars: 54100,
        tikiId: 'ID: 671204',
        isFollowing: true,
      ),
      const FamilyMemberModel(
        id: 'member_7',
        name: 'Divya',
        avatar: AppAssets.avatarDiya,
        role: 'Member',
        joinedDate: 'Mar 2026',
        contributionStars: 48900,
        tikiId: 'ID: 772109',
        isFollowing: false,
      ),
      const FamilyMemberModel(
        id: 'member_8',
        name: 'Vikram',
        avatar: AppAssets.avatarVicky,
        role: 'Member',
        joinedDate: 'Mar 2026',
        contributionStars: 42700,
        tikiId: 'ID: 881920',
        isFollowing: false,
      ),
      const FamilyMemberModel(
        id: 'member_9',
        name: 'Meena',
        avatar: AppAssets.avatarMeena,
        role: 'Member',
        joinedDate: 'Mar 2026',
        contributionStars: 38500,
        tikiId: 'ID: 391024',
        isFollowing: true,
      ),
      const FamilyMemberModel(
        id: 'member_10',
        name: 'Kavya',
        avatar: AppAssets.status4,
        role: 'Member',
        joinedDate: 'Mar 2026',
        contributionStars: 32100,
        tikiId: 'ID: 551920',
        isFollowing: false,
      ),
      const FamilyMemberModel(
        id: 'member_11',
        name: 'Arvind',
        avatar: AppAssets.status1,
        role: 'Member',
        joinedDate: 'Mar 2026',
        contributionStars: 28400,
        tikiId: 'ID: 712903',
        isFollowing: false,
        isRequested: true,
      ),
      const FamilyMemberModel(
        id: 'member_12',
        name: 'Nisha',
        avatar: AppAssets.status3,
        role: 'Member',
        joinedDate: 'Apr 2026',
        contributionStars: 24600,
        tikiId: 'ID: 820194',
        isFollowing: false,
      ),
      const FamilyMemberModel(
        id: 'member_13',
        name: 'Lokesh',
        avatar: AppAssets.status5,
        role: 'Member',
        joinedDate: 'Apr 2026',
        contributionStars: 19800,
        tikiId: 'ID: 901235',
        isFollowing: true,
      ),
      const FamilyMemberModel(
        id: 'member_14',
        name: 'Daisy',
        avatar: AppAssets.status2,
        role: 'Elder ⭐',
        joinedDate: 'Apr 2026',
        contributionStars: 16500,
        tikiId: 'ID: 312091',
        isFollowing: true,
      ),
      const FamilyMemberModel(
        id: 'member_15',
        name: 'Aarya',
        avatar: AppAssets.avatarSneha,
        role: 'Member',
        joinedDate: 'Apr 2026',
        contributionStars: 14200,
        tikiId: 'ID: 412998',
        isFollowing: false,
      ),
      const FamilyMemberModel(
        id: 'member_16',
        name: 'Mishri',
        avatar: AppAssets.avatarMeena,
        role: 'Member',
        joinedDate: 'Apr 2026',
        contributionStars: 11800,
        tikiId: 'ID: 512001',
        isFollowing: false,
      ),
    ];

    final rsTechPending = [
      FamilyJoinRequestModel(
        id: 'req_1',
        userId: 'user_priya',
        userName: 'Priya Singh',
        userAvatar: AppAssets.avatarPriya,
        userTikiId: 'ID: 4892104',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      FamilyJoinRequestModel(
        id: 'req_2',
        userId: 'user_arun',
        userName: 'Arun Kumar',
        userAvatar: AppAssets.avatarArun,
        userTikiId: 'ID: 994012',
        requestedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    final rsTech = FamilyTeamModel(
      id: 'family_rs_tech',
      name: 'Tivoo Angels ✨',
      leaderId: 'ananya_leader',
      leaderName: 'Ananya ✨',
      leaderAvatar: AppAssets.avatarNeha,
      slogan: 'Together We Shine ✨ • Support in PK • Top Ranked Family 🔥',
      totalPower: 798500,
      diamonds: 320000,
      memberCount: rsTechMembers.length,
      members: rsTechMembers,
      pendingRequests: rsTechPending,
      badgeIcon: '🛡️',
      region: 'India',
      language: 'Tamil',
    );

    return FamilyState(
      verification: const CreatorVerificationModel(),
      allFamilies: [rsTech],
      currentFamily: rsTech,
    );
  }

  /// User submits a request to join the Family (dispatched as private notification to Leader)
  void submitJoinRequest({
    String userName = 'Kasshvi',
    String userAvatar = AppAssets.avatarDiya,
    String userTikiId = 'ID: 10341053',
  }) {
    if (state.isFamilyFull) return;

    final alreadyPending = state.currentFamily.pendingRequests.any(
      (r) => r.userName.toLowerCase() == userName.toLowerCase() || r.userTikiId == userTikiId,
    );
    if (alreadyPending) {
      state = state.copyWith(hasRequestedToJoin: true);
      return;
    }

    final newRequest = FamilyJoinRequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      userAvatar: userAvatar,
      userTikiId: userTikiId,
      requestedAt: DateTime.now(),
    );

    final updatedPending = [newRequest, ...state.currentFamily.pendingRequests];
    final updatedFamily = state.currentFamily.copyWith(pendingRequests: updatedPending);

    state = state.copyWith(
      currentFamily: updatedFamily,
      hasRequestedToJoin: true,
    );
  }

  /// Reset join request state (useful for UI test demonstration)
  void resetJoinRequest() {
    state = state.copyWith(hasRequestedToJoin: false);
  }

  /// Accept join request (Leader approval)
  void acceptJoinRequest(String requestId) {
    if (state.isFamilyFull) return;

    final pending = List<FamilyJoinRequestModel>.from(state.currentFamily.pendingRequests);
    final index = pending.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final target = pending.removeAt(index);
    final newMember = FamilyMemberModel(
      id: 'member_${DateTime.now().millisecondsSinceEpoch}',
      name: target.userName,
      avatar: target.userAvatar,
      role: 'Member',
      joinedDate: 'Today',
      tikiId: target.userTikiId,
    );

    final updatedMembers = List<FamilyMemberModel>.from(state.currentFamily.members)..add(newMember);
    final updatedFamily = state.currentFamily.copyWith(
      members: updatedMembers,
      pendingRequests: pending,
      memberCount: updatedMembers.length,
    );

    state = state.copyWith(
      currentFamily: updatedFamily,
      hasRequestedToJoin: target.userName == 'Kasshvi' ? false : state.hasRequestedToJoin,
    );
  }

  /// Decline join request
  void declineJoinRequest(String requestId) {
    final pending = List<FamilyJoinRequestModel>.from(state.currentFamily.pendingRequests);
    final index = pending.indexWhere((r) => r.id == requestId);
    if (index == -1) return;
    final target = pending.removeAt(index);
    state = state.copyWith(
      currentFamily: state.currentFamily.copyWith(pendingRequests: pending),
      hasRequestedToJoin: target.userName == 'Kasshvi' ? false : state.hasRequestedToJoin,
    );
  }

  /// Claim Gray Tivoo verification
  void claimGrayTiki() {
    state = state.copyWith(
      verification: state.verification.copyWith(
        badgeTier: TikiBadgeTier.grayTiki,
        hasGrayTiki: true,
        currentViews: 500,
      ),
    );
  }

  void claimGrayTivoo() => claimGrayTiki();

  /// Create a new Family Team (Allowed only with Gray Tiki)
  bool createFamilyTeam({
    required String name,
    required String slogan,
  }) {
    if (!state.verification.canCreateFamily) {
      return false;
    }

    final newFamily = FamilyTeamModel(
      id: 'family_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'MY FAMILY' : name.trim(),
      leaderId: 'rohit_rajdhani66',
      leaderName: 'Rohit Rajdhani',
      leaderAvatar: AppAssets.status1,
      slogan: slogan.trim().isEmpty ? 'Welcome to our Family team!' : slogan.trim(),
      memberCount: 1,
      members: [
        const FamilyMemberModel(
          id: 'member_leader',
          name: 'Rohit Rajdhani',
          avatar: AppAssets.status1,
          role: 'Leader 👑',
          joinedDate: 'Today',
          tikiId: 'ID: 8084806861',
        ),
      ],
      pendingRequests: [],
    );

    state = state.copyWith(
      currentFamily: newFamily,
      allFamilies: [newFamily, ...state.allFamilies],
      verification: state.verification.copyWith(
        familyId: newFamily.id,
        familyName: newFamily.name,
        isFamilyLeader: true,
      ),
    );
    return true;
  }

  /// Toggles follow status for a member (Follow -> Following -> Follow)
  void toggleMemberFollow(String memberId) {
    final updatedMembers = state.currentFamily.members.map((m) {
      if (m.id != memberId) return m;
      if (!m.isFollowing && !m.isRequested) {
        return m.copyWith(isFollowing: true, isRequested: false);
      } else if (m.isFollowing) {
        return m.copyWith(isFollowing: false, isRequested: false);
      } else {
        return m.copyWith(isFollowing: false, isRequested: false);
      }
    }).toList();

    state = state.copyWith(
      currentFamily: state.currentFamily.copyWith(members: updatedMembers),
    );
  }

  /// Leaves the current family
  void leaveFamily() {
    state = state.copyWith(
      hasRequestedToJoin: false,
      verification: state.verification.copyWith(
        familyId: '',
        familyName: '',
        isFamilyLeader: false,
      ),
    );
  }
}

final familyControllerProvider = StateNotifierProvider<FamilyController, FamilyState>((ref) {
  return FamilyController();
});
