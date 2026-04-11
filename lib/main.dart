import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guitercord/auth/role.dart';
import 'package:guitercord/auth/login.dart';
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
      title: 'Guitar Chord App',
      // ThemeMode ကို သုံးတာက ပိုပြီး Stable ဖြစ်ပါတယ်
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const AuthEntryGate(),
    );
  }
}

// Auth Logic ကို သီးသန့် Widget ခွဲထုတ်လိုက်တာက Build Cycle ကို ပိုမြန်စေပါတယ်
class AuthEntryGate extends StatelessWidget {
  const AuthEntryGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      // AuthService ထက်စာရင် FirebaseAuth ရဲ့ standard stream ကို တိုက်ရိုက်သုံးတာ ပိုစိတ်ချရပါတယ်
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading ဖြစ်နေချိန်မှာ အမည်းရောင်မဖြစ်အောင် White Background ထားပါတယ်
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Logged in ဖြစ်ရင် Role စစ်တဲ့ AuthWrapper ဆီသွားမယ်
          return AuthWrapper(user: snapshot.data!);
        }

        // Login မဝင်ရသေးရင် LoginScreen ဆီသွားမယ်
        return const LoginScreen();
      },
    );
  }
}

// --- Themes Setup ---

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
  scaffoldBackgroundColor: const Color(0xFF121212), // Standard Material Dark
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1B24),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
);
