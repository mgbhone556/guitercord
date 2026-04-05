import 'dart:ui';

class Singer {
  final String? id;
  final String name;
  final String genre;
  final String imageUrl;
  final Color accentColor;
  final String bio;
  final List<String> popularSongs;
  final List<String> albums;

  const Singer({
    this.id,
    required this.name,
    required this.genre,
    required this.imageUrl,
    required this.accentColor,
    required this.bio,
    required this.popularSongs,
    required this.albums,
  });

  factory Singer.fromMap(Map<String, dynamic> map, String id) {
    return Singer(
      id: id,
      name: map['name'] ?? 'Unknown Artist',
      genre: map['genre'] ?? 'Genre',
      imageUrl: map['imageUrl'] ?? '',
      // Converts Firestore hex string or int to Flutter Color
      accentColor: Color(map['accentColor'] ?? 0xFF6200EE),
      bio: map['bio'] ?? '',
      popularSongs: List<String>.from(map['popularSongs'] ?? []),
      albums: List<String>.from(map['albums'] ?? []),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'genre': genre,
      'imageUrl': imageUrl,
      // Store the color as an integer value (0xFF...)
      'accentColor': accentColor.value,
      'bio': bio,
      'popularSongs': popularSongs,
      'albums': albums,
    };
  }
}
