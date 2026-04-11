import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/core/empty_state.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/widget/card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:guitercord/model/artist.dart';
import 'package:guitercord/ui/user/all_artist.dart';
import 'package:guitercord/ui/user/drawer.dart';
import 'package:guitercord/ui/user/search.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final Song song;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.song,
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

          // ... inside your _HomeScreenState build method

          // --- 1. Popular Artists Section ---
          StreamBuilder<QuerySnapshot>(
            // FIX: Changed 'singers' to 'artists' to match your Admin Panel
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

          // --- 2. Trending Now Section ---
          StreamBuilder<QuerySnapshot>(
            // FIX: Changed 'singers' to 'artists'
            stream: FirebaseFirestore.instance
                .collection('artists')
                .limit(8) // Limit trending to top 8
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildGridShimmer();
              }

              final singers =
                  snapshot.data?.docs
                      .map(
                        (doc) => Singer.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        ),
                      )
                      .toList() ??
                  [];

              if (singers.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: EmptyState(
                      isDark: widget.isDarkMode,
                      icon: Icons.music_note_rounded,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final singer = singers[index];
                    // Display the first popular song or a fallback
                    // final songName = singer.popularSongs.isNotEmpty
                    //     ? singer.popularSongs[0]
                    //     : "Top Track";

                    return TrendingCard(
                      song: Song(
                        id: null,
                        title: "",
                        chordsUsed: [],
                        lyricsWithChords: [],
                        albums: [],
                      ),
                      singer: singer,
                      songName: 'Top Track',
                    );
                  }, childCount: singers.length),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
          itemCount: 4,
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
}
