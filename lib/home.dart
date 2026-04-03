// ── Home Screen ─────────────────────────────────
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/artist.dart';
import 'package:guitercord/detail.dart';
import 'package:guitercord/drawer.dart';
import 'package:guitercord/model.dart';
import 'package:guitercord/search.dart';

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
    // Pro tip: Compute filtered lists outside the build method logic if possible
    final filteredSingers = singers
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      drawer: AppDrawer(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        singers: [],
      ),
      // Use a Scaffold background that matches your "Modern" container
      backgroundColor: widget.isDarkMode
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),

          // Section 1: Popular Artists Header
          _buildSectionHeader(
            "Popular Artists",
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllArtistsPage(isDarkMode: widget.isDarkMode),
                ),
              );
            },
          ),

          // Section 2: Horizontal Artists List
          SliverToBoxAdapter(
            child: _buildArtistsHorizontalList(filteredSingers),
          ),

          // Section 3: Trending Header
          _buildSectionHeader("Trending Now"),

          // Section 4: The Grid (No longer nested in a Container for better performance)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85, // Adjusted for better card height
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => const _TrendingCard(),
                childCount: 8,
              ),
            ),
          ),

          // Bottom padding for the scroll view
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        "Discover",
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
      ),
      backgroundColor: widget.isDarkMode
          ? const Color(0xFF0A0A0F).withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      // Pro: Add blur to the pinned app bar
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
      // 1. Ensure the total height covers the card (155) + the pop (-25) + padding
      height: 220,
      child: ListView.builder(
        // 2. CRITICAL: This allows the Avatar to bleed outside the ListView's box
        clipBehavior: Clip.none,
        // 3. IMPORTANT: Add top padding so the head has 'breathing room'
        // within the 220 height.
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 35, // Room for the head
          bottom: 10, // Room for the shadow
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _SingerCard(singer: filtered[index]),
      ),
    );
  }
}

// ── Improved Trending Card ─────────────────────────────────
class _TrendingCard extends StatelessWidget {
  const _TrendingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Pro Tip: Multiple shadows for "soft" look
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
            // Pro: Use a placeholder image or gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E1E26), Color(0xFF2C2C38)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Content
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
                  const Text(
                    "Blinding Lights",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "The Weeknd",
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
    );
  }
}

class _SingerCard extends StatelessWidget {
  final Singer singer;
  const _SingerCard({required this.singer});

  @override
  Widget build(BuildContext context) {
    return _PressedWrapper(
      onTap: () {
        Feedback.forTap(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(singer: singer)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(
          right: 20,
          top: 35,
        ), // Space for the Avatar "Pop"
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. THE MAIN BODY
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 165, // Fixed height for consistency
                    width: double.infinity,
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

                // 2. THE AVATAR (Positioned relative to card top)
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

                // 3. TEXT INFO (Moved up slightly & Overflow Protected)
                Positioned(
                  // 'bottom: 35' moves the text up away from the very bottom edge
                  bottom: 20,
                  left: 14,
                  right: 14,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NAME + VERIFIED ROW
                      Row(
                        children: [
                          Expanded(
                            child: Opacity(
                              opacity: 0.9,
                              child: Text(
                                singer.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // GENRE + BADGE ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Opacity(
                              opacity: 0.8,
                              child: Text(
                                singer.genre.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "24 Songs",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── PRO FEATURE: BOUNCE ANIMATION ──────────────────────────────
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
