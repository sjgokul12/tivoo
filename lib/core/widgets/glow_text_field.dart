import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared glass text field with a neon glow on focus, used by form-style
/// bottom sheets (edit profile, upload post) so they match the rest of the
/// app's glass/glow system instead of flat Material `TextField`s.
class GlowTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType keyboardType;

  const GlowTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<GlowTextField> createState() => _GlowTextFieldState();
}

class _GlowTextFieldState extends State<GlowTextField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? AppColors.glowPink.withValues(alpha: 0.8) : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: _isFocused ? [BoxShadow(color: AppColors.glowPink.withValues(alpha: 0.25), blurRadius: 14)] : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0x66181824),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
