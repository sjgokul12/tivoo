import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared empty / error / coming-soon view.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassFill,
              border: Border.all(color: AppColors.purple.withValues(alpha: 0.6)),
              boxShadow: const [
                BoxShadow(color: Color(0x668B5CF6), blurRadius: 24, blurStyle: BlurStyle.outer),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppColors.pink),
                shape: const StadiumBorder(),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
