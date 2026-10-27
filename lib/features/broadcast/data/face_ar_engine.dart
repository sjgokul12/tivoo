import 'dart:ui' show ImageFilter;

import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../domain/models/face_effects.dart';

/// Banuba Face AR client token. Build with:
///   flutter build apk --dart-define=BANUBA_TOKEN=YOUR_TOKEN
/// Without it the Go Live screen uses [CameraFaceArEngine] (no AR masks).
const banubaToken = String.fromEnvironment('BANUBA_TOKEN');

/// Camera + effects pipeline behind the Go Live screen.
abstract class FaceArEngine extends ChangeNotifier {
  FaceArEngine();

  BeautySettings _beauty = BeautySettings.natural;
  ColorLook _look = ColorLook.none;
  ArEffect? _effect;

  BeautySettings get beauty => _beauty;
  ColorLook get look => _look;
  ArEffect? get effect => _effect;

  /// Whether AR masks / real face retouch are available (Banuba).
  bool get supportsAr;
  bool get isReady;
  bool get isFrontCamera;

  /// Set when the camera could not start.
  String? get error;

  Future<void> start();
  Future<void> flipCamera();
  Future<void> setFlash(bool on);
  void pause();
  void resume();
  Widget buildPreview(BuildContext context);

  void setBeauty(BeautySettings value) {
    _beauty = value;
    onEffectsChanged();
    notifyListeners();
  }

  void setLook(ColorLook value) {
    _look = value;
    onEffectsChanged();
    notifyListeners();
  }

  void setEffect(ArEffect? value) {
    _effect = value;
    onEffectsChanged();
    notifyListeners();
  }

  @protected
  void onEffectsChanged() {}

  /// Picks Banuba when a token was provided at build time on a supported platform.
  factory FaceArEngine.create() {
    final mobile =
        !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
    return banubaToken.isNotEmpty && mobile ? BanubaFaceArEngine() : CameraFaceArEngine();
  }

  /// Colour grade + brighten as one matrix.
  @protected
  ColorFilter? colorFilter() {
    final b = _beauty.brighten;
    final brighten = b == 0
        ? null
        : <double>[
            1 + 0.1 * b, 0, 0, 0, 16 * b, //
            0, 1 + 0.1 * b, 0, 0, 14 * b,
            0, 0, 1 + 0.08 * b, 0, 12 * b,
            0, 0, 0, 1, 0,
          ];
    final grade = _look.matrix;
    if (grade == null && brighten == null) return null;
    if (grade == null) return ColorFilter.matrix(brighten!);
    if (brighten == null) return ColorFilter.matrix(grade);
    return ColorFilter.matrix(_compose(grade, brighten));
  }

  /// a ∘ b for 4×5 colour matrices (apply b first, then a).
  static List<double> _compose(List<double> a, List<double> b) {
    final out = List<double>.filled(20, 0);
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 5; c++) {
        var v = c == 4 ? a[r * 5 + 4] : 0.0;
        for (var k = 0; k < 4; k++) {
          v += a[r * 5 + k] * b[k * 5 + c];
        }
        out[r * 5 + c] = v;
      }
    }
    return out;
  }
}

// =============================================================================
// BANUBA
// =============================================================================

/// Banuba Face AR: real-time face tracking, skin retouch and AR masks.
class BanubaFaceArEngine extends FaceArEngine {
  final _sdk = BanubaSdkManager();
  late final EffectPlayerWidget _view = EffectPlayerWidget(onPlatformViewCreated: (_) => _attach());

  bool _initialized = false;
  bool _attached = false;
  bool _front = true;
  String? _loadedPath;
  String? _error;

  @override
  bool get supportsAr => true;
  @override
  bool get isReady => _initialized;
  @override
  bool get isFrontCamera => _front;
  @override
  String? get error => _error;

  @override
  Future<void> start() async {
    try {
      await _sdk.initialize([], banubaToken, SeverityLevel.info);
      _initialized = true;
    } catch (e) {
      _error = 'Face AR could not start: $e';
    }
    notifyListeners();
  }

  Future<void> _attach() async {
    try {
      await _sdk.openCamera();
      await _sdk.attachWidget(_view.banubaId);
      await _sdk.startPlayer();
      _attached = true;
      await _syncEffect();
    } catch (e) {
      _error = 'Camera could not start: $e';
      notifyListeners();
    }
  }

  @override
  void onEffectsChanged() => _syncEffect();

  /// One Banuba effect runs at a time: the chosen AR mask, or the beauty effect.
  Future<void> _syncEffect() async {
    if (!_attached) return;
    final target = effect?.path ?? (beauty.isOff ? null : 'effects/${ArEffect.beautyFolder}');
    try {
      if (target != _loadedPath) {
        if (target == null) {
          await _sdk.unloadEffect();
        } else {
          await _sdk.loadEffect(target, false);
        }
        _loadedPath = target;
      }
      if (target != null && effect == null) {
        // Banuba Makeup effect API.
        await _sdk.evalJs(
          'Skin.softening(${beauty.smooth.toStringAsFixed(2)});'
          'Teeth.whitening(${beauty.teeth.toStringAsFixed(2)});'
          'Eyes.whitening(${beauty.eyes.toStringAsFixed(2)});'
          'FaceMorph.face(${beauty.slim.toStringAsFixed(2)});',
        );
      }
    } catch (e) {
      debugPrint('Banuba effect error: $e');
    }
  }

  @override
  Future<void> flipCamera() async {
    _front = !_front;
    await _sdk.setCameraFacing(_front);
    notifyListeners();
  }

  @override
  Future<void> setFlash(bool on) => _sdk.enableFlashlight(on && !_front);

  @override
  void pause() {
    if (_attached) _sdk.stopPlayer();
  }

  @override
  void resume() {
    if (_attached) _sdk.startPlayer();
  }

  @override
  Widget buildPreview(BuildContext context) {
    if (!_initialized) return const ColoredBox(color: Colors.black);
    final filter = colorFilter();
    return filter == null ? _view : ColorFiltered(colorFilter: filter, child: _view);
  }

  @override
  void dispose() {
    if (_attached) {
      _sdk.stopPlayer();
      _sdk.closeCamera();
    }
    if (_initialized) _sdk.deinitialize();
    super.dispose();
  }
}

// =============================================================================
// PLAIN CAMERA (no Banuba token)
// =============================================================================

/// Regular camera with colour grades, brightening and a soft-focus skin glow.
class CameraFaceArEngine extends FaceArEngine {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _index = 0;
  bool _ready = false;
  bool _usePortraitFallback = false;
  String? _error;

  @override
  bool get supportsAr => false;
  @override
  bool get isReady => _ready;
  @override
  bool get isFrontCamera => _cameras.isEmpty || _cameras[_index].lensDirection == CameraLensDirection.front;
  @override
  String? get error => _error;

  @override
  Future<void> start() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _usePortraitFallback = true;
      } else {
        final front = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
        _index = front >= 0 ? front : 0;
        await _open(_cameras[_index]);
      }
    } catch (_) {
      // Emulators / desktops without a camera: show a sample portrait so the studio can be tried.
      _usePortraitFallback = true;
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> _open(CameraDescription d) async {
    final previous = _controller;
    final c = CameraController(d, ResolutionPreset.high, enableAudio: true);
    _controller = c;
    await c.initialize();
    await previous?.dispose();
    notifyListeners();
  }

  @override
  Future<void> flipCamera() async {
    if (_cameras.length < 2) return;
    _index = (_index + 1) % _cameras.length;
    await _open(_cameras[_index]);
  }

  @override
  Future<void> setFlash(bool on) async {
    try {
      await _controller?.setFlashMode(on ? FlashMode.torch : FlashMode.off);
    } catch (_) {}
  }

  @override
  void pause() {
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      _controller = null;
      c.dispose();
      notifyListeners();
    }
  }

  @override
  void resume() {
    if (_controller == null && _cameras.isNotEmpty) _open(_cameras[_index]);
  }

  @override
  Widget buildPreview(BuildContext context) {
    Widget picture;
    final c = _controller;
    if (!_usePortraitFallback && c != null && c.value.isInitialized && c.value.previewSize != null) {
      final size = c.value.previewSize!;
      Widget preview() => FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(width: size.height, height: size.width, child: CameraPreview(c)),
      );
      picture = Stack(
        fit: StackFit.expand,
        children: [
          preview(),
          // Soft-focus glow: a blurred copy of the picture on top smooths skin texture.
          if (beauty.smooth > 0)
            Opacity(
              opacity: (beauty.smooth * 0.42).clamp(0.0, 1.0),
              child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), child: preview()),
            ),
        ],
      );
    } else if (_usePortraitFallback) {
      picture = Image.asset(AppAssets.avatarPriya, fit: BoxFit.cover);
    } else {
      picture = const ColoredBox(color: Colors.black);
    }
    final filter = colorFilter();
    return SizedBox.expand(
      child: filter == null ? picture : ColorFiltered(colorFilter: filter, child: picture),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
