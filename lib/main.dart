import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guitercord/auth/role.dart';
import 'package:guitercord/auth/login.dart';
import 'package:guitercord/firebase_options.dart';
import 'package:guitercord/provider/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FavoritesManager.init();
  } catch (e) {
    debugPrint("Initialization Error: $e");
  }
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
      title: 'Guitar Chord App',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const AuthEntryGate(),
    );
  }
}

class AuthEntryGate extends StatelessWidget {
  const AuthEntryGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return AuthWrapper(user: snapshot.data!);
        }

        return const LoginScreen();
      },
    );
  }
}

final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: const Color(0xFF6200EE),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF6200EE),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
);

final ThemeData _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: const Color(0xFF8E54E9),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1B24),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
);
