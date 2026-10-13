import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glow_icon_button.dart';

class LegalPolicyScreen extends StatefulWidget {
  final int initialTabIndex;
  const LegalPolicyScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LegalPolicyScreen> createState() => _LegalPolicyScreenState();
}

class _LegalPolicyScreenState extends State<LegalPolicyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Legal & Policies',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Privacy Policy'),
            Tab(text: 'Terms of Use'),
            Tab(text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPrivacyPolicyTab(),
          _buildTermsOfUseTab(),
          _buildCommunityGuidelinesTab(),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryYellow,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          title: '1. Information We Collect',
          content:
              'Tivoo collects information you provide directly, such as your profile username, display name, email, phone number, and content uploaded during live broadcasts and stories. We also collect device diagnostic info, approximate location, and viewing metrics to enhance recommendation algorithms.',
        ),
        _buildSection(
          title: '2. Live Video & Audio Streaming',
          content:
              'When broadcasting live, your video stream and audio are transmitted in real time to connected viewers. Live chat messages and virtual gift logs are stored for moderation, safety compliance, and creator transaction auditing.',
        ),
        _buildSection(
          title: '3. Data Security & Encryption',
          content:
              'All user credentials, authentication tokens, and financial transactions for virtual coins/gifts are encrypted using industry-standard AES-256 and SSL/TLS encryption protocols.',
        ),
        _buildSection(
          title: '4. Your Privacy Rights & Controls',
          content:
              'You have full control over your privacy. You can switch your account to Private, delete search history, block disruptive accounts, or download a complete copy of your personal data by contacting our Data Protection Office.',
        ),
      ],
    );
  }

  Widget _buildTermsOfUseTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          title: '1. Acceptance of Terms',
          content:
              'By creating an account or accessing the Tivoo mobile platform, you agree to be legally bound by these Terms of Service. If you are under the legal age of majority in your jurisdiction, you must have guardian consent.',
        ),
        _buildSection(
          title: '2. Creator Content & Licensing',
          content:
              'You retain ownership of the original intellectual property and media you create. By uploading or streaming on Tivoo, you grant the platform a worldwide, non-exclusive license to host, display, and distribute your content across our services.',
        ),
        _buildSection(
          title: '3. Virtual Coins & Digital Gifts',
          content:
              'Virtual coins purchased are non-refundable digital goods with no cash equivalent outside of authorized creator payout programs. Fraudulent chargebacks or coin abuse will result in immediate account termination.',
        ),
        _buildSection(
          title: '4. Account Termination & Bans',
          content:
              'Tivoo reserves the right to suspend or permanently ban accounts that violate copyright laws, engage in harassment, or breach community safety standards.',
        ),
      ],
    );
  }

  Widget _buildCommunityGuidelinesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          title: '1. Respect & Safe Environment',
          content:
              'Treat all creators, streamers, and viewers with dignity. Hate speech, racial slurs, cyberbullying, harassment, and threats of violence are strictly prohibited and result in permanent bans.',
        ),
        _buildSection(
          title: '2. Live Stream Moderation',
          content:
              'Broadcasters are responsible for maintaining a safe chat environment. Use automated comment filters, assign trusted moderators, and immediately report abusive viewers.',
        ),
        _buildSection(
          title: '3. Copyright & Intellectual Property',
          content:
              'Only stream content, music, and gameplay that you own or have explicit broadcast rights for. Commercial piracy or rebroadcasting pay-per-view events is strictly forbidden.',
        ),
        _buildSection(
          title: '4. Reporting Violations',
          content:
              'If you observe content or behavior violating our guidelines, tap the 3-dot menu on any live stream or profile to file an immediate priority report to our 24/7 Safety Team.',
        ),
      ],
    );
  }
}
