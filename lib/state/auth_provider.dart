import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_user.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userProfileProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) {
      // Create initial profile if it doesn't exist
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? (user.isAnonymous ? 'Guest' : 'Anonymous'),
        avatarEmoji: '👤',
        country: '',
        totalCorrect: 0,
        totalAttempted: 0,
        bestStreak: 0,
        stagesCompleted: 0,
        isGuest: user.isAnonymous,
      );
    }
    return AppUser.fromMap(doc.data()!, user.uid, isGuest: user.isAnonymous);
  });
});

final currentUserProvider =
    NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends Notifier<User?> {
  @override
  User? build() {
    return ref.watch(firebaseAuthProvider).currentUser;
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      state = ref.read(firebaseAuthProvider).currentUser;
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(e.message ?? 'An error occurred');
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  Future<AuthResult> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential =
          await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
                email: email.trim(),
                password: password.trim(),
              );
      await credential.user?.updateDisplayName(displayName);
      state = ref.read(firebaseAuthProvider).currentUser;
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(e.message ?? 'An error occurred');
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Obtain access token for Firebase
      final authz = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      state = ref.read(firebaseAuthProvider).currentUser;
      return AuthResult.success;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return AuthResult.cancelled;
      }
      return AuthResult.error(e.toString());
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(e.message ?? 'Authentication failed');
    } catch (e) {
      if (e.toString().contains('sign_in_failed')) {
        return AuthResult.error(
            'Sign in failed. Ensure your SHA-1 is added to Firebase Console.');
      }
      return AuthResult.error(e.toString());
    }
  }

  Future<AuthResult> signInAsGuest() async {
    try {
      await ref.read(firebaseAuthProvider).signInAnonymously();
      state = ref.read(firebaseAuthProvider).currentUser;
      return AuthResult.success;
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await ref.read(googleSignInProvider).signOut();
    await ref.read(firebaseAuthProvider).signOut();
    state = null;
  }
}

class AuthResult {
  final String? message;
  final bool isSuccess;
  final bool isCancelled;

  const AuthResult._({
    this.message,
    this.isSuccess = false,
    this.isCancelled = false,
  });

  static const success = AuthResult._(isSuccess: true);
  static const cancelled = AuthResult._(isCancelled: true);
  static AuthResult error(String message) => AuthResult._(message: message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResult &&
          runtimeType == other.runtimeType &&
          isSuccess == other.isSuccess &&
          isCancelled == other.isCancelled &&
          message == other.message;

  @override
  int get hashCode =>
      message.hashCode ^ isSuccess.hashCode ^ isCancelled.hashCode;
}
