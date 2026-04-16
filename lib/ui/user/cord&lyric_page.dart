import 'package:flutter/material.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/provider/favorites_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChordAndLyricPage extends StatefulWidget {
  final String songName;
  final Singer singer;
  final List<Map<String, String>> lyricsData;
  final List<String> chordsUsed;

  const ChordAndLyricPage({
    super.key,
    required this.songName,
    required this.singer,
    required this.lyricsData,
    required this.chordsUsed,
    required String songData,
  });

  @override
  State<ChordAndLyricPage> createState() => _ChordAndLyricPageState();
}

class _ChordAndLyricPageState extends State<ChordAndLyricPage> {
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

  void _shareSong() async {
    StringBuffer shareText = StringBuffer();
    shareText.writeln("${widget.songName} - ${widget.singer.name}\n");

    for (var line in widget.lyricsData) {
      if (line['chord']?.isNotEmpty ?? false) {
        shareText.write("[${line['chord']}] ");
      }
      shareText.writeln("${line['text']}");
    }
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    shareText.writeln("\nShared from GuitarCord App");
    Share.share(shareText.toString());
    await Share.share(
      shareText.toString(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents layout jumping when popups appear
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.songName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.singer.name,
              style: TextStyle(
                fontSize: 13,
                color: (widget.singer.accentColor == Colors.transparent)
                    ? Colors.black
                    : Colors.white,
              ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Chords Used:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Distributes space evenly
                        children: widget.chordsUsed
                            .map(
                              (c) =>
                                  _buildChordBox(c, widget.singer.accentColor),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 40),
              _buildLyricsAndChords(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChordBox(String name, Color color) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 55,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Keep this
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
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
