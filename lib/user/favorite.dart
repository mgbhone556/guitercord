import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/user/favorites_manager.dart';
import 'package:guitercord/user/song_tile.dart';
import 'package:guitercord/util/empty_state.dart';
import 'package:guitercord/model/artist.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // These are the names saved locally (e.g., using Shared Preferences)
    final List<String> favoriteSongNames = FavoritesManager.getFavoriteSongs();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Library",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
      ),
      body: favoriteSongNames.isEmpty
          ? EmptyState(isDark: isDark, icon: Icons.favorite)
          : FutureBuilder<QuerySnapshot>(
              // Fetch all singers from Firestore to match the song names
              future: FirebaseFirestore.instance.collection('singers').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return EmptyState(isDark: isDark, icon: Icons.favorite);
                }

                // Convert Firestore docs into our Singer model objects
                final allSingers = snapshot.data!.docs.map((doc) {
                  return Singer.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteSongNames.length,
                  itemBuilder: (context, index) {
                    final songName = favoriteSongNames[index];

                    // Match the local song name to a Singer in the database
                    Singer? foundSinger;
                    try {
                      foundSinger = allSingers.firstWhere(
                        (s) => s.popularSongs.contains(songName),
                      );
                    } catch (e) {
                      foundSinger = null;
                    }

                    if (foundSinger == null) return const SizedBox.shrink();

                    return SongTile(
                      song: songName,
                      singer: foundSinger,
                      onReturn: _refresh,
                    );
                  },
                );
              },
            ),
    );
  }
}
