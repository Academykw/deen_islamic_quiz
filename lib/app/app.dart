import 'package:deen_iq/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';

class DeenQuizApp extends ConsumerWidget {
  const DeenQuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Deen — Islamic Quiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Temporary home — replaced with GoRouter in Step 10
      home: const SplashScreen(),
    );
  }
}