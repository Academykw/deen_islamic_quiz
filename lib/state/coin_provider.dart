import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// COIN PROVIDER
// Holds total coin balance, persists automatically
// ─────────────────────────────────────────────

class CoinNotifier extends Notifier<int> {
  @override
  int build() {
    _loadCoins();
    return 0; // Default until loaded
  }

  static const _key = 'deen_coins';

  // ── Load saved balance ─────────────────────────
  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_key) ?? 0;
  }

  // ── Add coins (after correct answer / session) ─
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    state = state + amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, state);
  }

  // ── Spend coins (lifelines in Phase 2) ────────
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;
    if (state < amount) return false; // Not enough coins
    state = state - amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, state);
    return true;
  }

  // ── Reset (testing only) ──────────────────────
  Future<void> resetCoins() async {
    state = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, 0);
  }
}

/// Watch this in any widget that displays coin balance
final coinProvider = NotifierProvider<CoinNotifier, int>(CoinNotifier.new);
