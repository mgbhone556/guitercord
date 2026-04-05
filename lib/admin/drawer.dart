import 'package:flutter/material.dart';
import 'package:guitercord/auth/service.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<Map<String, dynamic>> navItems;
  final Function(int) onTabSelected;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.navItems,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        // Ensures content doesn't hit the status bar
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.library_music_rounded,
                      size: 40,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "GUITERCORD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: navItems.isEmpty
                  ? const Center(child: Text("No items"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: navItems.length,
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final isSelected = selectedIndex == index;

                        return ListTile(
                          leading: Icon(
                            item['icon'],
                            color: isSelected ? theme.primaryColor : null,
                          ),
                          title: Text(
                            item['label'],
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: theme.primaryColor.withOpacity(
                            0.05,
                          ),
                          onTap: () {
                            onTabSelected(index);
                            if (Scaffold.of(context).isDrawerOpen) {
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _handleLogout(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

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

    if (confirm == true) {
      await AuthService().signOut();
    }
  }
}
