import 'package:flutter/material.dart';
import '../../../../core/widgets/glow_icon_button.dart';

/// Tiki Video Moderation & Content Detection System Screen
/// Strictly matches User Reference Image 1:
/// - Safe Community | AI Powered | Human Verified | Better Experience
/// - 5-Step Process Pipeline
/// - Violation / Bad Content (தடை செய்யப்பட்ட உள்ளடக்கம்)
/// - Good / Quality Content (நல்ல / பாதுகாப்பான உள்ளடக்கம்)
/// - AI Detection Engine & Methods
/// - Action Flow (Pass, Needs Review, Violates Policy)
class AiContentModerationScreen extends StatefulWidget {
  const AiContentModerationScreen({super.key});

  @override
  State<AiContentModerationScreen> createState() => _AiContentModerationScreenState();
}

class _AiContentModerationScreenState extends State<AiContentModerationScreen> {
  bool _aiProtectionActive = true;
  bool _blockSexualContent = true;
  bool _blockNudity = true;
  bool _blockAdultSuggestive = true;
  bool _blockHateViolence = true;
  bool _blockDrugsIllegal = true;
  bool _blockSelfHarm = true;
  bool _blockDangerousActs = true;
  bool _blockFakeSpam = true;

  double _sensitivityLevel = 0.85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090812),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GlowIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          size: 38,
          backgroundColor: const Color(0xFF161524),
          iconColor: Colors.white,
          onTap: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Content Detection System',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Header Banner matching Image 1 Top
            _buildHeroHeader(),

            const SizedBox(height: 18),

            // 2. 5-Step Process Pipeline matching Image 1 Steps 1 to 5
            _buildProcessPipeline(),

            const SizedBox(height: 20),

            // 3. AI Master Protection Toggle & Sensitivity
            _buildMasterToggleCard(),

            const SizedBox(height: 20),

            // 4. Violation / Bad Content (தடை செய்யப்பட்ட உள்ளடக்கம்)
            _buildBadContentSection(),

            const SizedBox(height: 20),

            // 5. Good / Quality Content (நல்ல / பாதுகாப்பான உள்ளடக்கம்)
            _buildGoodContentSection(),

            const SizedBox(height: 20),

            // 6. Detection Methods (எப்படி கண்டறிகிறது?)
            _buildDetectionMethodsSection(),

            const SizedBox(height: 20),

            // 7. Action Flow (செயல்முறை)
            _buildActionFlowSection(),

            const SizedBox(height: 20),

            // 8. Trust & Safe Community Footer Badge
            _buildTrustBadgeFooter(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Top Hero Header Banner
  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1436), Color(0xFF0F0B20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x66BA43F6), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x33BA43F6), blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFBA43F6), Color(0xFF673AB7)],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66BA43F6), blurRadius: 12),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Video Moderation System',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Safe Community • AI Powered • 24/7 Monitored',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: const Text(
              'Unwanted, sensitive and abusive videos are automatically scanned and prevented by real-time neural vision and voice analyzers.',
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  /// 5-Step Process Pipeline matching Image 1
  Widget _buildProcessPipeline() {
    final steps = [
      {'num': '1', 'title': 'Upload', 'desc': 'Video & Title', 'icon': Icons.cloud_upload_rounded, 'color': Color(0xFF00E5FF)},
      {'num': '2', 'title': 'AI Scan', 'desc': 'Rules & Risks', 'icon': Icons.memory_rounded, 'color': Color(0xFFBA43F6)},
      {'num': '3', 'title': 'Analysis', 'desc': 'Vision & Audio', 'icon': Icons.graphic_eq_rounded, 'color': Color(0xFFFFD600)},
      {'num': '4', 'title': 'Decision', 'desc': 'Allow / Block', 'icon': Icons.verified_user_rounded, 'color': Color(0xFF00E676)},
      {'num': '5', 'title': '24/7 Watch', 'desc': 'Keep Safe', 'icon': Icons.all_inclusive_rounded, 'color': Color(0xFFFF4081)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5-Step AI Moderation Pipeline',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (_, _) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 13),
            ),
            itemBuilder: (c, idx) {
              final s = steps[idx];
              final color = s['color'] as Color;
              return Container(
                width: 105,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141322),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: color.withValues(alpha: 0.20),
                      child: Icon(s['icon'] as IconData, color: color, size: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s['title'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      s['desc'] as String,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 9.5),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Master AI Toggle Card
  Widget _buildMasterToggleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x4400E5FF), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield_rounded, color: Color(0xFF00E5FF), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Active AI Protection',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Switch(
                value: _aiProtectionActive,
                activeThumbColor: const Color(0xFF00E5FF),
                activeTrackColor: const Color(0x4400E5FF),
                onChanged: (val) {
                  setState(() => _aiProtectionActive = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val ? '🛡️ Real-time AI Protection Activated' : '⚠️ AI Protection Paused'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Filter Sensitivity', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF00E5FF),
                    thumbColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    trackHeight: 2.5,
                  ),
                  child: Slider(
                    value: _sensitivityLevel,
                    min: 0.5,
                    max: 1.0,
                    onChanged: _aiProtectionActive
                        ? (v) => setState(() => _sensitivityLevel = v)
                        : null,
                  ),
                ),
              ),
              Text(
                '${(_sensitivityLevel * 100).toInt()}%',
                style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Violation / Bad Content (தடை செய்யப்பட்ட உள்ளடக்கம்) matching Image 1 Red Box
  Widget _buildBadContentSection() {
    final violations = [
      {'title': 'Sexual Content', 'sub': 'ஒழுங்கற்ற உள்ளடக்கம்', 'val': _blockSexualContent, 'set': (b) => setState(() => _blockSexualContent = b)},
      {'title': 'Nudity', 'sub': 'நிர்வாணம்', 'val': _blockNudity, 'set': (b) => setState(() => _blockNudity = b)},
      {'title': 'Adult / Suggestive', 'sub': 'வயது வந்தோருக்கான', 'val': _blockAdultSuggestive, 'set': (b) => setState(() => _blockAdultSuggestive = b)},
      {'title': 'Hate / Violence', 'sub': 'வெறுப்பு / வன்முறை', 'val': _blockHateViolence, 'set': (b) => setState(() => _blockHateViolence = b)},
      {'title': 'Drugs / Illegal', 'sub': 'போதை / சட்டவிரோதம்', 'val': _blockDrugsIllegal, 'set': (b) => setState(() => _blockDrugsIllegal = b)},
      {'title': 'Self Harm', 'sub': 'தற்கொலை உள்ளடக்கம்', 'val': _blockSelfHarm, 'set': (b) => setState(() => _blockSelfHarm = b)},
      {'title': 'Dangerous Acts', 'sub': 'ஆபத்தான செயல்', 'val': _blockDangerousActs, 'set': (b) => setState(() => _blockDangerousActs = b)},
      {'title': 'Fake / Spam', 'sub': 'போலி / ஸ்பேம்', 'val': _blockFakeSpam, 'set': (b) => setState(() => _blockFakeSpam = b)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF180E14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x66FF3B30), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x22FF3B30), blurRadius: 18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cancel_rounded, color: Color(0xFFFF3B30), size: 22),
              SizedBox(width: 8),
              Text(
                'Violation / Bad Content',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Spacer(),
              Text(
                'தடை செய்யப்பட்டவை',
                style: TextStyle(color: Color(0xFFFF8A80), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'These video types are strictly blocked & deleted automatically by AI.',
            style: TextStyle(color: Colors.white60, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: violations.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (c, i) {
              final v = violations[i];
              final isChecked = v['val'] as bool;
              final setter = v['set'] as Function(bool);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isChecked ? const Color(0x33FF3B30) : const Color(0xFF1F1218),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isChecked ? const Color(0xFFFF3B30) : Colors.white12,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v['title'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            v['sub'] as String,
                            style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 9),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.75,
                      child: Checkbox(
                        value: isChecked,
                        activeColor: const Color(0xFFFF3B30),
                        checkColor: Colors.white,
                        onChanged: (val) => setter(val ?? false),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Good / Quality Content (நல்ல / பாதுகாப்பான உள்ளடக்கம்) matching Image 1 Green Box
  Widget _buildGoodContentSection() {
    final good = [
      {'title': 'Entertainment', 'tamil': 'பொழுதுபோக்கு', 'icon': '🎭'},
      {'title': 'Education', 'tamil': 'கல்வி', 'icon': '📚'},
      {'title': 'Talent / Creativity', 'tamil': 'திறமை', 'icon': '🎸'},
      {'title': 'Travel / Nature', 'tamil': 'பயணம்', 'icon': '🏔️'},
      {'title': 'Food / Cooking', 'tamil': 'உணவு', 'icon': '🍳'},
      {'title': 'Lifestyle', 'tamil': 'வாழ்க்கை முறை', 'icon': '✨'},
      {'title': 'Pets / Animals', 'tamil': 'விலங்குகள்', 'icon': '🐶'},
      {'title': 'Motivation', 'tamil': 'உந்துதல்', 'icon': '🔥'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1812),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x6600E676), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x2200E676), blurRadius: 18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 22),
              SizedBox(width: 8),
              Text(
                'Good / Quality Content',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Spacer(),
              Text(
                'பாதுகாப்பானவை',
                style: TextStyle(color: Color(0xFFB9F6CA), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'These videos are verified as safe and published directly without delay.',
            style: TextStyle(color: Colors.white60, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: good.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (c, i) {
              final g = good[i];
              return Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10261D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x3300E676)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(g['icon']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      g['title']!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      g['tamil']!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF69F0AE), fontSize: 8),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Detection Methods matching Image 1
  Widget _buildDetectionMethodsSection() {
    final methods = [
      {'title': 'Computer Vision AI', 'desc': 'Nudity & weapon scanning', 'icon': Icons.visibility_rounded},
      {'title': 'Audio & Voice Check', 'desc': 'Abusive words & hate speech', 'icon': Icons.mic_rounded},
      {'title': 'Text & OCR Filter', 'desc': 'Banned keywords & spam links', 'icon': Icons.text_fields_rounded},
      {'title': 'User Behavior Radar', 'desc': 'Repeated violator detection', 'icon': Icons.insights_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121422),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detection Methods (எப்படி கண்டறிகிறது?)',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...methods.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x33BA43F6),
                    ),
                    child: Icon(m['icon'] as IconData, color: const Color(0xFFBA43F6), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(m['desc'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 16),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Action Flow matching Image 1 Bottom
  Widget _buildActionFlowSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141320),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Action Flow (செயல்முறை)',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFlowPill('Pass (No Issues)', 'Published Instantly', const Color(0xFF00E676)),
              const SizedBox(width: 8),
              _buildFlowPill('Needs Review', 'Temporary Hidden', const Color(0xFFFFD600)),
              const SizedBox(width: 8),
              _buildFlowPill('Violates Policy', 'Immediately Blocked', const Color(0xFFFF3B30)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowPill(String title, String action, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.40)),
        ),
        child: Column(
          children: [
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(action, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 8.5)),
          ],
        ),
      ),
    );
  }

  /// Safe Community Trust Badge Footer
  Widget _buildTrustBadgeFooter() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x331E88E5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x661E88E5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified_user_rounded, color: Color(0xFF64B5F6), size: 18),
            SizedBox(width: 8),
            Text(
              'Safe Platform  •  Happy Creators  •  Stronger Community',
              style: TextStyle(color: Color(0xFF90CAF9), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
