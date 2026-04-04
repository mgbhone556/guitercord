import 'package:flutter/material.dart';
import 'package:guitercord/admin/singer_service.dart';
import 'package:guitercord/auth/service.dart';
import 'package:guitercord/model/artist.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final SingerService _service = SingerService();

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.dashboard_rounded, 'label': 'Overview'},
    {'icon': Icons.music_note_rounded, 'label': 'Manage Chords'},
    {'icon': Icons.person_search_rounded, 'label': 'Artists'},
    {'icon': Icons.people_alt_rounded, 'label': 'User Management'},
    {'icon': Icons.settings_rounded, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      drawer: isLargeScreen ? null : _buildDrawer(theme),
      appBar: AppBar(
        title: const Text(
          "Guitercord Admin Panel",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Only show FAB if we are on the "Artists" tab
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () => _showArtistDialog(context),
              label: const Text("Add Artist"),
              icon: const Icon(Icons.person_add_alt_1_rounded),
            )
          : null,
      body: Row(
        children: [
          if (isLargeScreen)
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  right: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: _buildDrawerContent(theme),
            ),
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

  // Swaps content based on selection
  Widget _buildMainContent(ThemeData theme) {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview(theme);
      case 2:
        return _buildSingerManager();
      default:
        return Center(
          child: Text(
            "${_navItems[_selectedIndex]['label']} coming soon...",
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
        );
    }
  }

  // --- TAB 1: OVERVIEW ---
  Widget _buildOverview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, Admin",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                "Total Chords",
                "1,240",
                Icons.music_note,
                Colors.blue,
              ),
              _buildStatCard("Active Users", "856", Icons.people, Colors.green),
              _buildStatCard(
                "Pending Reviews",
                "12",
                Icons.rate_review,
                Colors.orange,
              ),
              _buildStatCard("App Crashes", "0", Icons.bug_report, Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: ARTIST MANAGER ---
  Widget _buildSingerManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Manage Artists",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<Singer>>(
            stream: _service.getSingers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Center(child: Text("No artists found."));

              final singers = snapshot.data!;
              return ListView.builder(
                itemCount: singers.length,
                itemBuilder: (context, index) {
                  final singer = singers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(singer.imageUrl),
                      ),
                      title: Text(
                        singer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(singer.genre),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () =>
                                _showArtistDialog(context, singer: singer),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmDelete(context, singer),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- DIALOGS & UI HELPERS ---
  void _showArtistDialog(BuildContext context, {Singer? singer}) {
    final nameCtrl = TextEditingController(text: singer?.name);
    final genreCtrl = TextEditingController(text: singer?.genre);
    final imgCtrl = TextEditingController(text: singer?.imageUrl);
    final bioCtrl = TextEditingController(text: singer?.bio);

    // Handling Color as Hex String for the controller
    final colorCtrl = TextEditingController(
      text: singer != null
          ? '#${singer.accentColor.value.toRadixString(16).padLeft(8, '0').substring(2)}'
          : '#4776E6',
    );

    List<String> currentSongs = singer?.popularSongs ?? [];
    List<String> currentAlbums = singer?.albums ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  singer == null ? "New Artist" : "Edit Artist",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _ProTextField(
                        controller: nameCtrl,
                        label: "Name",
                        icon: Icons.person,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ProTextField(
                        controller: genreCtrl,
                        label: "Genre",
                        icon: Icons.music_note,
                      ),
                    ),
                  ],
                ),

                _ProTextField(
                  controller: imgCtrl,
                  label: "Image URL",
                  icon: Icons.link,
                ),

                // Color Input
                _ProTextField(
                  controller: colorCtrl,
                  label: "Accent Color (Hex)",
                  icon: Icons.color_lens,
                ),

                _ProTextField(
                  controller: bioCtrl,
                  label: "Biography",
                  icon: Icons.description,
                  maxLines: 3,
                ),

                const Divider(),

                // Dynamic List Inputs for Songs and Albums
                _ProListInput(
                  label: "Popular Songs",
                  initialItems: currentSongs,
                  onChanged: (val) => currentSongs = val,
                ),

                _ProListInput(
                  label: "Albums",
                  initialItems: currentAlbums,
                  onChanged: (val) => currentAlbums = val,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Parsing hex color safely
                        int colorInt = int.parse(
                          colorCtrl.text.replaceFirst('#', '0xff'),
                        );

                        final newSinger = Singer(
                          id: singer?.id,
                          name: nameCtrl.text,
                          genre: genreCtrl.text,
                          imageUrl: imgCtrl.text,
                          bio: bioCtrl.text,
                          accentColor: Color(colorInt),
                          popularSongs: currentSongs,
                          albums: currentAlbums,
                        );

                        if (singer == null) {
                          _service.addSinger(newSinger);
                        } else {
                          _service.updateSinger(newSinger);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("Save Artist"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Singer singer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Artist?"),
        content: Text("Are you sure you want to remove ${singer.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _service.deleteSinger(singer.id!);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) =>
      Drawer(child: _buildDrawerContent(theme));

  Widget _buildDrawerContent(ThemeData theme) {
    return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1)),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _navItems.length,
            itemBuilder: (context, index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;
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
                selectedTileColor: theme.primaryColor.withOpacity(0.05),
                onTap: () {
                  setState(() => _selectedIndex = index);
                  if (MediaQuery.of(context).size.width <= 900)
                    Navigator.pop(context);
                },
              );
            },
          ),
        ),
        // --- LOGOUT SECTION ---
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          title: const Text(
            "Logout",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            // Confirm logout before proceeding
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
                    child: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await AuthService().signOut();
            }
          },
        ),
        const SizedBox(height: 16), // Padding at the bottom
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Text Field for standard strings
class _ProTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  const _ProTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}

// Custom Chip Input for Lists (Songs/Albums)
class _ProListInput extends StatefulWidget {
  final String label;
  final List<String> initialItems;
  final Function(List<String>) onChanged;

  const _ProListInput({
    required this.label,
    required this.initialItems,
    required this.onChanged,
  });

  @override
  State<_ProListInput> createState() => _ProListInputState();
}

class _ProListInputState extends State<_ProListInput> {
  late List<String> items;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    items = List.from(widget.initialItems);
  }

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        items.add(_controller.text);
        _controller.clear();
        widget.onChanged(items);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items
              .map(
                (item) => Chip(
                  label: Text(item, style: const TextStyle(fontSize: 12)),
                  onDeleted: () => setState(() {
                    items.remove(item);
                    widget.onChanged(items);
                  }),
                ),
              )
              .toList(),
        ),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "Add ${widget.label}...",
            suffixIcon: IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ),
          onSubmitted: (_) => _addItem(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
