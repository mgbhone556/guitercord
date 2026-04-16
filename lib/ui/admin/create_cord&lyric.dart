import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/service/singer_service.dart';
import 'package:guitercord/ui/admin/admin_created_cord_history_list.dart';

class CreateCordAndlyric extends StatefulWidget {
  final Singer singer;
  final Song? song;

  const CreateCordAndlyric({super.key, required this.singer, this.song});

  @override
  State<CreateCordAndlyric> createState() => _CreateCordAndlyricState();
}

class _CreateCordAndlyricState extends State<CreateCordAndlyric> {
  String? _selectedSong;
  final _chordController = TextEditingController();
  // Single controller for the entire Notepad input
  final _notepadController = TextEditingController();

  bool _isEditing = false;
  String? _editingSongId;

  @override
  void initState() {
    super.initState();
    if (widget.song != null) {
      _startEditing(widget.song!);
    }
  }

  void _startEditing(Song song) {
    setState(() {
      _isEditing = true;
      _editingSongId = song.id;
      _selectedSong = song.title;
      _chordController.text = song.chordsUsed.join(", ");

      // Convert the List<Map> from Firestore into a readable string for the notepad
      StringBuffer buffer = StringBuffer();
      for (var line in song.lyricsWithChords) {
        String chord = line['chord'] ?? '';
        String text = line['text'] ?? '';

        if (chord.isNotEmpty) {
          buffer.writeln("[$chord]"); // Put chords in brackets
        }
        buffer.writeln(text);
      }
      _notepadController.text = buffer.toString();
    });
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingSongId = null;
      _selectedSong = null;
      _chordController.clear();
      _notepadController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Chords" : "Add Chords"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminCreatedChordHistoryList(
                    singer: widget.singer,
                    onEdit: _startEditing,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP INPUTS ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: _selectedSong),
                      onChanged: (val) => _selectedSong = val,
                      decoration: const InputDecoration(
                        labelText: "Song Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _chordController,
                      decoration: const InputDecoration(
                        labelText: "Chords Used Summary (e.g. G, C, D)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Lyrics & Chords (Notepad)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              "Tip: Put chord on one line like [G] and lyrics on the next line.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // --- NOTEPAD INPUT ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _notepadController,
                maxLines: null, // Unlimited lines
                minLines: 15,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontFamily: 'monospace', // Monospace helps with alignment
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText:
                      "[G]\nI'm singing a song...\n\n[C]\nIn the key of C...",
                  contentPadding: EdgeInsets.all(15),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- SAVE BUTTONS ---
            Row(
              children: [
                if (_isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      child: const Text("CANCEL"),
                    ),
                  ),
                if (_isEditing) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _saveOrUpdateSong,
                    child: Text(_isEditing ? "UPDATE CHORD" : "SAVE CHORD"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOrUpdateSong() async {
    if (_selectedSong == null || _selectedSong!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter song title")));
      return;
    }

    // --- PARSING LOGIC ---
    // This converts the raw text into the List<Map> format your app expects
    List<String> lines = _notepadController.text.split('\n');
    List<Map<String, String>> parsedData = [];

    for (int i = 0; i < lines.length; i++) {
      String currentLine = lines[i].trim();
      if (currentLine.isEmpty) continue;

      // Check if this line is a chord (e.g., [G] or [Am7])
      if (currentLine.startsWith('[') && currentLine.endsWith(']')) {
        String chordName = currentLine.substring(1, currentLine.length - 1);
        String lyricsLine = "";

        // Look at the next line for the lyrics
        if (i + 1 < lines.length) {
          String nextLine = lines[i + 1].trim();
          // If the next line isn't another chord, use it as lyrics
          if (!(nextLine.startsWith('[') && nextLine.endsWith(']'))) {
            lyricsLine = nextLine;
            i++; // Skip the next line in the loop
          }
        }
        parsedData.add({'chord': chordName, 'text': lyricsLine});
      } else {
        // Just lyrics without a chord line above it
        parsedData.add({'chord': '', 'text': currentLine});
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final songData = Song(
        id: _editingSongId,
        title: _selectedSong!,
        chordsUsed: _chordController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        lyricsWithChords: parsedData,
        albums: [widget.singer.id!],
        singerId: widget.singer.id!,
      );

      if (_isEditing && _editingSongId != null) {
        await FirebaseFirestore.instance
            .collection('artists')
            .doc(widget.singer.id)
            .collection('cords')
            .doc(_editingSongId)
            .update(songData.toMap());
      } else {
        await SingerService().addSongToSinger(widget.singer.id!, songData);
      }

      if (mounted) Navigator.pop(context); // close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? "Updated!" : "Saved!")),
      );

      _resetForm();
    } catch (e) {
      if (mounted) Navigator.pop(context); // close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
