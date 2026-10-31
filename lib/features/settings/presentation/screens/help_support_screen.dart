import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../../core/widgets/gradient_button.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // Single active expanded question index.
  // null = all closed; 0..n = only that question is open.
  // When another question is clicked, this index changes, automatically closing the previous one!
  int? _expandedQuestionIndex;

  final TextEditingController _problemDescController = TextEditingController();
  String _selectedCategory = 'Live Stream Issue';

  final List<String> _categories = [
    'Live Stream Issue',
    'Account & Login',
    'Wallet & Coins',
    'Harassment or Abuse',
    'Bug Report',
  ];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I start a live stream broadcast?',
      'a':
          'Tap the glowing "+" button at the center of the bottom navigation bar and select "Go Live Now". Make sure camera and microphone permissions are granted on your device. For smooth, lag-free broadcasting, a stable connection of at least 5 Mbps upload speed is recommended.',
    },
    {
      'q': 'How do Coins, Virtual Gifts & Diamonds work?',
      'a':
          'Viewers purchase virtual coins in their wallet to send animated gifts to streamers during live sessions. Streamers receive diamonds that can be cashed out for real earnings once reaching 1,000 Diamonds.',
    },
    {
      'q': 'How do I withdraw my Creator Earnings?',
      'a':
          'Navigate to Profile > Wallet > Cash Out. Once you accumulate 1,000 Diamonds, you can withdraw directly to your verified bank account or PayPal.',
    },
    {
      'q': 'How do I get the Verified Creator Badge?',
      'a':
          'Creators with over 10,000 active followers and consistent original streams can apply for verification via our support desk.',
    },
  ];

  @override
  void dispose() {
    _problemDescController.dispose();
    super.dispose();
  }

  /// Toggles the question dropdown.
  /// If tapping the currently open question -> closes it.
  /// If tapping a different question -> opens it AND automatically closes the other!
  void _toggleQuestion(int index) {
    setState(() {
      if (_expandedQuestionIndex == index) {
        _expandedQuestionIndex = null;
      } else {
        _expandedQuestionIndex = index;
      }
    });
  }

  void _showReportProblemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Report a Problem',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.primaryYellow,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: AppColors.surfaceColor,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryYellow,
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.5,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'PROBLEM DESCRIPTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.primaryYellow,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _problemDescController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Describe what happened in detail...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceColor,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryYellow),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Submit Problem Report',
                onPressed: () {
                  if (_problemDescController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please describe the problem.'),
                        backgroundColor: Color(0xFFFF453A),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  _problemDescController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted! Our team will review within 24 hours.'),
                      backgroundColor: AppColors.primaryYellow,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLiveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.headset_mic_rounded, color: AppColors.primaryYellow),
            SizedBox(width: 10),
            Text(
              'Tivoo Support Bot',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Text(
                '👋 Hello! A support agent is online. How can we help you with your live session or account today?',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5, height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Average response time: ~2 minutes',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connected to Support Agent 💬')),
              );
            },
            child: const Text('Start Chat', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GlowIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          size: 38,
          backgroundColor: AppColors.cardBackground,
          iconColor: AppColors.textPrimary,
          onTap: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.primaryYellow,
                ),
              ),
            ),

            // One-by-One Question Dropdowns
            // Only ONE question can be open at a time ("one click means another one automatically closes")
            ...List.generate(_faqs.length, (index) {
              final faq = _faqs[index];
              final isExpanded = _expandedQuestionIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildQuestionDropdownCard(
                  index: index,
                  question: faq['q']!,
                  answer: faq['a']!,
                  isExpanded: isExpanded,
                ),
              );
            }),

            const SizedBox(height: 20),

            // Still Need Help Section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'CONTACT SUPPORT',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.primaryYellow,
                ),
              ),
            ),

            // Quick Support Actions (Live Chat & Report Problem)
            Row(
              children: [
                Expanded(
                  child: _buildContactChannel(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Live Chat',
                    subtitle: '24/7 Agent',
                    onTap: () => _showLiveChatDialog(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildContactChannel(
                    icon: Icons.report_problem_outlined,
                    title: 'Report Problem',
                    subtitle: 'File a ticket',
                    onTap: () => _showReportProblemSheet(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Email Support Direct Card
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support email copied: support@tivoo.live'),
                      backgroundColor: AppColors.primaryYellow,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.mail_outline_rounded,
                            color: AppColors.primaryYellow, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Support',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'support@tivoo.live',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.copy_rounded,
                          color: AppColors.textMuted, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Individual question dropdown card
  /// Tapping it opens its answer and automatically collapses whichever question was previously open.
  Widget _buildQuestionDropdownCard({
    required int index,
    required String question,
    required String answer,
    required bool isExpanded,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppColors.primaryYellow.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: isExpanded ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppColors.primaryYellow.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.25),
            blurRadius: isExpanded ? 14 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Question Tile (Always visible header row)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggleQuestion(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Question mark icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? AppColors.primaryYellow.withValues(alpha: 0.18)
                              : AppColors.primaryYellow.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.help_outline_rounded,
                          color: AppColors.primaryYellow,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Question Text
                      Expanded(
                        child: Text(
                          question,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isExpanded
                                ? AppColors.primaryYellow
                                : AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Animated chevron arrow (rotates 180° when open)
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isExpanded
                                ? AppColors.primaryYellow.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isExpanded
                                ? AppColors.primaryYellow
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated Dropdown Answer Body
            // Only visible when isExpanded is true
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: isExpanded
                  ? Column(
                      children: [
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            answer,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactChannel({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryYellow, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
