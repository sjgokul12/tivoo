import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_assets.dart';
import '../theme/luxe_theme.dart';

/// Unified Share Bottom Sheet for Tivoo.
/// Used across Live Stream, PK Battle, Chat Room, Explore Reels, and Profile.
/// Features direct integration with real apps:
/// - WhatsApp (Asset: assets/WhatsApp.png)
/// - Instagram (Asset: assets/Instagram_icon.png)
/// - Telegram (Asset: assets/telegram.jpeg)
/// - X / Twitter (Asset: assets/X Logo.png)
/// - Copy Link
class TivooShareSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String shareUrl;
  final String shareText;

  const TivooShareSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.shareUrl,
    required this.shareText,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Share',
    String? subtitle,
    required String shareUrl,
    required String shareText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TivooShareSheet(
        title: title,
        subtitle: subtitle,
        shareUrl: shareUrl,
        shareText: shareText,
      ),
    );
  }

  Future<void> _launchSocial(BuildContext context, String appName) async {
    Navigator.of(context).pop();

    switch (appName) {
      case 'WhatsApp':
        final waAppUri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(shareText)}');
        final waWebUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(shareText)}');
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
        final tgAppUri = Uri.parse('tg://msg_url?url=${Uri.encodeComponent(shareUrl)}&text=${Uri.encodeComponent(shareText)}');
        final tgWebUri = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(shareUrl)}&text=${Uri.encodeComponent(shareText)}');
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
        await Clipboard.setData(ClipboardData(text: shareText));
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
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;

      case 'X':
        final xAppUri = Uri.parse('twitter://post?message=${Uri.encodeComponent(shareText)}');
        final xDirectUri = Uri.parse('x://post?message=${Uri.encodeComponent(shareText)}');
        final xWebUri = Uri.parse('https://x.com/intent/tweet?text=${Uri.encodeComponent(shareText)}');
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
        await Clipboard.setData(ClipboardData(text: shareUrl));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📋 Link copied to clipboard!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF100C2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: Color(0x55FFC928), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
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
            const SizedBox(height: 14),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LuxeColors.goldGradient,
                  ),
                  child: const Icon(Icons.share_rounded, color: Color(0xFF1F1500), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
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
            const SizedBox(height: 22),

            // 5 Share Options Row
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
              ],
            ),

            const SizedBox(height: 20),

            // Link URL Box with Copy Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF17123A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, color: Color(0xFFFFD700), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shareUrl,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _launchSocial(context, 'Copy Link'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: LuxeDecor.goldButton(radius: 12),
                      child: const Text(
                        'Copy',
                        style: TextStyle(
                          color: Color(0xFF221600),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
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
                width: 52,
                height: 52,
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
              fontSize: 11.5,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
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
              child: Icon(Icons.link_rounded, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Copy Link',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
