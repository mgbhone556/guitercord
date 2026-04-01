// ── Home Screen ─────────────────────────────────
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guitercord/detail.dart';
import 'package:guitercord/model.dart';

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
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredSingers = singers
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _buildPopularArtistsHeader(),

          // 1. ARTISTS SECTION (ဒီကောင်က အပေါ်ဆုံးအလွှာ ဖြစ်ပါမယ်)
          _buildArtistsSection(filteredSingers),

          // 2. TRENDING SHEET (ဒါက အနောက်ကနေ ကပ်ပါလာမယ့် Sheet အကြီးကြီးပါ)
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none, // အပြင်ဘက်ကို ထွက်ခွင့်ပေးဖို့
              children: [
                // ဒီ Container က Artist Card တွေရဲ့ အနောက်ကို -60 လောက်အထိ တိုးဝင်သွားမှာပါ
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? const Color(0xFF0A0A0F)
                          : const Color(0xFFF8F9FA),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            widget.isDarkMode ? 0.4 : 0.08,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, -15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grabber Handle
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: widget.isDarkMode
                                  ? Colors.white10
                                  : Colors.black12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // TRENDING HEADER
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 25, 24, 15),
                          child: Text(
                            "Trending Now",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        // TRENDING GRID
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 60),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 18,
                                  crossAxisSpacing: 18,
                                  childAspectRatio: 1.05,
                                ),
                            itemCount: 8,
                            itemBuilder: (context, i) => const _TrendingCard(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: widget.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      title: Text(
        "Chordly",
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.isDarkMode
                    ? const Color(0xFF0A0A0F)
                    : const Color(0xFFF8F9FA),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: IconButton(
            onPressed: widget.onThemeToggle,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            style: IconButton.styleFrom(
              backgroundColor: widget.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.08),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _buildSearchBar(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF18161F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          hintText: "Search artists or songs...",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
    );
  }

  Widget _buildPopularArtistsHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Text(
          "Popular Artists",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildTrendingHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
        child: Text(
          "Trending Now",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildArtistsSection(List<Singer> filtered) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 235,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 24),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(singer: filtered[index]),
              ),
            ),
            child: _SingerCard(singer: filtered[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.08,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => const _TrendingCard(),
          childCount: 8,
        ),
      ),
    );
  }
}

// ── Modern Singer Card ─────────────────────────────────
class _SingerCard extends StatelessWidget {
  final Singer singer;
  const _SingerCard({required this.singer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 165,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  singer.accentColor.withOpacity(0.9),
                  singer.accentColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: singer.accentColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  singer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  singer.genre,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 14,
            child: Hero(
              tag: "hero-${singer.name}",
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: singer.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const CircularProgressIndicator(strokeWidth: 3),
                    errorWidget: (_, __, ___) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trending Card ─────────────────────────────────
class _TrendingCard extends StatelessWidget {
  const _TrendingCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B46C0), Color(0xFF9F7AEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const Positioned(
              top: 14,
              right: 14,
              child: Icon(
                Icons.whatshot_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const Positioned(
              bottom: 18,
              left: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Blinding Lights",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "The Weeknd",
                    style: TextStyle(color: Colors.white70, fontSize: 13.5),
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
