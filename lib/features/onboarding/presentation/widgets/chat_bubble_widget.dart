import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatBubbleWidget extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const ChatBubbleWidget({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bubbleBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.18),
            blurRadius: 20,
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTextStyles.chatBubble,
      ),
    );
  }
}
