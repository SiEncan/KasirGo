import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/screen/login_screen.dart';
import 'package:kasir_go/screen/kitchen/kitchen_screen.dart';
import 'package:kasir_go/utils/token_storage.dart';
import 'package:kasir_go/providers/app_mode_provider.dart';
import 'package:kasir_go/providers/auth_provider.dart';
import 'package:kasir_go/screen/mode_selection_screen.dart';

import 'screen/pos_screen.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KasirGo',
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/pos': (_) => const POSScreen(),
        '/kitchen': (_) => const KitchenScreen(),
        '/mode_selection': (_) => const ModeSelectionScreen(),
      },
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await tokenStorage.getAccessToken();

    if (!mounted) return;

    if (token != null) {
      // Restore Firebase Session
      try {
        final authService = ref.read(authServiceProvider);
        final userId = await authService.getUserId();
        if (userId != null) {
          await authService.authenticateFirebase(userId, token);
        }
      } catch (e) {
        debugPrint("Firebase Restore Failed: $e");
      }

      // Token valid, check mode
      await ref.read(appModeProvider.notifier).loadSavedMode();
      final savedMode = ref.read(appModeProvider);

      if (!mounted) return;

      if (savedMode == AppMode.pos) {
        Navigator.pushReplacementNamed(context, '/pos');
      } else if (savedMode == AppMode.kitchen) {
        Navigator.pushReplacementNamed(context, '/kitchen');
      } else {
        // Logged in but no mode selected yet
        Navigator.pushReplacementNamed(context, '/mode_selection');
      }
    } else {
      // Not logged in
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Colors.orange[800]),
      ),
    );
  }
}
