import 'package:flutter/material.dart';
import 'package:guitercord/user/favorite.dart';
import 'package:guitercord/user/model.dart';

class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final List<Singer> singers;

  const AppDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.singers,
  });

  @override
  Widget build(BuildContext context) {
    // Custom colors for a premium feel
    final primaryColor = isDarkMode
        ? const Color(0xFFBB86FC)
        : const Color(0xFF6200EE);
    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final surfaceColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);

    return Drawer(
      backgroundColor: bgColor,
      // Rounded edges on the right side for a modern look
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // --- 1. PRO PROFILE HEADER ---
            _buildProfileHeader(isDarkMode),

            const SizedBox(height: 20),

            // --- 2. MENU ITEMS ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _DrawerTile(
                      icon: Icons.home_rounded,
                      title: "Discover",
                      isSelected: true, // Example state
                      onTap: () => Navigator.pop(context),
                    ),
                    _DrawerTile(
                      icon: Icons.favorite_rounded,
                      title: "My Favorites",
                      onTap: () {
                        Navigator.pop(context); // Close drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritesPage(),
                          ),
                        );
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.playlist_play_rounded,
                      title: "Collections",
                      onTap: () {},
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(indent: 12, endIndent: 12),
                    ),
                    _DrawerTile(
                      icon: Icons.settings_rounded,
                      title: "Settings",
                      onTap: () {
                        // Your navigation logic here
                      },
                    ),
                  ],
                ),
              ),
            ),

            // --- 3. BOTTOM UTILITY SECTION ---
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    isDarkMode
                        ? Icons.nightlight_round
                        : Icons.wb_sunny_rounded,
                    color: isDarkMode ? Colors.amber : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Night Mode",
                    style: TextStyle(fontWeight: FontWeight.w600),
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
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=a042581f4e29026704d',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Alex Rivera",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  "Premium Member",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueAccent.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM REUSABLE TILE ─────────────────────────────────
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.blueAccent : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected
            ? Colors.blueAccent.withValues(alpha: 0.1)
            : Colors.transparent,
        leading: Icon(icon, color: color, size: 26),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blueAccent : null,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
