import 'package:flutter/material.dart';
import 'package:guitercord/admin/drawer.dart';
import 'package:guitercord/admin/nav_item.dart';
import 'package:guitercord/admin/overview.dart';
import 'package:guitercord/admin/artists.dart';
import 'package:guitercord/admin/singer_service.dart';
import 'package:guitercord/model/artist.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final SingerService _service = SingerService();

  // Handle Tab Switching
  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isLargeScreen = size.width > 900;

    return Scaffold(
      // Drawer only for mobile/tablet
      drawer: isLargeScreen ? null : _buildGlobalDrawer(),

      appBar: AppBar(
        title: const Text(
          "Guitercord Admin Panel",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: _buildFab(),

      body: Row(
        children: [
          // Sidebar for Desktop
          if (isLargeScreen) _buildSidebar(theme),

          // Main Content Area
          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.5),
              padding: const EdgeInsets.all(24),
              child: _buildMainContent(theme),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildGlobalDrawer() {
    return AdminDrawer(
      selectedIndex: _selectedIndex,
      navItems: AdminNavConfig.navItems,
      onTabSelected: (index) {
        _onTabChanged(index);
        Navigator.pop(context); // Close drawer on mobile after selection
      },
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: AdminDrawer(
        selectedIndex: _selectedIndex,
        navItems: AdminNavConfig.navItems,
        onTabSelected: _onTabChanged,
      ),
    );
  }

  Widget? _buildFab() {
    // Only show FAB on Artists Tab (Index 2)
    if (_selectedIndex != 2) return null;

    return FloatingActionButton.extended(
      onPressed: () => SingerManagerTab.showArtistDialog(context, _service),
      label: const Text("Add Artist"),
      icon: const Icon(Icons.person_add_alt_1_rounded),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    final navLabel = AdminNavConfig.navItems[_selectedIndex]['label'];

    switch (_selectedIndex) {
      case 0:
        return const OverviewTab();
      case 2:
        return SingerManagerTab(
          service: _service,
          onEdit: (singer) => SingerManagerTab.showArtistDialog(
            context,
            _service,
            singer: singer,
          ),
          onDelete: (singer) => _showDeleteConfirmation(singer),
        );
      default:
        return Center(
          child: Text(
            "$navLabel coming soon...",
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
        );
    }
  }

  // Helper to show the dialog
  void _showDeleteConfirmation(Singer singer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Artist"),
        content: Text("Are you sure you want to delete ${singer.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _service.deleteSinger(singer.id!);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
