import 'package:flutter/material.dart';
import 'package:guitercord/ui/admin/admin_drawer.dart';
import 'package:guitercord/ui/admin/created_artist_list.dart';
import 'overview_screen.dart';
import 'create_artist_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  Widget _getPage() {
    switch (selectedIndex) {
      case 0:
        return const OverviewScreen();
      case 2:
        return const CreateArtistPage();
      case 3:
        return const CreatedArtistList();
      default:
        return const OverviewScreen();
    }
  }

  void _onTabSelected(int index) {
    print("DEBUG: Tab selected: $index");
    setState(() {
      selectedIndex = index;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(
        selectedIndex: selectedIndex,
        onTabSelected: _onTabSelected,
      ),
      appBar: AppBar(title: const Text("Admin Panel")),
      body: _getPage(),
    );
  }
}
