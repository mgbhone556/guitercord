import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String? id;
  final String title;
  final List<String> albums;
  final List<String> chordsUsed;
  final List<Map<String, String>> lyricsWithChords;
  final String singerId;
  final DateTime? createdAt;

  Song({
    this.id,
    required this.title,
    required this.chordsUsed,
    required this.lyricsWithChords,
    required this.albums,
    required this.singerId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'chordsUsed': chordsUsed,
      'lyricsWithChords': lyricsWithChords,
      'albums': albums,
      'singerId': singerId,
      'createdAt': createdAt ?? DateTime.now(),
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
      singerId: map['singerId'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
