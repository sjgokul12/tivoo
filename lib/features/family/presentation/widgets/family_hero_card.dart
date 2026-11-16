import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/models/family_team_model.dart';

/// Top Hero Banner card for the Family:
/// - Lion crest shield
/// - Name, Region | Language, Slogan
/// - Total Family Stars and Rank #1 badge
class FamilyHeroCard extends StatelessWidget {
  final FamilyTeamModel family;
  final int totalStars;

  const FamilyHeroCard({
    super.key,
    required this.family,
    required this.totalStars,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B064D),
            Color(0xFF5E0B49),
            Color(0xFF280A3C),
            Color(0xFF140824),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF2DC0).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55FF2DC0),
            blurRadius: 20,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black87,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Shield with Lion Crest
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFEA79),
                      Color(0xFFFF9100),
                      Color(0xFFC43E00),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88FFD700),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.giftGoldenLion,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('🦁', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Family Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      family.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${family.region}  |  ${family.language}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      family.slogan,
                      style: const TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Crown badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  ),
                ),
                child: const Text('👑', style: TextStyle(fontSize: 22)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Total Stars Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF28113E), Color(0xFF190B28)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x33FFD700), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFEA79), Color(0xFFFF8F00)],
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0x66FFD700), blurRadius: 8),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.star_rounded,
                      color: Color(0xFF3B1E00),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TOTAL FAMILY STARS',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${formatter.format(totalStars)} ⭐',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF2DC0), Color(0xFF7B1FA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'RANK #1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

