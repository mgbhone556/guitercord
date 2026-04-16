import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/ui/admin/admin_dashboard.dart';
import 'package:guitercord/ui/user/user_home_page.dart';

class AuthRoleWrapper extends StatefulWidget {
  final User user;
  const AuthRoleWrapper({super.key, required this.user});

  @override
  State<AuthRoleWrapper> createState() => _AuthRoleWrapperState();
}

class _AuthRoleWrapperState extends State<AuthRoleWrapper> {
  bool isDarkMode = false;
  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          String role = data['role'] ?? 'user';

          return role == 'admin'
              ? const AdminDashboard()
              : UserHomePage(
                  onThemeToggle: toggleTheme,
                  isDarkMode: isDarkMode,
                  singer: Singer(
                    id: '',
                    name: '',
                    genre: '',
                    imageUrl: '',
                    accentColor: Colors.blue,
                    bio: '',
                  ),
                  song: Song(
                    id: null,
                    title: "",
                    chordsUsed: [],
                    lyricsWithChords: [],
                    albums: [],
                    singerId: '',
                  ),
                );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
