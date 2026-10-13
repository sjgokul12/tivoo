import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../family/presentation/controllers/family_controller.dart';

class TikiVerificationSheet extends ConsumerWidget {
  const TikiVerificationSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TikiVerificationSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyControllerProvider);
    final familyCtrl = ref.read(familyControllerProvider.notifier);
    final v = familyState.verification;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF14131E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Colors.white24, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            const SizedBox(height: 16),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF9100)]),
                  ),
                  child: const Icon(Icons.verified_rounded, color: Colors.black87, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiki Creator Verification',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Step-by-step roadmap to White Tiki & Gray Tiki',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 1. White Tiki Milestone (⚪)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: const Center(child: Text('⚪', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'White Tiki (Beginning Tier)',
                          style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Condition: Setup authentic profile, post good quality original videos.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 22),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. Gray Tiki Milestone (🔘) with 500 Views / 1 Month Target
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0x33424242), Color(0x221E1E2C)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: v.hasGrayTiki ? const Color(0xFF00E676) : const Color(0xFF9E9E9E), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade700),
                        child: const Center(child: Text('🔘', style: TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Gray Tiki (Target Tier)',
                                  style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                if (v.hasGrayTiki)
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 16),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Target: Post quality videos & reach 500 views in 1 month',
                              style: TextStyle(color: Color(0xFFFFD54F), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress Bar for 500 Views
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Views: ${v.currentViews} / ${v.targetViews}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${v.daysRemaining} days left in month',
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: v.progressRatio,
                      minHeight: 7,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Claim Gray Tiki Button
                  if (!v.hasGrayTiki)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        familyCtrl.claimGrayTiki();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Congratulations! You achieved 500 views and earned Gray Tiki! 🔘'),
                          ),
                        );
                      },
                      child: const Text(
                        'Achieved 500 Views! Claim Gray Tiki 🔘',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0x3300E676), borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Color(0xFF00E676), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Gray Tiki Active • Family Creation Unlocked 👑',
                            style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Family Team Creation Rule ("gray tiki vantha thu ku apporam tha family create pana mudiyu")
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1C2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Family Team Leader Privilege',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              v.canCreateFamily
                                  ? 'Gray Tiki unlocked! You can lead a Family and accept members.'
                                  : '🔒 Locked: Must achieve Gray Tiki (500 views in 1 month) to create a family.',
                              style: TextStyle(
                                color: v.canCreateFamily ? const Color(0xFF00E676) : Colors.white60,
                                fontSize: 11,
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

            const SizedBox(height: 18),

            // Close button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
