import 'package:flutter/material.dart';
import 'package:guitercord/auth/login.dart';
import 'package:guitercord/service/auth_service.dart'; // Ensure this path is correct

class LogoutTile extends StatelessWidget {
  const LogoutTile({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // 1. Close the drawer
      Navigator.pop(context);

      // 2. TRIGGER THE ACTUAL LOGOUT
      // This clears the Firebase session/Token
      await AuthService().signOut();

      // 3. Redirect to login and clear navigation stack
      // Using pushNamedAndRemoveUntil ensures the user can't go "Back"
      if (context.mounted) {
        MaterialPageRoute(
          builder: (context) =>
              const LoginScreen(), // Replace with your login screen
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        "Logout",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      onTap: () => _handleLogout(context),
    );
  }
}
