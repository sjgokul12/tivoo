import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Centralized audio service for realistic live stream gift sound effects
class GiftSoundService {
  GiftSoundService._() {
    _init();
  }

  static final GiftSoundService instance = GiftSoundService._();

  AudioPlayer? _player;
  bool _isMuted = false;
  int _playSessionId = 0;

  bool get isMuted => _isMuted;
  set isMuted(bool val) {
    _isMuted = val;
    if (_isMuted) stop();
  }

  void _init() {
    try {
      _player = AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('GiftSoundService init error: $e');
    }
  }

  /// Sound file (under assets/) for a gift category. Premium gifts each have their own
  /// full-length track in sounds/gift/; small gifts use the short sounds.
  static String soundFor(String category) {
    switch (category.toLowerCase()) {
      case 'lion':
        return 'sounds/gift/sound_lion.wav';
      case 'horse':
        return 'sounds/gift/sound_horse.wav';
      case 'car':
        return 'sounds/gift/sound_car.wav';
      case 'rocket':
        return 'sounds/gift/sound_rocket.wav';
      case 'yacht':
        return 'sounds/gift/sound_yacht.wav';
      case 'whale':
      case 'dolphin':
        return 'sounds/gift/sound_ocean_dolphin.wav';
      case 'wings':
        return 'sounds/gift/sound_diamond_wings.wav';
      case 'angel_vehicle':
        return 'sounds/gift/sound_angel_vehicle.wav';
      case 'crown':
        return 'sounds/gift/sound_crown.wav';
      case 'throne':
        return 'sounds/gift/sound_throne.wav';
      case 'castle':
        return 'sounds/gift/sound_love_castle.wav';
      case 'roses':
        return 'sounds/gift/sound_roses.wav';
      case 'diamond':
      case 'meteor':
      case 'shower':
        return 'sounds/sound_diamond.wav';
      case 'rose':
      case 'flowers':
      case 'flower':
      case 'chariot':
        return 'sounds/sound_rose.wav';
      case 'world_tour':
      case 'tour':
        return 'sounds/sound_castle.wav';
      case 'love':
      case 'tiki':
        return 'sounds/sound_love.wav';
      case 'kitty':
      case 'teddy':
      case 'cat':
      case 'panda':
        return 'sounds/sound_kitty.wav';
      case 'cake':
        return 'sounds/sound_cake.wav';
      default:
        return 'sounds/sound_generic.wav';
    }
  }

  bool _preloaded = false;

  /// Copies the premium tracks into the audio cache ahead of time, so the first
  /// gift's sound starts exactly with its animation instead of after a load delay.
  Future<void> preload() async {
    if (_preloaded) return;
    _preloaded = true;
    try {
      await AudioCache.instance.loadAll([
        for (final c in const ['lion', 'horse', 'dolphin', 'car', 'rocket', 'yacht', 'wings', 'crown', 'castle'])
          soundFor(c),
      ]);
    } catch (e) {
      debugPrint('GiftSoundService preload note: $e');
    }
  }

  /// Plays the authentic sound effect corresponding to the active gift category
  Future<void> playGiftSound(String category) async {
    if (_isMuted) return;

    final sessionId = ++_playSessionId;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      final soundFile = soundFor(category);

      if (_playSessionId != sessionId) return;

      // In browsers, directly set source and play without calling stop() immediately beforehand
      await _player?.play(AssetSource(soundFile), volume: 1.0);
    } catch (e) {
      // Ignored for harmless browser playback interruption
      if (!kIsWeb) {
        debugPrint('GiftSoundService non-critical play note: $e');
      }
    }
  }

  /// Stops current playing audio immediately (e.g. when skipped or overlay closed)
  Future<void> stop() async {
    _playSessionId++;
    try {
      await _player?.stop();
    } catch (_) {}
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
