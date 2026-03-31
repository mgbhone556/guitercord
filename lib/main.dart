import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ChordApp());
}

class ChordApp extends StatefulWidget {
  const ChordApp({super.key});
  @override
  State<ChordApp> createState() => _ChordAppState();
}

class _ChordAppState extends State<ChordApp> {
  bool isDarkMode = true;
  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? _darkTheme : _lightTheme,
      home: HomeScreen(onThemeToggle: toggleTheme, isDarkMode: isDarkMode),
    );
  }

  final ThemeData _darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0A0A0F),
    primaryColor: const Color(0xFF8E54E9),
    cardColor: const Color(0xFF18161F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  final ThemeData _lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    primaryColor: const Color(0xFF6200EE),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

// ── Singer Model ─────────────────────────────────────
class Singer {
  final String name;
  final String genre;
  final String imageUrl;
  final Color accentColor;
  final String bio;
  final List<String> popularSongs;
  final List<String> albums;

  const Singer({
    required this.name,
    required this.genre,
    required this.imageUrl,
    required this.accentColor,
    required this.bio,
    required this.popularSongs,
    required this.albums,
  });
}

// ── Home Screen ─────────────────────────────────
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

  static const List<Singer> singers = [
    Singer(
      name: "The Weeknd",
      genre: "R&B / Pop",
      imageUrl: "https://i.pravatar.cc/300?img=11",
      accentColor: Color(0xFF4776E6),
      bio:
          "Abel Makkonen Tesfaye, known as The Weeknd, is a Canadian singer, songwriter, and record producer known for his signature falsetto.",
      popularSongs: const [
        "Blinding Lights",
        "Starboy",
        "Save Your Tears",
        "Die For You",
        "Call Out My Name",
        "Heartless",
        "After Hours",
        "Take My Breath",
        "Sacrifice",
        "Creepin'",
      ],
      albums: const [
        "Dawn FM",
        "After Hours",
        "Starboy",
        "Beauty Behind the Madness",
        "My Dear Melancholy",
        "Kiss Land",
        "House of Balloons",
        "Thursday",
        "Echoes of Silence",
        "The Highlights",
      ],
    ),
    Singer(
      name: "Billie Eilish",
      genre: "Alt / Indie",
      imageUrl: "https://i.pravatar.cc/300?img=5",
      accentColor: Color(0xFF8E54E9),
      bio:
          "Billie Eilish is an American singer-songwriter known for her whispery vocals, dark pop, and emotionally honest songwriting.",
      popularSongs: const [
        "Bad Guy",
        "Birds of a Feather",
        "What Was I Made For?",
        "Lovely",
        "Ocean Eyes",
        "Happier Than Ever",
        "Therefore I Am",
        "Bury a Friend",
        "No Time To Die",
        "Lunch",
      ],
      albums: const [
        "Hit Me Hard and Soft",
        "When We All Fall Asleep...",
        "Happier Than Ever",
        "Don't Smile at Me",
        "GUTS",
        "SOUR",
        "Live at Third Man",
        "Guitar Songs",
        "Barbie",
        "The World Is Burning",
      ],
    ),
    Singer(
      name: "Harry Styles",
      genre: "Soft Rock / Pop",
      imageUrl: "https://i.pravatar.cc/300?img=12",
      accentColor: Color(0xFFF09819),
      bio:
          "Harry Edward Styles is an English singer, songwriter, and actor known for his bold fashion and genre-fluid music.",
      popularSongs: const [
        "As It Was",
        "Watermelon Sugar",
        "Late Night Talking",
        "Sign of the Times",
        "Adore You",
        "Falling",
        "Golden",
        "Kiwi",
        "Lights Up",
        "Music For a Sushi Restaurant",
      ],
      albums: const [
        "Harry's House",
        "Fine Line",
        "Harry Styles",
        "Eroda",
        "Treat People With Kindness",
        "Satellite",
        "Boyfriends",
        "Cinema",
        "One Direction",
        "Please Don't Let Me Go",
      ],
    ),
    Singer(
      name: "Taylor Swift",
      genre: "Pop / Country",
      imageUrl: "https://i.pravatar.cc/300?img=9",
      accentColor: Color(0xFFE94E77),
      bio:
          "Taylor Alison Swift is one of the most influential singer-songwriters of the 21st century, celebrated for her storytelling.",
      popularSongs: const [
        "Cruel Summer",
        "Anti-Hero",
        "Blank Space",
        "Shake It Off",
        "Fortnight",
        "Karma",
        "Lavender Haze",
        "Love Story",
        "You Belong With Me",
        "Cardigan",
      ],
      albums: const [
        "The Tortured Poets Department",
        "Midnights",
        "Folklore",
        "1989",
        "Reputation",
        "Lover",
        "Evermore",
        "Red",
        "Speak Now",
        "Fearless",
      ],
    ),
    Singer(
      name: "Drake",
      genre: "Hip-Hop / Rap",
      imageUrl: "https://i.pravatar.cc/300?img=47",
      accentColor: Color(0xFF1DB954),
      bio:
          "Aubrey Drake Graham is a Canadian rapper, singer, and actor. One of the most successful music artists globally.",
      popularSongs: const [
        "One Dance",
        "God's Plan",
        "Passionfruit",
        "Too Good",
        "Hotline Bling",
        "In My Feelings",
        "Nice For What",
        "Toosie Slide",
        "Laugh Now Cry Later",
        "Jimmy Cooks",
      ],
      albums: const [
        "For All the Dogs",
        "Views",
        "Scorpion",
        "Take Care",
        "Nothing Was the Same",
        "Certified Lover Boy",
        "Her Loss",
        "Honestly, Nevermind",
        "Dark Lane Demo Tapes",
        "If You're Reading This",
      ],
    ),
    Singer(
      name: "Olivia Rodrigo",
      genre: "Pop / Alt",
      imageUrl: "https://i.pravatar.cc/300?img=65",
      accentColor: Color(0xFFFF6B6B),
      bio:
          "Olivia Isabel Rodrigo is an American singer-songwriter and actress who gained massive fame with her emotional debut hits.",
      popularSongs: const [
        "drivers license",
        "vampire",
        "good 4 u",
        "deja vu",
        "traitor",
        "brutal",
        "favorite crime",
        "hope ur ok",
        "lacy",
        "get him back!",
      ],
      albums: const [
        "GUTS",
        "SOUR",
        "GUTS (Spilled)",
        "SOUR (Limited Edition)",
        "drivers license EP",
        "brutal",
        "deja vu",
        "good 4 u",
        "vampire",
        "Olivia Rodrigo Singles",
      ],
    ),
  ];

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
          _buildArtistsSection(filteredSingers),
          _buildTrendingHeader(),
          _buildTrendingSection(),
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
  const _SingerCard({super.key, required this.singer});

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
  const _TrendingCard({super.key});

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

// ── Detail Screen ─────────────────────────────────
class DetailScreen extends StatelessWidget {
  final Singer singer;
  const DetailScreen({super.key, required this.singer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: "hero-${singer.name}",
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
                    (song) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        leading: const Icon(
                          Icons.play_circle_filled_rounded,
                          color: Colors.deepPurple,
                          size: 32,
                        ),
                        title: Text(
                          song,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Text(
                          "4 Chords",
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Opening chords for $song")),
                        ),
                      ),
                    ),
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
