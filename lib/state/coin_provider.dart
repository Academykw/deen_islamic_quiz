import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Read-only view of the server wallet. The device never calculates, persists,
/// or writes an authoritative balance.
class CoinNotifier extends Notifier<int> {
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _walletSubscription;

  @override
  int build() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _walletSubscription?.cancel();
      if (user == null) {
        state = 0;
        return;
      }
      _walletSubscription = FirebaseFirestore.instance
          .collection('wallets')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
            final wallet = snapshot.data();
            final earned = wallet?['balance'];
            final bonus = wallet?['bonusBalance'];
            state = (earned is int ? earned : 0) + (bonus is int ? bonus : 0);
          });
    });
    ref.onDispose(() {
      _authSubscription?.cancel();
      _walletSubscription?.cancel();
    });
    return 0;
  }
}

final coinProvider = NotifierProvider<CoinNotifier, int>(CoinNotifier.new);
