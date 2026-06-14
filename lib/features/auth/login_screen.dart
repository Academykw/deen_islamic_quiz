import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constant/app_colors.dart';
import '../../core/widgets/geo_background.dart';
import '../../core/widgets/gold_button.dart';

import '../../app/router.dart';
import '../../state/auth_provider.dart';

import '../quiz/widget/auth_text_field.dart';
import 'widgets/social_auth_button.dart';
import 'widgets/auth_ui_components.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isGuestLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Email login ────────────────────────────────
  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(currentUserProvider.notifier)
        .signInWithEmail(_emailCtrl.text, _passCtrl.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == AuthResult.success) {
      context.goNamed(Routes.home);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  // ── Google login ───────────────────────────────
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(currentUserProvider.notifier)
        .signInWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (result == AuthResult.success) {
      context.goNamed(Routes.home);
    } else if (result != AuthResult.cancelled) {
      setState(() => _errorMessage = result.message);
    }
  }

  // ── Guest login ────────────────────────────────
  Future<void> _loginAsGuest() async {
    setState(() {
      _isGuestLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(currentUserProvider.notifier)
        .signInAsGuest();

    if (!mounted) return;
    setState(() => _isGuestLoading = false);

    if (result == AuthResult.success) {
      context.goNamed(Routes.home);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Logo + title ─────────────
                    const AuthHeader(
                      title: 'Welcome Back',
                      subtitle: 'مرحباً بعودتك',
                    ),

                    const SizedBox(height: 36),

                    // ── Email field ───────────────
                    AuthTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'your@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Email is required';
                        }
                        if (!v.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Password field ────────────
                    AuthTextField(
                      controller: _passCtrl,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outlined,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: _loginWithEmail,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        if (v.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // ── Forgot password ───────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPassword,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),

                    // ── Error message ─────────────
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      ErrorBanner(message: _errorMessage!),
                    ],

                    const SizedBox(height: 20),

                    // ── Sign in button ────────────
                    GoldButton(
                      label: 'Sign In',
                      onTap: _loginWithEmail,
                      isLoading: _isLoading,
                      icon: Icons.login_rounded,
                    ),

                    const SizedBox(height: 24),

                    // ── Divider ───────────────────
                    const OrDivider(),

                    const SizedBox(height: 20),

                    // ── Google button ─────────────
                    SocialAuthButton(
                      label: 'Continue with Google',
                      icon: const GoogleIcon(),
                      onTap: _loginWithGoogle,
                      isLoading: _isGoogleLoading,
                    ),

                    const SizedBox(height: 12),

                    // ── Guest button ──────────────
                    SocialAuthButton(
                      label: 'Continue as Guest',
                      icon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onTap: _loginAsGuest,
                      isLoading: _isGuestLoading,
                    ),

                    const SizedBox(height: 32),

                    // ── Register link ─────────────
                    Center(
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context
                                .goNamed(Routes.register),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your email and we\'ll send a reset link.',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: ctrl,
                label: 'Email',
                hint: 'your@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              GoldButton(
                label: 'Send Reset Link',
                onTap: () async {
                  if (ctrl.text.isEmpty) return;
                  final sm = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(context);
                  try {
                    await ref
                        .read(firebaseAuthProvider)
                        .sendPasswordResetEmail(email: ctrl.text.trim());
                    nav.pop();
                    sm.showSnackBar(const SnackBar(
                      content: Text(
                        'Reset link sent! Check your email.',
                        style: TextStyle(fontFamily: 'Tajawal'),
                      ),
                      backgroundColor: AppColors.emerald,
                    ));
                  } catch (_) {}
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
