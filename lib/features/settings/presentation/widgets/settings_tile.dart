import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool isDestructive;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.isDestructive = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isDestructive
        ? const Color(0xFFFF453A)
        : (iconColor ?? AppColors.primaryYellow);

    final effectiveIconBg = iconBackgroundColor ??
        (isDestructive
            ? const Color(0xFFFF453A).withValues(alpha: 0.12)
            : AppColors.primaryYellow.withValues(alpha: 0.1));

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Icon Box
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: effectiveIconBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: effectiveIconColor.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: effectiveIconColor,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDestructive
                                ? const Color(0xFFFF453A)
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing
                  if (trailing != null)
                    trailing!
                  else if (trailingText != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trailingText!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    )
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: 66,
            endIndent: 14,
            color: Colors.white.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;
  final bool showDivider;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      showDivider: showDivider,
      onTap: () => onChanged(!value),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.textOnPrimary,
        activeTrackColor: AppColors.primaryYellow,
        inactiveThumbColor: Colors.white70,
        inactiveTrackColor: Colors.white12,
      ),
    );
  }
}

class SettingsSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsSectionCard({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8, top: 16),
            child: Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.primaryYellow,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
