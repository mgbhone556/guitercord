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

  final List<String> _quickChords = ["G", "C", "D", "Em", "Am", "F", "A", "Bm"];

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.initialSongs);
  }

  void _insertChord(String chord) {
    final text = _chordController.text;
    final selection = _chordController.selection;
    final chordTag = "[$chord]";

    if (selection.start >= 0) {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        chordTag,
      );
      _chordController.text = newText;
      _chordController.selection = TextSelection.collapsed(
        offset: selection.start + chordTag.length,
      );
    } else {
      _chordController.text += chordTag;
    }
  }

  void _addOrUpdateSong() {
    final title = _titleController.text.trim();
    final content = _chordController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      setState(() {
        _songs.insert(0, "$title:::$content");
        _titleController.clear();
        _chordController.clear();
        FocusScope.of(context).unfocus();
      });
      widget.onChanged(_songs);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Song Saved!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // LayoutBuilder ensures we have constraints to avoid the black screen crash
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionHeader("Song & Chord Editor"),
                    const SizedBox(height: 16),
                    _buildEditorField(
                      controller: _titleController,
                      hint: "Song Title",
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Quick Insert:",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildQuickChordBar(),
                    const SizedBox(height: 8),
                    _buildEditorField(
                      controller: _chordController,
                      hint: "Paste lyrics with [G] chords...",
                      icon: Icons.music_note_rounded,
                      maxLines: 6,
                      isMonospace: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed:
                          _addOrUpdateSong, // <--- This triggers the save logic
                      icon: const Icon(Icons.playlist_add_check_rounded),
                      label: const Text("SAVE TO LIST"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Current Song List"),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              _songs.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyPrompt())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final title = _songs[index].split(':::')[0];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () =>
                                  setState(() => _songs.removeAt(index)),
                            ),
                          ),
                        );
                      }, childCount: _songs.length),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickChordBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickChords
            .map(
              (chord) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(chord),
                  onPressed: () => _insertChord(chord),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    );
  }

  Widget _buildEditorField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool isMonospace = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: isMonospace ? 'monospace' : null,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEmptyPrompt() {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            "No songs added yet.",
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
