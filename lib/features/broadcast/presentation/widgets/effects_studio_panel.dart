import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../data/face_ar_engine.dart';
import '../../domain/models/face_effects.dart';

const _gold = Color(0xFFFFC928);
const _pink = Color(0xFFFF2D87);
const _muted = Color(0xFFA7A5BC);

enum _StudioTab { beauty, filters, effects }

/// Frosted bottom panel for the Go Live camera: Beauty sliders, colour Filters and AR Effects.
/// With [onGoLive] it shows the Go Live button (pre-live); without, it's the in-live sheet.
class EffectsStudioPanel extends StatefulWidget {
  final FaceArEngine engine;
  final VoidCallback? onGoLive;

  const EffectsStudioPanel({super.key, required this.engine, this.onGoLive});

  /// The panel as a bottom sheet (used while live).
  static Future<void> showSheet(BuildContext context, FaceArEngine engine) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EffectsStudioPanel(engine: engine),
    );
  }

  @override
  State<EffectsStudioPanel> createState() => _EffectsStudioPanelState();
}

class _EffectsStudioPanelState extends State<EffectsStudioPanel> {
  _StudioTab _tab = _StudioTab.beauty;
  BeautyFeature _feature = BeautyFeature.smooth;

  FaceArEngine get _engine => widget.engine;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, (bottom > 0 ? bottom : 12) + 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0D0B1A).withValues(alpha: 0.62),
                    const Color(0xFF07060F).withValues(alpha: 0.9),
                  ],
                ),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
              ),
              child: ListenableBuilder(
                listenable: _engine,
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                    SizedBox(height: compact ? 10 : 14),
                    _Tabs(selected: _tab, onSelect: (t) => setState(() => _tab = t)),
                    SizedBox(height: compact ? 12 : 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(a),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_tab),
                        child: switch (_tab) {
                          _StudioTab.beauty => _buildBeauty(compact),
                          _StudioTab.filters => _buildFilters(compact),
                          _StudioTab.effects => _buildEffects(compact),
                        },
                      ),
                    ),
                    if (widget.onGoLive != null) ...[
                      SizedBox(height: compact ? 14 : 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _GoLiveButton(onTap: widget.onGoLive!, height: compact ? 50 : 56),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- beauty

  Widget _buildBeauty(bool compact) {
    final beauty = _engine.beauty;
    final value = beauty.valueOf(_feature);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slider for the selected feature
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                _feature.label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: _gold,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    overlayColor: _gold.withValues(alpha: 0.15),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(value: value, onChanged: (v) => _engine.setBeauty(beauty.withValue(_feature, v))),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${(value * 100).round()}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: compact ? 76 : 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _RoundOption(
                label: beauty.isOff ? 'Off' : 'Reset',
                selected: false,
                onTap: () => _engine.setBeauty(beauty.isOff ? BeautySettings.natural : const BeautySettings()),
                child: Icon(
                  beauty.isOff ? Icons.auto_fix_high_rounded : Icons.block_rounded,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
              for (final f in BeautyFeature.values)
                _RoundOption(
                  label: f.label,
                  selected: f == _feature,
                  badge: beauty.valueOf(f) > 0,
                  onTap: () => setState(() => _feature = f),
                  child: Icon(f.icon, color: f == _feature ? _gold : Colors.white, size: 24),
                ),
            ],
          ),
        ),
        if (!_engine.supportsAr && (_feature != BeautyFeature.smooth && _feature != BeautyFeature.brighten))
          const _Hint('Teeth, eyes and slim need Face AR (Banuba token).'),
      ],
    );
  }

  // ---------------------------------------------------------------- filters

  Widget _buildFilters(bool compact) {
    return SizedBox(
      height: compact ? 96 : 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          for (final look in ColorLook.all)
            _RoundOption(
              label: look.name,
              selected: look.id == _engine.look.id,
              large: true,
              onTap: () => _engine.setLook(look),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: look.swatch),
                ),
                child: look.isNone
                    ? const Center(child: Icon(Icons.block_rounded, color: Colors.white70, size: 22))
                    : const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- AR effects

  Widget _buildEffects(bool compact) {
    if (!_engine.supportsAr) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            Icon(Icons.face_retouching_natural_rounded, color: _gold, size: 34),
            SizedBox(height: 8),
            Text(
              'AR effects are powered by Banuba',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Add your Banuba client token to the build to unlock masks and face effects.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 12.5),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: compact ? 96 : 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          _RoundOption(
            label: 'None',
            selected: _engine.effect == null,
            large: true,
            onTap: () => _engine.setEffect(null),
            child: const Icon(Icons.block_rounded, color: Colors.white70, size: 24),
          ),
          for (final e in ArEffect.bundled)
            _RoundOption(
              label: e.name,
              selected: _engine.effect?.id == e.id,
              large: true,
              onTap: () => _engine.setEffect(e),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: e.swatch),
                ),
                child: Center(child: Icon(e.icon, color: Colors.white, size: 28)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final _StudioTab selected;
  final ValueChanged<_StudioTab> onSelect;

  const _Tabs({required this.selected, required this.onSelect});

  static const _labels = {
    _StudioTab.beauty: ('Beauty', Icons.auto_awesome_rounded),
    _StudioTab.filters: ('Filters', Icons.palette_outlined),
    _StudioTab.effects: ('AR Effects', Icons.face_retouching_natural_rounded),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          for (final tab in _StudioTab.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: tab == selected ? const LinearGradient(colors: [Color(0xFFFFE066), _gold]) : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            _labels[tab]!.$2,
                            size: 16,
                            color: tab == selected ? const Color(0xFF1A1300) : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _labels[tab]!.$1,
                            style: TextStyle(
                              color: tab == selected ? const Color(0xFF1A1300) : Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Circle option with a label; gold ring when selected.
class _RoundOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool large;
  final bool badge;
  final VoidCallback onTap;
  final Widget child;

  const _RoundOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
    this.large = false,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final d = large ? 62.0 : 52.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: d + 18,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: d,
                  height: d,
                  padding: EdgeInsets.all(selected ? 3 : 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected ? const SweepGradient(colors: [_gold, _pink, Color(0xFF8E5BFF), _gold]) : null,
                    color: selected ? null : Colors.white.withValues(alpha: 0.18),
                    boxShadow: selected ? [BoxShadow(color: _gold.withValues(alpha: 0.45), blurRadius: 14)] : null,
                  ),
                  child: ClipOval(
                    child: ColoredBox(
                      color: const Color(0xFF17152A),
                      child: SizedBox.expand(child: Center(child: child)),
                    ),
                  ),
                ),
                if (badge)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0D0B1A), width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? _gold : Colors.white70,
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _muted, fontSize: 11.5),
      ),
    );
  }
}

class _GoLiveButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const _GoLiveButton({required this.onTap, required this.height});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Go Live',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: const LinearGradient(colors: [Color(0xFFFF3D6E), _pink, Color(0xFFB026FF)]),
            boxShadow: [BoxShadow(color: _pink.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensors_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Go Live',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
