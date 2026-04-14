import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  // Mock data for History - In a real app, load this from SharedPreferences
  List<String> _recentSearches = [
    "The Weeknd",
    "Post Malone",
    "Blinding Lights",
    "Taylor Swift",
  ];

  // Popular Genres/Categories
  final List<Map<String, dynamic>> _categories = [
    {"name": "Pop", "color": Colors.pinkAccent},
    {"name": "Rock", "color": Colors.deepPurpleAccent},
    {"name": "Hip-Hop", "color": Colors.orangeAccent},
    {"name": "Jazz", "color": Colors.teal},
    {"name": "Country", "color": Colors.blueAccent},
    {"name": "Classical", "color": Colors.brown},
  ];

  void _removeHistoryItem(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  void _clearAllHistory() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: "Artists, songs, or lyrics",
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => _controller.clear(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- Section 1: Recent Searches ---
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader(
              "Recent Searches",
              onAction: _clearAllHistory,
              actionText: "Clear All",
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildHistoryTile(_recentSearches[index], index),
                childCount: _recentSearches.length,
              ),
            ),
          ],

          // --- Section 2: Trending / Browse All ---
          _buildSectionHeader("Browse All"),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCategoryCard(_categories[index]),
                childCount: _categories.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onAction,
    String? actionText,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            if (onAction != null)
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionText!,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String text, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: const Icon(Icons.history_rounded, color: Colors.grey, size: 22),
      title: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
        onPressed: () => _removeHistoryItem(index),
      ),
      onTap: () {
        _controller.text = text;
        // Logic to trigger search
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        color: category['color'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (category['color'] as Color).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -10,
            right: -10,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.music_note_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              category['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
