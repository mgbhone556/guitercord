import 'package:flutter/material.dart';
import 'package:guitercord/auth/login.dart';
import 'package:guitercord/service/auth_service.dart';

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
      Navigator.pop(context);

      await AuthService().signOut();

      if (context.mounted) {
        MaterialPageRoute(builder: (context) => const LoginScreen());
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
