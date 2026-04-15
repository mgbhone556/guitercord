import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/auth/logout.dart';
import 'package:guitercord/ui/user/favorite.dart';
import 'package:guitercord/model/singer.dart';

class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final List<Singer> singers;
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.singers,
    this.currentRoute = '/home',
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
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
            _buildProfileHeader(isDarkMode, user),
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
                      Navigator.pop(context); // Drawer ကို အရင်ပိတ်ပါ

                      // လက်ရှိရောက်နေတဲ့ Page က Favorites ဖြစ်နေရင် ထပ်သွားစရာမလိုအောင် စစ်ပါ
                      if (currentRoute != '/favorites') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesPage(),
                          ),
                        );
                      }
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
                ],
              ),
            ),
            const Divider(indent: 20, endIndent: 20),
            const LogoutTile(),
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
            Text(
              "Version 1.0.0",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, dynamic user) {
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
              SizedBox(
                width: 150,
                child: Text(
                  user?.email ?? "Admin User",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis, // Adds the "..."
                  maxLines: 1, // Ensures it stays on one line
                  softWrap: false, // Prevents wrapping to a second line
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
