import 'package:flutter/material.dart';
import 'package:guitercord/favorites_manager.dart';
// Import your manager and model here
// import 'package:guitercord/favorites_manager.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // We use a local list to handle the UI state
  late List<String> favorites;

  @override
  void initState() {
    super.initState();
    favorites = FavoritesManager.getFavoriteSongs();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Library",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (favorites.isNotEmpty)
            TextButton(
              onPressed: () => _clearAll(),
              child: const Text(
                "Clear All",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: favorites.isEmpty
            ? _buildEmptyState(isDark)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final song = favorites[index];
                  // PRO: Swipe to remove
                  return Dismissible(
                    key: Key(song),
                    direction: DismissDirection.endToStart,
                    background: _buildDeleteBackground(),
                    onDismissed: (direction) => _removeFavorite(song),
                    child: _buildFavoriteTile(context, song, isDark),
                  );
                },
              ),
      ),
    );
  }

  void _removeFavorite(String song) {
    setState(() {
      FavoritesManager.toggle(song);
      favorites = FavoritesManager.getFavoriteSongs();
    });
  }

  void _clearAll() {
    setState(() {
      FavoritesManager.clearAll();
      favorites = [];
    });
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }

  Widget _buildFavoriteTile(BuildContext context, String title, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        onTap: () {
          // Navigate to ChordViewScreen here
        },
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: const Icon(
            Icons.music_note_rounded,
            color: Colors.blueAccent,
            size: 20,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text(
          "Chords available",
          style: TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  // Use the empty state from your original code here...
}

// --- UI: What to show if no favorites yet ---
Widget _buildEmptyState(bool isDark) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite_border_rounded,
          size: 100,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        const SizedBox(height: 20),
        const Text(
          "Your stage is empty!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Songs you heart will appear here.",
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}
