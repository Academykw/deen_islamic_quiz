import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constant/app_colors.dart';
import '../../state/auth_provider.dart';

import '../../app/router.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const _LoadingScreen(),
      error: (_, __) => const _LoadingScreen(),
      data: (user) {
        if (user == null) {
          // Not logged in — redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goNamed(Routes.login);
          });
          return const _LoadingScreen();
        }
        // Logged in — show the requested screen
        return child;
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.gold,
          strokeWidth: 2,
        ),
      ),
    );
  }
}