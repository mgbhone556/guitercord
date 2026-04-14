import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/core/empty_state.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/ui/user/cord.dart';
import 'package:guitercord/widget/card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/ui/user/all_artist.dart';
import 'package:guitercord/ui/user/drawer.dart';
import 'package:guitercord/ui/user/search.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final Song? song;
  final Singer? singer;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    this.song,
    this.singer,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        singers: [],
      ),
      backgroundColor: widget.isDarkMode
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),

          _buildSectionHeader(
            "Popular Artists",
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AllArtistsPage(isDarkMode: widget.isDarkMode),
              ),
            ),
          ),

          // --- 1. Popular Artists Section ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('artists')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: _buildHorizontalShimmer());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    isDark: false,
                    icon: Icons.people_outline_rounded,
                    title: "No artists found!",
                    subtitle: "Check back later for new artists.",
                  ),
                );
              }

              final singers = snapshot.data!.docs
                  .map(
                    (doc) => Singer.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList();

              return SliverToBoxAdapter(
                child: _buildArtistsHorizontalList(singers),
              );
            },
          ),

          _buildSectionHeader("Trending Now"),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('cords')
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildGridShimmer();
              }

              if (snapshot.hasError) {
                print(
                  "Firebase Error: ${snapshot.error}",
                ); // Error ကို console မှာ ကြည့်ရန်
                return SliverToBoxAdapter(
                  child: Center(child: Text("Error loading data")),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text("No trending songs yet.")),
                );
              }

              final songDocs = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final songData =
                        songDocs[index].data() as Map<String, dynamic>;
                    final song = Song.fromMap(songData, songDocs[index].id);

                    // Singer data ကို song ထဲက singerId နဲ့ ပြန်ရှာရပါမယ်
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('artists')
                          .doc(song.singerId)
                          .get(),
                      builder: (context, singerSnapshot) {
                        if (!singerSnapshot.hasData)
                          return _buildSingleShimmer();

                        final singer = Singer.fromMap(
                          singerSnapshot.data!.data() as Map<String, dynamic>,
                          singerSnapshot.data!.id,
                        );

                        return TrendingCard(
                          singer: singer,
                          songName: song.title,
                          song: song,
                          onTap: () {
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
                          },
                        );
                      },
                    );
                  }, childCount: songDocs.length),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- UI Methods (AppBar, Shimmers, etc.) ---

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      elevation: 0,
      title: const Text(
        "Discover",
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
      ),
      backgroundColor: widget.isDarkMode
          ? const Color(0xFF0A0A0F).withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          icon: const Icon(Icons.search_rounded),
          style: IconButton.styleFrom(
            backgroundColor: widget.isDarkMode
                ? Colors.white10
                : Colors.black12,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            if (onSeeAll != null)
              TextButton(onPressed: onSeeAll, child: const Text("See All")),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistsHorizontalList(List<Singer> filtered) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 35,
          bottom: 10,
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, index) => SingerCard(singer: filtered[index]),
      ),
    );
  }

  Widget _buildHorizontalShimmer() {
    return Shimmer.fromColors(
      baseColor: widget.isDarkMode ? Colors.white10 : Colors.grey[300]!,
      highlightColor: widget.isDarkMode ? Colors.white24 : Colors.grey[100]!,
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: 4,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 20, top: 35),
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: widget.isDarkMode ? Colors.white10 : Colors.grey[300]!,
            highlightColor: widget.isDarkMode
                ? Colors.white24
                : Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildSingleShimmer() {
    return Shimmer.fromColors(
      baseColor: widget.isDarkMode ? Colors.white10 : Colors.grey[300]!,
      highlightColor: widget.isDarkMode ? Colors.white24 : Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
