import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/family_team_model.dart';
import '../controllers/family_controller.dart';

/// Compact, workable follow pill button placed below member / leader name.
class FamilyFollowButton extends ConsumerWidget {
  final FamilyMemberModel member;

  const FamilyFollowButton({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (member.isRequested) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(familyControllerProvider.notifier).toggleMemberFollow(member.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x448E2DE2), blurRadius: 4),
            ],
          ),
          child: const Text(
            'Requested',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    } else if (member.isFollowing) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(familyControllerProvider.notifier).toggleMemberFollow(member.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 0.9),
          ),
          child: const Text(
            'Following',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(familyControllerProvider.notifier).toggleMemberFollow(member.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00E676), Color(0xFF00C853)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x4400E676), blurRadius: 5),
            ],
          ),
          child: const Text(
            'Follow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }
  }
}

