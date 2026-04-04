import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// 1. ADD THIS IMPORT for kIsWeb
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:guitercord/admin/admin.dart';
import 'package:guitercord/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guitercord/auth/service.dart';
import 'package:guitercord/firebase_options.dart';
import 'package:guitercord/user/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ChordApp());
}

class ChordApp extends StatefulWidget {
  const ChordApp({super.key});

  @override
  State<ChordApp> createState() => _ChordAppState();
}

class _ChordAppState extends State<ChordApp> {
  bool isDarkMode = false;

  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? _darkTheme : _lightTheme,
      home: StreamBuilder<firebase_auth.User?>(
        stream: AuthService().userStatus,
        builder: (context, snapshot) {
          // 1. Still checking Firebase?
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Not logged in?
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // 3. Logged in! Now check Platform
          if (kIsWeb) {
            return const AdminDashboard(); // Your Web Admin
          } else {
            return HomeScreen(
              onThemeToggle: toggleTheme,
              isDarkMode: isDarkMode,
            ); // Mobile App
          }
        },
      ),
    );
  }

  // Define themes here
  final ThemeData _darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0A0A0F),
    primaryColor: const Color(0xFF8E54E9),
    cardColor: const Color(0xFF18161F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );

  final ThemeData _lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    primaryColor: const Color(0xFF6200EE),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
