import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/auth/logout.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.email ?? "Admin User",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "GUITERCORD ADMIN",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Navigation Items ---
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text("Overview"),
              selected: selectedIndex == 0,
              onTap: () {
                Navigator.pop(context); // Close drawer
                onTabSelected(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_rounded),
              title: const Text("Artists"),
              selected: selectedIndex == 2,
              onTap: () {
                Navigator.pop(context);
                onTabSelected(2);
              },
            ),
            // NEW: Added Songs/Chords Management Tab
            ListTile(
              leading: const Icon(Icons.music_note_rounded),
              title: const Text("Manage Chords"),
              selected: selectedIndex == 3,
              onTap: () {
                Navigator.pop(context);
                onTabSelected(3);
              },
            ),

            const Spacer(),
            const Divider(indent: 20, endIndent: 20),

            // --- Logout Section ---
            const LogoutTile(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
