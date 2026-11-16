import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_assets.dart';
import '../theme/luxe_theme.dart';

/// Unified Instagram-style Share Bottom Sheet for Tivoo.
/// Used across Live Stream, PK Battle, Chat Room, Explore Reels, and Profile.
///
/// Features:
/// 1. Followers section FIRST with direct message "Send" / "Sent" toggle (Instagram DM style).
/// 2. Search bar to quickly filter followers.
/// 3. Share to external apps (WhatsApp, Instagram, Telegram, X, Copy Link, SMS).
/// 4. Direct link box with instant Copy button.
class TivooShareSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String shareUrl;
  final String shareText;
  final bool canDownload;
  final bool allowDownload;
  final String? videoAuthor;

  const TivooShareSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.shareUrl,
    required this.shareText,
    this.canDownload = false,
    this.allowDownload = true,
    this.videoAuthor,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Share to',
    String? subtitle,
    required String shareUrl,
    required String shareText,
    bool canDownload = false,
    bool allowDownload = true,
    String? videoAuthor,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TivooShareSheet(
        title: title,
        subtitle: subtitle,
        shareUrl: shareUrl,
        shareText: shareText,
        canDownload: canDownload,
        allowDownload: allowDownload,
        videoAuthor: videoAuthor,
      ),
    );
  }

  @override
  State<TivooShareSheet> createState() => _TivooShareSheetState();
}

class _ShareFollower {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final bool isOnline;

  const _ShareFollower({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    this.isOnline = true,
  });
}

class _TivooShareSheetState extends State<TivooShareSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _sentFollowerIds = {};
  String _searchQuery = '';
  bool _showAllFollowers = false;

  static const List<_ShareFollower> _allFollowers = [
    _ShareFollower(id: 'f1', name: 'Diya Sharma', username: '@diya_official', avatar: AppAssets.avatarDiya, isOnline: true),
    _ShareFollower(id: 'f2', name: 'Priya Singh', username: '@priya_star', avatar: AppAssets.avatarPriya, isOnline: true),
    _ShareFollower(id: 'f3', name: 'Neha Verma', username: '@neha_live', avatar: AppAssets.avatarNeha, isOnline: true),
    _ShareFollower(id: 'f4', name: 'Arun Kumar', username: '@arun_k', avatar: AppAssets.avatarArun, isOnline: false),
    _ShareFollower(id: 'f5', name: 'Vicky', username: '@vicky_vibes', avatar: AppAssets.avatarVicky, isOnline: true),
    _ShareFollower(id: 'f6', name: 'Sneha', username: '@sneha_dance', avatar: AppAssets.avatarSneha, isOnline: true),
    _ShareFollower(id: 'f7', name: 'Karthik', username: '@karthik_pro', avatar: AppAssets.avatarKarthik, isOnline: false),
    _ShareFollower(id: 'f8', name: 'Saran', username: '@saran_dev', avatar: AppAssets.avatarSaran, isOnline: true),
    _ShareFollower(id: 'f9', name: 'Meena', username: '@meena_music', avatar: AppAssets.avatarMeena, isOnline: true),
    _ShareFollower(id: 'f10', name: 'Pooja', username: '@pooja_live', avatar: AppAssets.status1, isOnline: true),
    _ShareFollower(id: 'f11', name: 'Ananya', username: '@ananya_sing', avatar: AppAssets.status2, isOnline: true),
    _ShareFollower(id: 'f12', name: 'Lucas', username: '@lucas_vibes', avatar: AppAssets.status3, isOnline: false),
    _ShareFollower(id: 'f13', name: 'Aurora', username: '@aurora_star', avatar: AppAssets.status4, isOnline: true),
    _ShareFollower(id: 'f14', name: 'Sam', username: '@sam_99', avatar: AppAssets.status5, isOnline: false),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ShareFollower> get _filteredFollowers {
    if (_searchQuery.isEmpty) return _allFollowers;
    return _allFollowers.where((f) {
      return f.name.toLowerCase().contains(_searchQuery) ||
          f.username.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _sendToFollower(_ShareFollower follower) {
    HapticFeedback.mediumImpact();
    setState(() {
      _sentFollowerIds.add(follower.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
            const SizedBox(width: 8),
            Text('Sent to ${follower.name}\'s messages ✉️'),
          ],
        ),
        backgroundColor: const Color(0xFF1B1638),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchSocial(BuildContext context, String appName) async {
    Navigator.of(context).pop();

    switch (appName) {
      case 'WhatsApp':
        final waAppUri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(widget.shareText)}');
        final waWebUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(widget.shareText)}');
        try {
          if (await canLaunchUrl(waAppUri)) {
            await launchUrl(waAppUri, mode: LaunchMode.externalApplication);
          } else {
            await launchUrl(waWebUri, mode: LaunchMode.externalApplication);
          }
        } catch (_) {
          await launchUrl(waWebUri, mode: LaunchMode.externalApplication);
        }
        break;

      case 'Telegram':
        final tgAppUri = Uri.parse('tg://msg_url?url=${Uri.encodeComponent(widget.shareUrl)}&text=${Uri.encodeComponent(widget.shareText)}');
        final tgWebUri = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(widget.shareUrl)}&text=${Uri.encodeComponent(widget.shareText)}');
        try {
          if (await canLaunchUrl(tgAppUri)) {
            await launchUrl(tgAppUri, mode: LaunchMode.externalApplication);
          } else {
            await launchUrl(tgWebUri, mode: LaunchMode.externalApplication);
          }
        } catch (_) {
          await launchUrl(tgWebUri, mode: LaunchMode.externalApplication);
        }
        break;

      case 'Instagram':
        await Clipboard.setData(ClipboardData(text: widget.shareText));
        final igAppUri = Uri.parse('instagram://');
        final igWebUri = Uri.parse('https://instagram.com');
        try {
          if (await canLaunchUrl(igAppUri)) {
            await launchUrl(igAppUri, mode: LaunchMode.externalApplication);
          } else {
            await launchUrl(igWebUri, mode: LaunchMode.externalApplication);
          }
        } catch (_) {
          await launchUrl(igWebUri, mode: LaunchMode.externalApplication);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📋 Link copied! Opening Instagram... 📸'),
              backgroundColor: Color(0xFF1B1638),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;

      case 'X':
        final xAppUri = Uri.parse('twitter://post?message=${Uri.encodeComponent(widget.shareText)}');
        final xDirectUri = Uri.parse('x://post?message=${Uri.encodeComponent(widget.shareText)}');
        final xWebUri = Uri.parse('https://x.com/intent/tweet?text=${Uri.encodeComponent(widget.shareText)}');
        try {
          if (await canLaunchUrl(xAppUri)) {
            await launchUrl(xAppUri, mode: LaunchMode.externalApplication);
          } else if (await canLaunchUrl(xDirectUri)) {
            await launchUrl(xDirectUri, mode: LaunchMode.externalApplication);
          } else {
            await launchUrl(xWebUri, mode: LaunchMode.externalApplication);
          }
        } catch (_) {
          await launchUrl(xWebUri, mode: LaunchMode.externalApplication);
        }
        break;

      case 'Copy Link':
      default:
        await Clipboard.setData(ClipboardData(text: widget.shareUrl));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📋 Link copied to clipboard!'),
              backgroundColor: Color(0xFF1B1638),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    final viewInsetBottom = mq.viewInsets.bottom;
    final followers = _filteredFollowers;
    final maxHeight = (mq.size.height * 0.84).clamp(420.0, 680.0);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + (viewInsetBottom > 0 ? viewInsetBottom : bottomInset)),
      decoration: const BoxDecoration(
        color: Color(0xFF120E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x66FFC928), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top pill handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row: Title + Close Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LuxeColors.goldGradient,
                    ),
                    child: const Icon(Icons.send_rounded, color: Color(0xFF1F1500), size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            widget.subtitle!,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Search Bar (Instagram style)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1642),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Colors.white54, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: const Color(0xFFFFD700),
                        decoration: const InputDecoration(
                          hintText: 'Search followers...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: const Icon(Icons.cancel_rounded, color: Colors.white38, size: 16),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 1 (FIRST): Followers Direct Message List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showAllFollowers ? 'All Followers (${followers.length})' : 'Send to Followers',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showAllFollowers = !_showAllFollowers);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllFollowers ? 'Show less' : 'view all followers',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          _showAllFollowers ? Icons.keyboard_arrow_up_rounded : Icons.arrow_forward_ios_rounded,
                          color: const Color(0xFFFFD700),
                          size: _showAllFollowers ? 15 : 10.5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Followers List (Horizontal Cards or Full Vertical List when 'view all followers' is selected)
              if (followers.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'No followers found',
                    style: TextStyle(color: Colors.white38, fontSize: 12.5),
                  ),
                )
              else if (_showAllFollowers)
                Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161138),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    itemCount: followers.length,
                    separatorBuilder: (_, _) => Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                    itemBuilder: (context, index) {
                      final follower = followers[index];
                      final isSent = _sentFollowerIds.contains(follower.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: Row(
                          children: [
                            // Avatar with online status
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(1.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isSent
                                        ? const LinearGradient(colors: [Colors.white24, Colors.white12])
                                        : const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFFFFD700)]),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      follower.avatar,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 40,
                                        height: 40,
                                        color: const Color(0xFF2E2460),
                                        child: Center(
                                          child: Text(
                                            follower.name.substring(0, 1),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (follower.isOnline)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E676),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF161138), width: 1.8),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Follower details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    follower.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    follower.username,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 11.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Send / Sent Button
                            GestureDetector(
                              onTap: isSent ? null : () => _sendToFollower(follower),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: isSent
                                      ? null
                                      : const LinearGradient(colors: [Color(0xFF2979FF), Color(0xFF00E5FF)]),
                                  color: isSent ? Colors.white.withValues(alpha: 0.12) : null,
                                  border: isSent ? Border.all(color: Colors.white24, width: 0.8) : null,
                                ),
                                child: Center(
                                  child: isSent
                                      ? const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 14),
                                            SizedBox(width: 3),
                                            Text(
                                              'Sent',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Send',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                SizedBox(
                  height: 124,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: followers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final follower = followers[index];
                      final isSent = _sentFollowerIds.contains(follower.id);

                      return SizedBox(
                        width: 76,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Avatar with online status
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isSent
                                        ? const LinearGradient(colors: [Colors.white24, Colors.white12])
                                        : const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFFFFD700)]),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      follower.avatar,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 50,
                                        height: 50,
                                        color: const Color(0xFF2E2460),
                                        child: Center(
                                          child: Text(
                                            follower.name.substring(0, 1),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (follower.isOnline)
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E676),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF120E2E), width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Follower Name
                            Text(
                              follower.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            // Send / Sent Button (Instagram style)
                            GestureDetector(
                              onTap: isSent ? null : () => _sendToFollower(follower),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 26,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  gradient: isSent
                                      ? null
                                      : const LinearGradient(
                                          colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                                        ),
                                  color: isSent ? Colors.white.withValues(alpha: 0.12) : null,
                                  border: isSent
                                      ? Border.all(color: Colors.white24, width: 0.8)
                                      : null,
                                ),
                                child: Center(
                                  child: isSent
                                      ? const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 12),
                                            SizedBox(width: 2),
                                            Text(
                                              'Sent',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Send',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 16),

              // SECTION 2: External Apps (Instagram, WhatsApp, Telegram, X, Copy Link)
              const Text(
                'Share to other apps',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOption(
                    context: context,
                    name: 'WhatsApp',
                    assetPath: AppAssets.iconWhatsapp,
                  ),
                  _buildOption(
                    context: context,
                    name: 'Instagram',
                    assetPath: AppAssets.iconInstagram,
                  ),
                  _buildOption(
                    context: context,
                    name: 'Telegram',
                    assetPath: AppAssets.iconTelegram,
                  ),
                  _buildOption(
                    context: context,
                    name: 'X',
                    assetPath: AppAssets.iconX,
                  ),
                  _buildCopyLinkOption(context),
                  if (widget.canDownload) _buildDownloadOption(context),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDownload(BuildContext context) {
    Navigator.of(context).pop();
    if (!widget.allowDownload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock_rounded, color: Color(0xFFFF5252), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('Downloads disabled: Creator has turned off downloads for this video 🔒'),
              ),
            ],
          ),
          backgroundColor: Color(0xFF2E1A29),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text('Downloading video with TiVOO watermark... 🎬'),
            ),
          ],
        ),
        backgroundColor: Color(0xFF1B1638),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1400),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Saved to Gallery with TiVOO watermark! ✨ (@${widget.videoAuthor ?? "tivoo_creator"})'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10281E),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Widget _buildDownloadOption(BuildContext context) {
    final enabled = widget.allowDownload;
    return GestureDetector(
      onTap: () => _handleDownload(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF4A4458), Color(0xFF2C2836)],
                    ),
              border: Border.all(
                color: (enabled ? const Color(0xFFFFD700) : Colors.white24).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                enabled ? Icons.download_rounded : Icons.file_download_off_rounded,
                color: enabled ? const Color(0xFF1F1500) : Colors.white38,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            enabled ? 'Download' : 'Locked',
            style: TextStyle(
              color: enabled ? Colors.white70 : Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String name,
    required String assetPath,
  }) {
    return GestureDetector(
      onTap: () => _launchSocial(context, name),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    name.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyLinkOption(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchSocial(context, 'Copy Link'),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.link_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Copy Link',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
