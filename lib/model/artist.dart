import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class Singer {
  final String? id; // Firestore Doc ID
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

  // Convert Firestore Document to Singer Object
  factory Singer.fromMap(Map<String, dynamic> map, String documentId) {
    return Singer(
      id: documentId,
      name: map['name'] ?? '',
      genre: map['genre'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      accentColor: Color(map['accentColor'] ?? 0xFF4776E6),
      bio: map['bio'] ?? '',
      popularSongs: List<String>.from(map['popularSongs'] ?? []),
      albums: List<String>.from(map['albums'] ?? []),
    );
  }

  // Convert Singer Object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'genre': genre,
      'imageUrl': imageUrl,
      'accentColor': accentColor.value,
      'bio': bio,
      'popularSongs': popularSongs,
      'albums': albums,
    };
  }
}
