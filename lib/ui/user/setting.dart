import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Appearance"),
          Card(
            elevation: 0,
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDarkMode ? Colors.amber : Colors.blueGrey,
              ),
              title: const Text("Dark Mode"),
              subtitle: Text(isDarkMode ? "Enabled" : "Disabled"),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (_) => onThemeToggle(),
                activeColor: Colors.amber,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("Account"),
          _buildSettingsTile(
            Icons.person_outline_rounded,
            "Profile",
            "Manage your info",
          ),
          _buildSettingsTile(
            Icons.notifications_none_rounded,
            "Notifications",
            "Sound & Haptics",
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("About"),
          _buildSettingsTile(
            Icons.info_outline_rounded,
            "App Version",
            "1.0.0 (Build 2026)",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {},
    );
  }
}
