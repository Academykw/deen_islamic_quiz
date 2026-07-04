import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/settings_provider.dart';

enum SoundEffect {
  correct,
  wrong,
  coinEarn,
  buttonTap,
  stageComplete,
  comboBurst,
}

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final Map<SoundEffect, AudioPlayer> _players = {};
  bool _isEnabled = true;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  String _assetFor(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.correct:
        return 'audio/correct.mp3';
      case SoundEffect.wrong:
        return 'audio/wrong.mp3';
      case SoundEffect.coinEarn:
        return 'audio/coin_earn.mp3';
      case SoundEffect.buttonTap:
        return 'audio/button_tap.mp3';
      case SoundEffect.stageComplete:
        return 'audio/stage_complete.mp3';
      case SoundEffect.comboBurst:
        return 'audio/combo_burst.mp3';
    }
  }

  Future<void> play(SoundEffect effect) async {
    if (!_isEnabled) return;

    try {
      // Reuse player per effect type to avoid lag
      final player = _players.putIfAbsent(
        effect,
            () => AudioPlayer()
          ..setReleaseMode(ReleaseMode.stop),
      );

      await player.stop();
      await player.play(
        AssetSource(_assetFor(effect)),
        volume: 0.7,
      );
    } catch (_) {
      // Silently fail if asset missing — app must not crash
      // without audio files present
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}

// ── Riverpod wrapper ────────────────────────────
final audioServiceProvider = Provider<AudioService>((ref) {
  final settings = ref.watch(settingsProvider);
  AudioService.instance.setEnabled(settings.isSoundEnabled);
  return AudioService.instance;
});