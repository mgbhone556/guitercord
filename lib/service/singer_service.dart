import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart';

class SingerService {
  final CollectionReference _artists = FirebaseFirestore.instance.collection(
    'artists',
  );

  Future<void> addSinger(Singer singer) async {
    await _artists.add(singer.toMap());
  }

  Stream<List<Singer>> getSingers() {
    return _artists.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Singer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateSinger(Singer singer) async {
    if (singer.id != null) {
      await _artists.doc(singer.id).update(singer.toMap());
    }
  }

  Future<void> deleteSinger(String id) async {
    await _artists.doc(id).delete();
  }

  Future<void> addSongToSinger(String singerId, Song song) async {
    await _artists.doc(singerId).collection('cords').add(song.toMap());

    await _artists.doc(singerId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Song>> getSongsForSinger(String singerId) {
    return _artists.doc(singerId).collection('cords').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Song.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateSong(String singerId, Song song) async {
    if (song.id != null) {
      await _artists
          .doc(singerId)
          .collection('cords')
          .doc(song.id)
          .update(song.toMap());
    }
  }

  Future<void> deleteSong(String singerId, String songId) async {
    try {
      await _artists.doc(singerId).collection('cords').doc(songId).delete();
    } catch (e) {
      print("Error deleting song: $e");
      rethrow;
    }
  }
}
