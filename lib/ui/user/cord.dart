import 'package:flutter/material.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/provider/favorites_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChordViewScreen extends StatefulWidget {
  final String songName;
  final Singer singer;
  final List<Map<String, String>> lyricsData;
  final List<String> chordsUsed;

  const ChordViewScreen({
    super.key,
    required this.songName,
    required this.singer,
    required this.lyricsData,
    required this.chordsUsed,
    required String songData,
  });

  @override
  State<ChordViewScreen> createState() => _ChordViewScreenState();
}

class _ChordViewScreenState extends State<ChordViewScreen> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = FavoritesManager.isFavorite(widget.songName);
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      FavoritesManager.toggle(widget.songName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorited ? "Added to Favorites" : "Removed from Favorites",
        ),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareSong() {
    StringBuffer shareText = StringBuffer();
    shareText.writeln("${widget.songName} - ${widget.singer.name}\n");

    for (var line in widget.lyricsData) {
      if (line['chord']?.isNotEmpty ?? false) {
        shareText.write("[${line['chord']}] ");
      }
      shareText.writeln("${line['text']}");
    }
    shareText.writeln("\nShared from GuitarCord App");
    Share.share(shareText.toString());
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
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareSong,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chords Used",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.chordsUsed
                    .map((c) => _buildChordBox(c, widget.singer.accentColor))
                    .toList(),
              ),
            ),
            const Divider(height: 40),
            _buildLyricsAndChords(),
          ],
        ),
      ),
    );
  }

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
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Icon(Icons.grid_on, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLyricsAndChords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.lyricsData.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (line['chord']?.isNotEmpty ?? false)
                Text(
                  line['chord']!,
                  style: TextStyle(
                    color: widget.singer.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              Text(
                line['text'] ?? "",
                style: const TextStyle(fontSize: 17, height: 1.5),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
