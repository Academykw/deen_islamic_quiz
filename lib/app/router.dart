import 'package:deen_iq/features/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/quiz_model.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/widgets/home_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/quiz/widget/question_screen.dart';
import '../features/quiz/widget/stage_select_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/quiz/result_screen.dart';
import '../features/quiz/difficulty_screen.dart';

// ── Route names ────────────────────────────────
class Routes {
  Routes._();
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const home = 'home';
  static const difficulty = 'difficulty';
  static const stages = 'stages';
  static const question = 'question';
  static const result = 'result';
  static const leaderboard = 'leaderboard';
  static const profile = 'profile';

}

// ── Route paths ────────────────────────────────
class RoutePaths {
  RoutePaths._();
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const difficulty = '/difficulty';
  static const stages = '/stages/:difficulty';
  static const question = '/question';
  static const result = '/result';
  static const leaderboard = '/leaderboard';
  static const profile = '/profile';
}

// ── Extra objects passed via GoRouter extra ────
class StageExtra {
  const StageExtra({required this.stage, required this.difficulty});
  final Stage stage;
  final Difficulty difficulty;
}

class ResultExtra {
  const ResultExtra({required this.stage});
  final Stage stage;
}

// ── Router provider ────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    routes: [

      // ── Splash ──────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        name: Routes.splash,
        pageBuilder: (context, state) => _buildPage(
          state,
          const SplashScreen(),
        ),
      ),


      GoRoute(
        path: RoutePaths.profile,
        name: Routes.profile,
        pageBuilder: (context, state) => _buildSlide(
          state,
          const AuthGate(child: ProfileScreen()),
        ),
      ),

      GoRoute(
        path: RoutePaths.leaderboard,
        name: Routes.leaderboard,
        pageBuilder: (context, state) => _buildSlide(
          state,
          const AuthGate(child: LeaderboardScreen()),
        ),
      ),


      // ── Login ───────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: Routes.login,
        pageBuilder: (context, state) => _buildPage(
          state,
          const LoginScreen(),
        ),
      ),

      // ── Register ───────────────────────────
      GoRoute(
        path: RoutePaths.register,
        name: Routes.register,
        pageBuilder: (context, state) => _buildPage(
          state,
          const RegisterScreen(),
        ),
      ),

      // ── Home ────────────────────────────────
      GoRoute(
        path: RoutePaths.home,
        name: Routes.home,
        pageBuilder: (context, state) => _buildPage(
          state,
          AuthGate(child:  HomeScreen()),
        ),
      ),

      // ── Difficulty ──────────────────────────
      GoRoute(
        path: RoutePaths.difficulty,
        name: Routes.difficulty,
        pageBuilder: (context, state) => _buildSlide(
          state,
          const DifficultyScreen(),
        ),
      ),

      // ── Stage select ─────────────────────────
      GoRoute(
        path: RoutePaths.stages,
        name: Routes.stages,
        pageBuilder: (context, state) {
          final diffStr =
              state.pathParameters['difficulty'] ?? 'easy';
          final difficulty = _parseDifficulty(diffStr);
          return _buildSlide(
            state,
            StageSelectScreen(difficulty: difficulty),
          );
        },
      ),

      // ── Question ────────────────────────────
      GoRoute(
        path: RoutePaths.question,
        name: Routes.question,
        pageBuilder: (context, state) {
          final extra = state.extra as StageExtra;
          return _buildFade(
            state,
            QuestionScreen(stage: extra.stage),
          );
        },
      ),

      // ── Result ──────────────────────────────
      GoRoute(
        path: RoutePaths.result,
        name: Routes.result,
        pageBuilder: (context, state) {
          final extra = state.extra as ResultExtra;
          return _buildFade(
            state,
            ResultScreen(stage: extra.stage),
          );
        },
      ),
    ],

    // ── Error page ─────────────────────────────
    errorPageBuilder: (context, state) => _buildPage(
      state,
      _ErrorScreen(error: state.error.toString()),
    ),
  );
});

// ── Page transition helpers ────────────────────

/// Default — no animation (for root screens)
CustomTransitionPage<void> _buildPage(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// Slide from right (for drill-down screens)
CustomTransitionPage<void> _buildSlide(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Fade (for quiz screens — no back swipe feel)
CustomTransitionPage<void> _buildFade(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// ── Difficulty parser ──────────────────────────
Difficulty _parseDifficulty(String str) {
  switch (str.toLowerCase()) {
    case 'medium': return Difficulty.medium;
    case 'hard':   return Difficulty.hard;
    default:       return Difficulty.easy;
  }
}

// ── Error screen ───────────────────────────────
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A12),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFE05252), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF0EAD6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: Color(0xFF5E7A65),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () =>
                    context.goNamed(Routes.home),
                child: const Text(
                  'Go Home',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Color(0xFFC9A84C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}