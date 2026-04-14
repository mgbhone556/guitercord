import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart';

class SingerService {
  // Screenshot ထဲကအတိုင်း 'artists' လို့ ပြောင်းထားပါတယ်
  final CollectionReference _artists = FirebaseFirestore.instance.collection(
    'artists',
  );

  // --- SINGER CRUD ---
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

  // --- SONG (CHORD DATA) CRUD ---
  // Screenshot ထဲကအတိုင်း sub-collection ကို 'cords' ဟု သုံးထားပါသည်
  // singer_service.dart ထဲက addSongToSinger ကို ဒီလိုပြင်ပါ
  Future<void> addSongToSinger(String singerId, Song song) async {
    // ၁။ သီချင်းအသစ်ကို sub-collection ထဲ ထည့်မယ်
    await _artists.doc(singerId).collection('cords').add(song.toMap());

    // ၂။ Artist document ရဲ့ updatedAt ကို လက်ရှိအချိန်နဲ့ update လုပ်မယ် (Trending မှာ ထိပ်ဆုံးရောက်ဖို့)
    await _artists.doc(singerId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Song>> getSongsForSinger(String singerId) {
    return _artists.doc(singerId).collection('cords').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Song.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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

  // --- DELETE SONG ---
  Future<void> deleteSong(String singerId, String songId) async {
    try {
      await _artists.doc(singerId).collection('cords').doc(songId).delete();
    } catch (e) {
      print("Error deleting song: $e");
      rethrow;
    }
  }
}
