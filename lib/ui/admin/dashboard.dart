import 'package:flutter/material.dart';
import 'package:guitercord/ui/admin/drawer.dart';
import 'package:guitercord/ui/admin/artist_list.dart';
import 'overview.dart';
import 'artist_create.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int selectedIndex = 0;

  Widget _getPage() {
    switch (selectedIndex) {
      case 0:
        return const OverviewPage();
      case 2:
        return const ArtistPage();
      case 3:
        return const ManageArtistForSongPage();
      default:
        return const OverviewPage();
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
