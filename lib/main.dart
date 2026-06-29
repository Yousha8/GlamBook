import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/service_providers.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_wrapper.dart';
import 'presentation/screens/onboarding/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // IMPORTANT: For this to work, the user must add google-services.json
  // For now, I'll wrap it in a try-catch to allow local testing if Firebase is not yet configured
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e. Ensure google-services.json is present.');
  }
  
  runApp(
    const ProviderScope(
      child: GlamBookApp(),
    ),
  );
}

class GlamBookApp extends ConsumerWidget {
  const GlamBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'GlamBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainWrapper();
          }
          return const LoginScreen();
        },
        loading: () => const SplashScreen(),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error: $err'),
          ),
        ),
      ),
    );
  }
}
