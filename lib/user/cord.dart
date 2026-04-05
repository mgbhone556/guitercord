import 'package:flutter/material.dart';
import 'package:guitercord/core/chord_parser.dart';
import 'package:guitercord/model/artist.dart';
import 'package:guitercord/provider/favorites_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChordViewScreen extends StatefulWidget {
  final String songName;
  final Singer singer;
  final String songData; // Pass the raw string like "[G] My [D] Song" here

  const ChordViewScreen({
    super.key,
    required this.songName,
    required this.singer,
    required this.songData,
  });

  @override
  State<ChordViewScreen> createState() => _ChordViewScreenState();
}

class _ChordViewScreenState extends State<ChordViewScreen> {
  late bool isFavorited;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    isFavorited = FavoritesManager.getFavoriteSongs().contains(widget.songName);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---
  void _shareSong(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset position = box.localToGlobal(Offset.zero);

    Share.share(
      "Check out ${widget.songName} chords on Guitercord!",
      sharePositionOrigin: position & box.size,
    );
  }

  void _toggleFavorite() {
    setState(() {
      FavoritesManager.toggle(widget.songName);
      isFavorited = !isFavorited;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorited ? "Added to Favorites" : "Removed"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildChordBox(String name, Color color) {
    return Container(
      width: 55,
      height: 65,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Icon(Icons.grid_on, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildParsedContent() {
    final blocks = ChordProcessor.parse(widget.songData);

    return Wrap(
      runSpacing: 22, // Space between rows of lyrics
      spacing: 2, // Space between words
      children: blocks.map((block) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Chord (Always aligned above the start of its text)
            if (block["chord"] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  block["chord"]!,
                  style: TextStyle(
                    color: widget.singer.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'monospace', // Better for chord alignment
                  ),
                ),
              )
            else
              const SizedBox(height: 20), // Spacer if no chord exists
            // The Lyric text
            Text(
              block["text"] ?? "",
              style: const TextStyle(fontSize: 17, height: 1.1),
            ),
          ],
        );
      }).toList(),
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
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorited
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorited ? Colors.redAccent : null,
            ),
          ),
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => _shareSong(ctx),
              icon: const Icon(Icons.share_outlined),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chords Used",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["G", "Em", "C", "D"]
                    .map((c) => _buildChordBox(c, widget.singer.accentColor))
                    .toList(),
              ),
            ),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lyrics & Chords",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_overscan, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // This is where the magic happens
            _buildParsedContent(),

            const SizedBox(height: 60),
            Center(
              child: Text(
                "Enjoying the chords? Support ${widget.singer.name}!",
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
}
