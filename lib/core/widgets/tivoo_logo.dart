import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// Glossy 3D "Tivoo" wordmark (brand artwork) with the two tagline rows.
/// Everything scales from [fontSize] (the wordmark's letter height).
class TivooLogo extends StatelessWidget {
  const TivooLogo({super.key, this.fontSize = 64, this.showTagline = true});

  final double fontSize;
  final bool showTagline;

  /// Artwork aspect ratio (width / height) and its width relative to [fontSize].
  static const _aspect = 600 / 307;
  static const _widthFactor = 3.6;

  @override
  Widget build(BuildContext context) {
    final width = fontSize * _widthFactor;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final wordmark = Image.asset(
      AppAssets.tivooLogo,
      width: width,
      height: width / _aspect,
      cacheWidth: (width * dpr).round(),
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Tivoo',
    );

    if (!showTagline) return wordmark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        wordmark,
        SizedBox(height: fontSize * 0.04),
        _TaglineRow(
          words: const ['Live', 'Connect', 'Share'],
          color: Colors.white,
          fontSize: fontSize * 0.2,
        ),
        SizedBox(height: fontSize * 0.07),
        _TaglineRow(
          words: const ['Your World', 'Your Live', 'Your Tivoo'],
          color: AppColors.link,
          fontSize: fontSize * 0.165,
        ),
      ],
    );
  }
}

class _TaglineRow extends StatelessWidget {
  const _TaglineRow({required this.words, required this.color, required this.fontSize});

  final List<String> words;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w500);
    final dot = Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.9),
      child: Container(
        width: fontSize * 0.25,
        height: fontSize * 0.25,
        decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < words.length; i++) ...[
          if (i > 0) dot,
          Text(words[i], style: style),
        ],
      ],
    );
  }
}
