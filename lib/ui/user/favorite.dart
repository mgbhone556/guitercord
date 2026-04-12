import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/provider/favorites_provider.dart';
import 'package:guitercord/core/empty_state.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/ui/user/cord.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}
// ... (imports remain the same)

class _FavoritesPageState extends State<FavoritesPage> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final List<String> favoriteNames = FavoritesManager.getFavoriteSongs();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // DEBUG: Check your console to see if this list is empty!
    debugPrint("Current Favorites in Manager: $favoriteNames");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Library",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
      ),
      body: favoriteNames.isEmpty
          ? EmptyState(isDark: isDark, icon: Icons.favorite)
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('songs')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text("Error: ${snapshot.error}"));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                // Robust filtering: compare trimmed and lowercase strings
                final favoriteDocs = snapshot.data!.docs.where((doc) {
                  final title =
                      doc['title']?.toString().trim().toLowerCase() ?? "";
                  return favoriteNames.any(
                    (fav) => fav.trim().toLowerCase() == title,
                  );
                }).toList();

                if (favoriteDocs.isEmpty) {
                  return EmptyState(isDark: isDark, icon: Icons.favorite);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteDocs.length,
                  itemBuilder: (context, index) {
                    final doc = favoriteDocs[index];
                    final song = Song.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('singers')
                          .doc(doc.reference.parent.parent!.id)
                          .get(),
                      builder: (context, singerSnap) {
                        if (!singerSnap.hasData)
                          return const SizedBox(height: 90);

                        final singerData =
                            singerSnap.data!.data() as Map<String, dynamic>?;
                        if (singerData == null) return const SizedBox();

                        final singer = Singer.fromMap(
                          singerData,
                          singerSnap.data!.id,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.music_note),
                            ),
                            title: Text(
                              song.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(singer.name),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChordViewScreen(
                                    songName: song.title,
                                    singer: singer,
                                    lyricsData: song.lyricsWithChords,
                                    chordsUsed: song.chordsUsed,
                                    songData: '',
                                  ),
                                ),
                              );
                              _refresh(); // Refresh when coming back in case they unfavorited it
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
