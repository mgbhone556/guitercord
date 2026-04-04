import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:guitercord/admin/admin.dart';
import 'package:guitercord/auth/login.dart';
import 'package:guitercord/user/home.dart';

class AuthWrapper extends StatefulWidget {
  final firebase_auth.User user;
  const AuthWrapper({super.key, required this.user});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isDarkMode = false;

  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      // Look up the user's document using their unique UID
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the document exists, check the role
        if (snapshot.hasData && snapshot.data!.exists) {
          String role = snapshot.data!.get('role') ?? 'user';

          if (role == 'admin') {
            return const AdminDashboard();
          } else {
            return HomeScreen(
              onThemeToggle: toggleTheme,
              isDarkMode: isDarkMode,
            ); // Your normal mobile user home
          }
        }

        // Fallback if something goes wrong
        return const LoginScreen();
      },
    );
  }
}
