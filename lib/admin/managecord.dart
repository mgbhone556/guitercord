import 'package:flutter/material.dart';

class ChordEditorTab extends StatefulWidget {
  final List<String> initialSongs;
  final Function(List<String>) onChanged;

  const ChordEditorTab({
    super.key,
    required this.initialSongs,
    required this.onChanged,
  });

  @override
  State<ChordEditorTab> createState() => _ChordEditorTabState();
}

class _ChordEditorTabState extends State<ChordEditorTab> {
  late List<String> _songs;
  final _titleController = TextEditingController();
  final _chordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.initialSongs);
  }

  void _addOrUpdateSong() {
    final title = _titleController.text.trim();
    final chords = _chordController.text.trim();

    if (title.isNotEmpty && chords.isNotEmpty) {
      setState(() {
        // Encode: Title | Content
        _songs.insert(0, "$title|$chords");
        _titleController.clear();
        _chordController.clear();
        widget.onChanged(_songs);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Song & Chord Manager",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Input Area
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: "Song Title",
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _chordController,
          maxLines: 5,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            hintText: "Paste Chords & Lyrics here... (e.g. [G] My [D] Song)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addOrUpdateSong,
          icon: const Icon(Icons.add),
          label: const Text("Add Song to List"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(45),
          ),
        ),

        const SizedBox(height: 16),

        // Display List
        if (_songs.isNotEmpty)
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final parts = _songs[index].split('|');
                final title = parts[0];

                return ListTile(
                  dense: true,
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Chords Attached"),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _songs.removeAt(index);
                        widget.onChanged(_songs);
                      });
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
