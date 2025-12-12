// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kasir_go/screen/home_screen.dart';
// import 'package:kasir_go/utils/token_storage.dart';
// import 'screen/login_screen.dart';
// import 'screen/pos_screen.dart';

// void main() {

//   WidgetsFlutterBinding.ensureInitialized();
//    runApp(
//     const ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatefulWidget  {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final tokenStorage = TokenStorage();

//   String? initialRoute;
  
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialRoute();
//   }

//   Future<void> _loadInitialRoute() async {
//     final access = await tokenStorage.getAccessToken();

//     setState(() {
//       initialRoute = access != null ? '/home' : '/login';
//     });
//   }

//   @override
// Widget build(BuildContext context) {
//   return FutureBuilder<String?>(
//     future: tokenStorage.getAccessToken(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return MaterialApp(
//           home: Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(color: Colors.orange[800]),
//             ),
//           ),
//         );
//       }

//       // Kalau future selesai
//       final access = snapshot.data;

//       return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'KasirGo',
//         initialRoute: access != null ? '/home' : '/login',
//         routes: {
//           '/login': (_) => LoginScreen(),
//           '/home': (_) => const POSScreen(),
//         },
//       );
//     },
//   );
// }

// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/screen/login_screen.dart';
import 'package:kasir_go/utils/token_storage.dart';

import 'screen/pos_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await tokenStorage.getAccessToken();

    if (!mounted) return;

    // Navigasi ke home atau login
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/pos');
    } else {
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