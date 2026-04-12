class Song {
  final String? id;
  final String title;
  final List<String> albums;
  final List<String> chordsUsed;
  final List<Map<String, String>> lyricsWithChords;

  // ✅ ADD THIS
  final String singerId;

  Song({
    this.id,
    required this.title,
    required this.chordsUsed,
    required this.lyricsWithChords,
    required this.albums,
    required this.singerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'chordsUsed': chordsUsed,
      'lyricsWithChords': lyricsWithChords,
      'albums': albums,

      // ✅ ADD THIS
      'singerId': singerId,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map, String id) {
    return Song(
      id: id,
      title: map['title'] ?? 'Untitled',
      chordsUsed: List<String>.from(map['chordsUsed'] ?? []),
      lyricsWithChords: (map['lyricsWithChords'] as List? ?? [])
          .map((item) => Map<String, String>.from(item as Map))
          .toList(),
      albums: List<String>.from(map['albums'] ?? []),

      // ✅ ADD THIS
      singerId: map['singerId'] ?? '',
    );
  }
}
