import 'package:flutter/material.dart';
import 'package:guitercord/home.dart';

void main() {
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
      home: HomeScreen(onThemeToggle: toggleTheme, isDarkMode: isDarkMode),
    );
  }

  final ThemeData _darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0A0A0F),
    primaryColor: const Color(0xFF8E54E9),
    cardColor: const Color(0xFF18161F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  final ThemeData _lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    primaryColor: const Color(0xFF6200EE),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
