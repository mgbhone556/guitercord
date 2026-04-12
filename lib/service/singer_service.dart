import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart'; // Ensure this matches your file path

class SingerService {
  final CollectionReference _singers = FirebaseFirestore.instance.collection(
    'singers',
  );

  // --- SINGER CRUD ---

  Stream<List<Singer>> getSingers() {
    return _singers.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Singer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addSinger(Singer singer) async {
    // You'll need a toMap() method in your Singer class
    await _singers.add(singer.toMap());
  }

  Future<void> updateSinger(Singer singer) async {
    if (singer.id != null) {
      await _singers.doc(singer.id).update(singer.toMap());
    }
  }

  Future<void> deleteSinger(String id) async {
    await _singers.doc(id).delete();
  }

  // --- SONG (CHORD DATA) CRUD ---
  // These methods target: singers -> {singerId} -> songs -> {songId}

  Future<void> addSongToSinger(String singerId, Song song) async {
    await _singers.doc(singerId).collection('songs').add(song.toMap());
  }

  Stream<List<Song>> getSongsForSinger(String singerId) {
    return _singers.doc(singerId).collection('songs').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Song.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateSong(String singerId, Song song) async {
    if (song.id != null) {
      await _singers
          .doc(singerId)
          .collection('songs')
          .doc(song.id)
          .update(song.toMap());
    }
  }
}
