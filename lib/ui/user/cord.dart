import 'package:flutter/material.dart';
import 'package:guitercord/core/chord_parser.dart';
import 'package:guitercord/model/artist.dart';
import 'package:guitercord/provider/favorites_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChordViewScreen extends StatefulWidget {
  final String songName;
  final Singer singer;
  final List<Map<String, dynamic>> lyricsData; // Admin ကပို့တဲ့ list format
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
  // ... (initState, dispose, toggleFavorite, shareSong တွေက အရင်အတိုင်းပဲ ထားပါ)

  // Chords Used list ကို ပြပေးတဲ့ UI
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

  // Chords နဲ့ Lyrics ကို တစ်ကြောင်းချင်းစီ ပြပေးမယ့် UI
  Widget _buildLyricsAndChords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.lyricsData.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chord ရှိရင် ပြမယ်
              if (line['chord'] != null && line['chord']!.toString().isNotEmpty)
                Text(
                  line['chord']!.toString(),
                  style: TextStyle(
                    color: widget.singer.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              // Lyric စာသား
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
        actions: [/* Favorite & Share Buttons အရင်အတိုင်းထားပါ */],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chords Used",
              style: TextStyle(
                fontSize: 15,
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
            const Text(
              "Lyrics & Chords",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Magic Area: ဒီနေရာမှာ Data တွေပေါ်လာမှာပါ
            _buildLyricsAndChords(),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "Enjoy playing!",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
