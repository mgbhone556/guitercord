// ── Detail Screen ─────────────────────────────────
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/model/artist.dart';
import 'package:guitercord/user/song_tile.dart';

class DetailScreen extends StatelessWidget {
  final Singer singer;
  final String heroTag;
  const DetailScreen({super.key, required this.singer, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: "hero-${singer.id}",
                  child: SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: singer.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[900],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.error, size: 80),
                    ),
                  ),
                ),
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    singer.name,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    singer.genre,
                    style: TextStyle(fontSize: 18.5, color: singer.accentColor),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Biography",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    singer.bio,
                    style: const TextStyle(fontSize: 16.2, height: 1.65),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Popular Songs",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  ...singer.popularSongs.map(
                    (song) => SongTile(song: song, singer: singer),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Albums",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: singer.albums
                        .map(
                          (album) => Chip(
                            label: Text(album),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            backgroundColor: singer.accentColor.withOpacity(
                              0.12,
                            ),
                            labelStyle: TextStyle(
                              color: singer.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Full chords library coming soon ✨",
                              ),
                            ),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: singer.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        "Browse All Chords",
                        style: TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
