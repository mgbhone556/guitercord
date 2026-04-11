class Song {
  final String? id;
  final String title;
  final List<String> albums;
  final List<String> chordsUsed;
  final List<Map<String, String>> lyricsWithChords;

  Song({
    this.id,
    required this.title,
    required this.chordsUsed,
    required this.lyricsWithChords,
    required this.albums,
  });

  // Firebase မှာ သိမ်းတဲ့အခါ သုံးဖို့ (albums ပါ ထည့်သိမ်းရပါမယ်)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'chordsUsed': chordsUsed,
      'lyricsWithChords': lyricsWithChords,
      'albums': albums, // ဒါလေး ထည့်ပေးပါ
    };
  }

  factory Song.fromMap(Map<String, dynamic> map, String id) {
    return Song(
      id: id,
      title: map['title'] ?? 'Untitled',
      chordsUsed: List<String>.from(map['chordsUsed'] ?? []),
      // List mapping လုပ်တဲ့အခါ error မတက်အောင် null safety သေချာစစ်ပေးထားပါတယ်
      lyricsWithChords: (map['lyricsWithChords'] as List? ?? [])
          .map((item) => Map<String, String>.from(item))
          .toList(),
      albums: List<String>.from(map['albums'] ?? []),
    );
  }
}
