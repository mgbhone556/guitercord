class Song {
  final String? id;
  final String title;
  final List<String> chordsUsed; // e.g., ["G", "Em", "C", "D"]
  final List<Map<String, String>>
  lyricsWithChords; // e.g., [{"chord": "G", "text": "I'm heading out..."}]

  Song({
    this.id,
    required this.title,
    required this.chordsUsed,
    required this.lyricsWithChords,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'chordsUsed': chordsUsed,
      'lyricsWithChords': lyricsWithChords,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map, String id) {
    return Song(
      id: id,
      title: map['title'] ?? 'Untitled',
      chordsUsed: List<String>.from(map['chordsUsed'] ?? []),
      lyricsWithChords: List<Map<String, String>>.from(
        (map['lyricsWithChords'] as List).map(
          (item) => Map<String, String>.from(item),
        ),
      ),
    );
  }
}
