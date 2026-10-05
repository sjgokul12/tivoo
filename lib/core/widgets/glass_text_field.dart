import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Frosted input used by login, search and chat.
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    required this.hint,
    this.controller,
    this.focusNode,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.borderRadius = 20,
    this.verticalPadding = 20,
    this.fontSize = 15,
    this.autofocus = false,
    this.maxLength,
  });

  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final double borderRadius;
  final double verticalPadding;
  final double fontSize;
  final bool autofocus;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      autofocus: autofocus,
      maxLength: maxLength,
      enableSuggestions: !obscureText,
      autocorrect: false,
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: fontSize),
        filled: true,
        isDense: true,
        fillColor: const Color(0xFF1B2466).withValues(alpha: 0.32),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: verticalPadding),
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
                child: Icon(prefixIcon, size: fontSize + 7, color: Colors.white.withValues(alpha: 0.85)),
              ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(),
        errorStyle: const TextStyle(color: Color(0xFFFF7AA8), fontSize: 11),
        enabledBorder: border(const Color(0x668DA2FF)),
        focusedBorder: border(AppColors.pink, 1.4),
        errorBorder: border(AppColors.live),
        focusedErrorBorder: border(AppColors.live, 1.4),
      ),
    );
  }
}
