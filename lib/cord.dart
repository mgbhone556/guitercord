import 'package:flutter/material.dart';
import 'package:guitercord/favorites_manager.dart';
import 'package:guitercord/model.dart';

class ChordViewScreen extends StatefulWidget {
  // Changed to Stateful
  final String songName;
  final Singer singer;

  const ChordViewScreen({
    super.key,
    required this.songName,
    required this.singer,
  });

  @override
  State<ChordViewScreen> createState() => _ChordViewScreenState();
}

class _ChordViewScreenState extends State<ChordViewScreen> {
  late bool isFavorited; // Internal state for this song
  @override
  void initState() {
    super.initState();
    // 2. Check the real status from the Manager immediately
    isFavorited = FavoritesManager.getFavoriteSongs().contains(widget.songName);
  }

  void _toggleFavorite() {
    setState(() {
      // 3. Toggle the logic
      FavoritesManager.toggle(widget.songName);
      // 4. Update the local bool to match the new state
      isFavorited = !isFavorited;
    });
    // Pro Tip: Add a SnackBar with an action
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorited ? "Added to Favorites" : "Removed from Favorites",
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () => setState(() => isFavorited = !isFavorited),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.songName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.singer.name,
              style: TextStyle(fontSize: 13, color: widget.singer.accentColor),
            ),
          ],
        ),
        actions: [
          // --- FAVORITE BUTTON ---
          IconButton(
            onPressed: _toggleFavorite,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isFavorited
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey<bool>(isFavorited),
                color: isFavorited ? Colors.redAccent : null,
              ),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chords Used",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: ["G", "Em", "C", "D"]
                  .map(
                    (chord) => _buildChordBox(chord, widget.singer.accentColor),
                  )
                  .toList(),
            ),
            const Divider(height: 40),

            // ... rest of your body remains the same (use widget.singer.accentColor)

            // Helper widgets (_buildChordBox, _buildLyricLine) go here...
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lyrics & Chords",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.transform_sharp, size: 18),
                  label: const Text("Transpose"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildLyricLine("G", "I'm heading out to the ", "Em", "west coast"),
            _buildLyricLine("C", "Where the sun meets the ", "D", "ocean blue"),

            const SizedBox(height: 30),
            Center(
              child: Text(
                "Enjoying the chords? Support ${widget.singer.name} by following!",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChordBox(String name, Color color) {
    return Container(
      width: 60,
      height: 70,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Icon(Icons.grid_on, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLyricLine(String c1, String text1, String c2, String text2) {
    const chordStyle = TextStyle(
      color: Colors.blueAccent,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    const textStyle = TextStyle(fontSize: 17, height: 2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(c1, style: chordStyle),
              const SizedBox(width: 80),
              Text(c2, style: chordStyle),
            ],
          ),
          Text(text1 + text2, style: textStyle),
        ],
      ),
    );
  }
}
