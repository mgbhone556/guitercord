import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import 'package:flutter/material.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/ui/user/detail.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/core/empty_state.dart';

class AllArtistsPage extends StatelessWidget {
  final bool isDarkMode;

  const AllArtistsPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "All Artists",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // --- PRO CRUD: Real-time Stream from Firestore ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('singers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return EmptyState(isDark: isDarkMode, icon: Icons.music_note);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: data.length, // Dynamic count from DB
            itemBuilder: (context, index) {
              // Convert Firestore Map to Singer Object
              final singer = Singer.fromMap(
                data[index].data() as Map<String, dynamic>,
                data[index].id,
              );

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      singer: singer,

                      heroTag: "popular-hero-${singer.name}",
                    ),
                  ),
                ),
                child: _CompactSingerCard(
                  singer: singer,
                  isDarkMode: isDarkMode,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// See All Screen အတွက် သီးသန့် Card Design အသေးလေး
class _CompactSingerCard extends StatelessWidget {
  final Singer singer;
  final bool isDarkMode;

  const _CompactSingerCard({required this.singer, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF18161F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag:
                "hero-all-${singer.name}", // Hero tag ကို duplicate မဖြစ်အောင် rename ပေးထားတယ်
            child: CircleAvatar(
              radius: 45,
              backgroundColor: singer.accentColor.withOpacity(0.2),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: singer.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            singer.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            singer.genre,
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
