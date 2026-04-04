import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:guitercord/model/artist.dart';
import 'package:guitercord/user/all_artist.dart';
import 'package:guitercord/user/cord.dart';
import 'package:guitercord/user/detail.dart';
import 'package:guitercord/user/drawer.dart';
import 'package:guitercord/user/search.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _searchQuery = "";

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

          // --- SECTION 1: POPULAR ARTISTS ---
          _buildSectionHeader(
            "Popular Artists",
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AllArtistsPage(isDarkMode: widget.isDarkMode),
              ),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('singers')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: _buildHorizontalShimmer());
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
                return const SliverToBoxAdapter(
                  child: _EmptyContentCard(label: "No Artists available yet"),
                );
              }

              return SliverToBoxAdapter(
                child: _buildArtistsHorizontalList(singers),
              );
            },
          ),

          // --- SECTION 2: TRENDING NOW ---
          _buildSectionHeader("Trending Now"),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('singers')
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
                return const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _EmptyContentCard(label: "No trending chords found"),
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
                    final singer = singers[index % singers.length];
                    final songName = singer.popularSongs.isNotEmpty
                        ? singer.popularSongs[index %
                              singer.popularSongs.length]
                        : "New Release";

                    return _TrendingCard(songName: songName, singer: singer);
                  }, childCount: singers.length < 8 ? singers.length : 8),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- SHIMMER / LOADING UI ---

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

  // --- UI COMPONENTS ---

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
        itemBuilder: (context, index) => _SingerCard(singer: filtered[index]),
      ),
    );
  }
}

// --- SMALL EMPTY STATE COMPONENT ---
class _EmptyContentCard extends StatelessWidget {
  final String label;
  const _EmptyContentCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note_rounded, color: Colors.grey, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your existing _TrendingCard, _SingerCard, and _PressedWrapper classes below...
class _TrendingCard extends StatelessWidget {
  final String songName;
  final Singer singer;
  const _TrendingCard({required this.songName, required this.singer});

  @override
  Widget build(BuildContext context) {
    return _PressedWrapper(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChordViewScreen(songName: songName, singer: singer),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      singer.accentColor.withOpacity(0.8),
                      const Color(0xFF1E1E26),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const Spacer(),
                    Text(
                      songName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      singer.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SingerCard extends StatelessWidget {
  final Singer singer;
  const _SingerCard({required this.singer});

  @override
  Widget build(BuildContext context) {
    return _PressedWrapper(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailScreen(singer: singer)),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 165,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      singer.accentColor,
                      Color.lerp(singer.accentColor, Colors.black, 0.2)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: singer.accentColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -25,
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: "hero-${singer.name}",
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: CachedNetworkImageProvider(
                        singer.imageUrl,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 14,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          singer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.verified,
                        color: Colors.blueAccent,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    singer.genre.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

class _PressedWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressedWrapper({required this.child, required this.onTap});

  @override
  State<_PressedWrapper> createState() => _PressedWrapperState();
}

class _PressedWrapperState extends State<_PressedWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
