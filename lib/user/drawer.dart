import 'package:flutter/material.dart';
import 'package:guitercord/user/favorite.dart';
import 'package:guitercord/model/artist.dart';
import 'package:guitercord/auth/service.dart';

class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final List<Singer> singers;
  final String currentRoute; // Added to track active page

  const AppDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.singers,
    this.currentRoute = '/home',
  });

  // --- Pro Logout Logic ---
  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to log out of Guitercord?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await AuthService().signOut();
      // StreamBuilder in main.dart will handle the switch to LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final surfaceColor = isDarkMode
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(isDarkMode),
            const Divider(indent: 20, endIndent: 20, height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  _DrawerTile(
                    icon: Icons.explore_rounded,
                    title: "Discover",
                    isSelected: currentRoute == '/home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerTile(
                    icon: Icons.favorite_rounded,
                    title: "My Library",
                    isSelected: currentRoute == '/favorites',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesPage(),
                        ),
                      );
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.queue_music_rounded,
                    title: "Collections",
                    isSelected: false,
                    onTap: () {},
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(indent: 8, endIndent: 8),
                  ),
                  _DrawerTile(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    onTap: () {},
                  ),
                  _DrawerTile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    iconColor: Colors.redAccent,
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),

            // --- Theme Toggle Section ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: isDarkMode ? Colors.purpleAccent : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDarkMode ? "Dark Mode" : "Light Mode",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: isDarkMode,
                      activeColor: primaryColor,
                      onChanged: (v) => onThemeToggle(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.blueAccent, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Developer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Text(
                "Guitercord Pro",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? iconColor;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: activeColor.withOpacity(0.1),
        leading: Icon(
          icon,
          color: isSelected ? activeColor : (iconColor ?? Colors.grey[600]),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? activeColor
                : (iconColor ?? theme.textTheme.bodyMedium?.color),
          ),
        ),
      ),
    );
  }
}
