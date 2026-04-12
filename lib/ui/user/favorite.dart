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

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final List<String> favoriteNames = FavoritesManager.getFavoriteSongs()
        .map((e) => e.trim().toLowerCase())
        .toList();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final favoriteDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String title = (data['title'] ?? "")
                      .toString()
                      .trim()
                      .toLowerCase();
                  return favoriteNames.contains(title);
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

                    String singerId = "";
                    try {
                      singerId = doc.reference.parent.parent!.id;
                    } catch (e) {
                      singerId = "unknown";
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('artists')
                          .doc(singerId)
                          .get(),
                      builder: (context, singerSnap) {
                        String nameOfSinger = "Loading...";
                        Color colorOfSinger = Colors.blueGrey;
                        Singer? loadedSinger;

                        if (singerSnap.hasData && singerSnap.data!.exists) {
                          loadedSinger = Singer.fromMap(
                            singerSnap.data!.data() as Map<String, dynamic>,
                            singerSnap.data!.id,
                          );
                          nameOfSinger = loadedSinger.name;
                          colorOfSinger = loadedSinger.accentColor;
                        }
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            onTap: () async {
                              debugPrint("==== FAVORITE CLICKED ====");
                              debugPrint("Song: ${song.title}");
                              debugPrint("SingerId: $singerId");

                              try {
                                final singerDoc = await FirebaseFirestore
                                    .instance
                                    .collection("singers")
                                    .doc(singerId)
                                    .get();

                                if (!singerDoc.exists) {
                                  debugPrint("❌ Singer document not found!");
                                  return;
                                }

                                final singer = Singer.fromMap(
                                  singerDoc.data() as Map<String, dynamic>,
                                  singerDoc.id,
                                );

                                debugPrint("✅ Singer Loaded: ${singer.name}");
                                debugPrint("✅ Navigating to chord page...");

                                Navigator.push(
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
                              } catch (e) {
                                debugPrint("❌ ERROR loading singer: $e");
                              }
                            },

                            leading: CircleAvatar(
                              child: const Icon(Icons.music_note),
                            ),
                            title: Text(song.title),
                            subtitle: const Text("Tap to open chords"),
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
