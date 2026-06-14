import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constant/app_colors.dart';

import '../../core/widgets/geo_background.dart';
import '../../core/widgets/gold_button.dart';
import '../../state/auth_provider.dart';
import '../../app/router.dart';
import '../quiz/widget/auth_text_field.dart';
import 'widgets/social_auth_button.dart';
import 'widgets/auth_ui_components.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(currentUserProvider.notifier)
        .registerWithEmail(
      _emailCtrl.text,
      _passCtrl.text,
      _nameCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == AuthResult.success) {
      context.goNamed(Routes.home);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  Future<void> _registerWithGoogle() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Back button ───────────────
                    IconButton(
                      onPressed: () =>
                          context.goNamed(Routes.login),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 12),

                    // ── Title ─────────────────────
                    const AuthHeader(
                      title: 'Create Account',
                      subtitle: 'إنشاء حساب جديد',
                    ),

                    const SizedBox(height: 28),

                    // ── Name field ────────────────
                    AuthTextField(
                      controller: _nameCtrl,
                      label: 'Display Name',
                      hint: 'Your name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (v.trim().length < 2) {
                          return 'At least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

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
                      hint: 'At least 6 characters',
                      icon: Icons.lock_outlined,
                      isPassword: true,
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

                    const SizedBox(height: 16),

                    // ── Confirm password ──────────
                    AuthTextField(
                      controller: _confirmCtrl,
                      label: 'Confirm Password',
                      hint: 'Repeat your password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: _register,
                      validator: (v) {
                        if (v != _passCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    // ── Error message ─────────────
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      ErrorBanner(message: _errorMessage!),
                    ],

                    const SizedBox(height: 24),

                    // ── Register button ───────────
                    GoldButton(
                      label: 'Create Account',
                      onTap: _register,
                      isLoading: _isLoading,
                      icon: Icons.person_add_rounded,
                    ),

                    const SizedBox(height: 24),

                    const OrDivider(),

                    const SizedBox(height: 20),

                    // ── Google button ─────────────
                    SocialAuthButton(
                      label: 'Continue with Google',
                      icon: const GoogleIcon(),
                      onTap: _registerWithGoogle,
                      isLoading: _isGoogleLoading,
                    ),

                    const SizedBox(height: 28),

                    // ── Login link ────────────────
                    Center(
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                context.goNamed(Routes.login),
                            child: const Text(
                              'Sign In',
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
}
