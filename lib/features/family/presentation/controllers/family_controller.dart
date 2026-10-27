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
        name: 'Rohit Rajdhani',
        avatar: AppAssets.status1,
        role: 'Leader 👑',
        joinedDate: 'Jan 2026',
        tikiId: 'ID: 8084806861',
      ),
      const FamilyMemberModel(
        id: 'member_2',
        name: 'Daisy',
        avatar: AppAssets.status2,
        role: 'Elder ⭐',
        joinedDate: 'Feb 2026',
        tikiId: 'ID: 412091',
      ),
      const FamilyMemberModel(
        id: 'member_3',
        name: 'Aarya',
        avatar: AppAssets.status3,
        role: 'Member',
        joinedDate: 'Feb 2026',
        tikiId: 'ID: 558291',
      ),
      const FamilyMemberModel(
        id: 'member_4',
        name: 'Mishri',
        avatar: AppAssets.status4,
        role: 'Member',
        joinedDate: 'Mar 2026',
        tikiId: 'ID: 772109',
      ),
    ];

    final rsTech = FamilyTeamModel(
      id: 'family_rs_tech',
      name: 'RS TECH',
      leaderId: 'rohit_rajdhani66',
      leaderName: 'Rohit Rajdhani',
      leaderAvatar: AppAssets.status1,
      slogan: 'Official RS TECH Family • Support in PK • Quality Creators Only 🔥',
      totalPower: 245000,
      diamonds: 118000,
      memberCount: 4,
      members: rsTechMembers,
      pendingRequests: const [],
      badgeIcon: '🛡️',
    );

    return FamilyState(
      verification: const CreatorVerificationModel(),
      allFamilies: [rsTech],
      currentFamily: rsTech,
    );
  }

  /// User submits a request to join the Family (dispatched as private notification to Leader)
  void submitJoinRequest({
    required String userName,
    required String userAvatar,
    required String userTikiId,
  }) {
    if (state.isFamilyFull) return;

    final newRequest = FamilyJoinRequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_current',
      userName: userName,
      userAvatar: userAvatar,
      userTikiId: userTikiId,
      requestedAt: DateTime.now(),
    );

    final updatedPending = List<FamilyJoinRequestModel>.from(state.currentFamily.pendingRequests)..add(newRequest);
    final updatedFamily = state.currentFamily.copyWith(pendingRequests: updatedPending);

    state = state.copyWith(
      currentFamily: updatedFamily,
      hasRequestedToJoin: true,
    );
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
      joinedDate: 'Just now',
      tikiId: target.userTikiId,
    );

    final updatedMembers = List<FamilyMemberModel>.from(state.currentFamily.members)..add(newMember);
    final updatedFamily = state.currentFamily.copyWith(
      members: updatedMembers,
      pendingRequests: pending,
      memberCount: updatedMembers.length,
    );

    state = state.copyWith(currentFamily: updatedFamily);
  }

  /// Decline join request
  void declineJoinRequest(String requestId) {
    final pending = List<FamilyJoinRequestModel>.from(state.currentFamily.pendingRequests);
    pending.removeWhere((r) => r.id == requestId);
    state = state.copyWith(currentFamily: state.currentFamily.copyWith(pendingRequests: pending));
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
}

final familyControllerProvider = StateNotifierProvider<FamilyController, FamilyState>((ref) {
  return FamilyController();
});
