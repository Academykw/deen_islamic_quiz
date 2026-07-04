import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  const SettingsState({
    this.isSoundEnabled = true,
    this.isHapticsEnabled = true,
    this.isLoaded = false,
  });

  final bool isSoundEnabled;
  final bool isHapticsEnabled;
  final bool isLoaded;

  SettingsState copyWith({
    bool? isSoundEnabled,
    bool? isHapticsEnabled,
    bool? isLoaded,
  }) {
    return SettingsState(
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isHapticsEnabled:
      isHapticsEnabled ?? this.isHapticsEnabled,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  static const _soundKey = 'deen_sound_enabled';
  static const _hapticsKey = 'deen_haptics_enabled';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      isSoundEnabled: prefs.getBool(_soundKey) ?? true,
      isHapticsEnabled: prefs.getBool(_hapticsKey) ?? true,
      isLoaded: true,
    );
  }

  Future<void> toggleSound() async {
    final newValue = !state.isSoundEnabled;
    state = state.copyWith(isSoundEnabled: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, newValue);
  }

  Future<void> toggleHaptics() async {
    final newValue = !state.isHapticsEnabled;
    state = state.copyWith(isHapticsEnabled: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, newValue);
  }
}

final settingsProvider =
StateNotifierProvider<SettingsNotifier, SettingsState>(
      (ref) => SettingsNotifier(),
);