import 'package:flutter/material.dart';
import 'package:guitercord/user/favorites_manager.dart';
import 'package:guitercord/user/song_tile.dart';
import 'package:guitercord/util/empty_state.dart';
import 'package:guitercord/user/model.dart'; // Import your singers list

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Helper to refresh the UI
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final List<String> favoriteSongNames = FavoritesManager.getFavoriteSongs();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Library",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: favoriteSongNames.isEmpty
          ? EmptyState(isDark: isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSongNames.length,
              itemBuilder: (context, index) {
                final songName = favoriteSongNames[index];

                // FIND THE DATA: Search through your 'singers' list
                // to find the singer who owns this song.
                Singer? foundSinger;
                try {
                  foundSinger = singers.firstWhere(
                    (s) => s.popularSongs.contains(songName),
                  );
                } catch (e) {
                  foundSinger = null;
                }

                if (foundSinger == null) return const SizedBox.shrink();

                return SongTile(
                  song: songName,
                  singer: foundSinger,
                  onReturn: _refresh, // This re-runs build when coming back
                );
              },
            ),
    );
  }
}
