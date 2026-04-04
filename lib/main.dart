import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:guitercord/auth/auth_wrapper.dart';
import 'package:guitercord/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guitercord/auth/service.dart';
import 'package:guitercord/firebase_options.dart';

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
      // ... inside your ChordApp build method ...
      home: StreamBuilder<firebase_auth.User?>(
        stream: AuthService().userStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            // Pass the logged-in user to the wrapper to check their role
            return AuthWrapper(user: snapshot.data!);
          }

          return const LoginScreen();
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
