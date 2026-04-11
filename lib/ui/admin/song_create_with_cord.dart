import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/model/artist.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/service/singer_service.dart';
import 'package:guitercord/ui/admin/cord_history.dart';

class AdminAddSongPage extends StatefulWidget {
  final Singer singer;
  final Song? song; // optional ဖြစ်သွားပါပြီ (Add ရော Edit ရော သုံးနိုင်အောင်)

  const AdminAddSongPage({super.key, required this.singer, this.song});

  @override
  State<AdminAddSongPage> createState() => _AdminAddSongPageState();
}

class _AdminAddSongPageState extends State<AdminAddSongPage> {
  String? _selectedSong;
  final _chordController = TextEditingController();
  List<LineInput> _lines = [];
  bool _isEditing = false;
  String? _editingSongId;

  @override
  void initState() {
    super.initState();
    // History ကနေ Edit ဖို့ song ပါလာရင် တန်းပြီး data သွင်းမယ်
    if (widget.song != null) {
      _startEditing(widget.song!);
    } else {
      _resetLines();
    }
  }

  void _resetLines() {
    setState(() {
      _lines = [
        LineInput(
          chordController: TextEditingController(),
          textController: TextEditingController(),
        ),
      ];
    });
  }

  void _startEditing(Song song) {
    setState(() {
      _isEditing = true;
      _editingSongId = song.id;
      _selectedSong = song.title;
      _chordController.text = song.chordsUsed.join(", ");
      _lines = song.lyricsWithChords
          .map(
            (m) => LineInput(
              chordController: TextEditingController(text: m['chord'] ?? ''),
              textController: TextEditingController(text: m['text'] ?? ''),
            ),
          )
          .toList();
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
                  builder: (context) => AdminChordHistoryPage(
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
          children: [
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
                        labelText: "Chords Used (e.g. G, C, D)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lyrics & Chords",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            ..._lines.asMap().entries.map((entry) {
              int idx = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _lines[idx].chordController,
                        decoration: const InputDecoration(
                          hintText: "Chord",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _lines[idx].textController,
                        decoration: const InputDecoration(
                          hintText: "Lyric line",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => setState(() => _lines.removeAt(idx)),
                    ),
                  ],
                ),
              );
            }).toList(),

            TextButton.icon(
              onPressed: () => setState(
                () => _lines.add(
                  LineInput(
                    chordController: TextEditingController(),
                    textController: TextEditingController(),
                  ),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text("ADD NEW LINE"),
            ),

            const SizedBox(height: 30),
            Row(
              children: [
                if (_isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _selectedSong = null;
                          _chordController.clear();
                          _resetLines();
                        });
                      },
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

  // AdminAddSongPage ရဲ့ _saveOrUpdateSong method ထဲမှာ ပြင်ရန်
  Future<void> _saveOrUpdateSong() async {
    if (_selectedSong == null || _selectedSong!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter song title")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final songData = Song(
        id: _editingSongId, // Edit ဆိုရင် id ရှိမယ်၊ Add ဆိုရင် null ဖြစ်မယ်
        title: _selectedSong!,
        chordsUsed: _chordController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        lyricsWithChords: _lines
            .map(
              (l) => {
                'chord': l.chordController.text.trim(),
                'text': l.textController.text.trim(),
              },
            )
            .toList(),
        // ဒီမှာ singer.id ကို သေချာထည့်ပေးပါ (ဒါမှ song က artist နဲ့ link ဖြစ်မှာပါ)
        albums: [widget.singer.id!],
      );

      if (_isEditing && _editingSongId != null) {
        // Edit Mode
        await FirebaseFirestore.instance
            .collection('artists')
            .doc(widget.singer.id)
            .collection('songs')
            .doc(_editingSongId)
            .update(songData.toMap());
      } else {
        // Add New Mode
        await SingerService().addSongToSinger(widget.singer.id!, songData);
      }

      Navigator.pop(context); // close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? "Updated Successfully!" : "Saved Successfully!",
          ),
        ),
      );

      // Form ကို reset ပြန်လုပ်မယ်
      setState(() {
        _isEditing = false;
        _editingSongId = null;
        _selectedSong = null;
        _chordController.clear();
        _resetLines();
      });
    } catch (e) {
      Navigator.pop(context); // close loading
      debugPrint("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

class LineInput {
  final TextEditingController chordController;
  final TextEditingController textController;
  LineInput({required this.chordController, required this.textController});
}
