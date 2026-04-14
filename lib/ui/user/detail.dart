// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/core/empty_state.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/ui/user/cord.dart';

class DetailScreen extends StatelessWidget {
  final Singer singer;
  final String heroTag;
  final String song;

  const DetailScreen({
    super.key,
    required this.singer,
    required this.heroTag,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: const BackButton(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Singer Image Header ---
            Stack(
              children: [
                Hero(
                  tag: heroTag,
                  child: SizedBox(
                    height: 420,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: singer.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[900],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 420,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    singer.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    singer.genre,
                    style: TextStyle(
                      fontSize: 18,
                      color: singer.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    "Biography",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    singer.bio.isNotEmpty
                        ? singer.bio
                        : "No biography available.",
                    style: TextStyle(
                      fontSize: 15.5,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 35),
                  const Text(
                    "Popular Songs",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('artists')
                        .doc(singer.id)
                        .collection('cords')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: EmptyState(
                            isDark: false,
                            icon: Icons.music_note,
                            title: "No songs found",
                            subtitle: "This artist doesn't have any songs yet.",
                          ),
                        );
                      }

                      final songDocs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: songDocs.length,
                        itemBuilder: (context, index) {
                          final data =
                              songDocs[index].data() as Map<String, dynamic>;
                          final currentSong = Song.fromMap(
                            data,
                            songDocs[index].id,
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            color: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: singer.accentColor.withOpacity(
                                  0.2,
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  color: singer.accentColor,
                                ),
                              ),
                              title: Text(
                                currentSong.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                "Chords: ${currentSong.chordsUsed.join(', ')}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChordViewScreen(
                                      songName: currentSong.title,
                                      singer: singer,
                                      lyricsData: currentSong.lyricsWithChords,
                                      chordsUsed: currentSong.chordsUsed,
                                      songData: '',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
