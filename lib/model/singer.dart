import 'dart:ui';

class Singer {
  final String? id;
  final String name;
  final String genre;
  final String imageUrl;
  final Color accentColor;
  final String bio;

  const Singer({
    this.id,
    required this.name,
    required this.genre,
    required this.imageUrl,
    required this.accentColor,
    required this.bio,
  });

  factory Singer.fromMap(Map<String, dynamic> map, String id) {
    return Singer(
      id: id,
      name: map['name'] ?? 'Unknown Artist',
      genre: map['genre'] ?? 'Genre',
      imageUrl: map['imageUrl'] ?? '',
      accentColor: Color(map['accentColor'] ?? 0xFF6200EE),
      bio: map['bio'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'genre': genre,
      'imageUrl': imageUrl,
      'accentColor': accentColor.value,
      'bio': bio,
    };
  }
}
