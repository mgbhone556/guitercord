import 'package:flutter/material.dart';
import 'package:guitercord/favorites_manager.dart';
// Import your manager and model here
// import 'package:guitercord/favorites_manager.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the list of names from your manager
    final List<String> favoriteSongs = FavoritesManager.getFavoriteSongs();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: favoriteSongs.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final songName = favoriteSongs[index];
                return _buildFavoriteTile(context, songName, isDark);
              },
            ),
    );
  }

  // --- UI: The List Item ---
  Widget _buildFavoriteTile(BuildContext context, String title, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.music_note_rounded, color: Colors.blueAccent),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: const Text("Tap to view chords"),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),
        onTap: () {
          // Navigate back to ChordViewScreen for this specific song
        },
      ),
    );
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
}
