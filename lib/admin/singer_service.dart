import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guitercord/model/artist.dart';

class SingerService {
  final CollectionReference _singers = FirebaseFirestore.instance.collection(
    'singers',
  );

  // CREATE
  Future<void> addSinger(Singer singer) async {
    await _singers.add(singer.toMap());
  }

  // READ (Real-time Stream)
  Stream<List<Singer>> getSingers() {
    return _singers.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Singer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // UPDATE
  Future<void> updateSinger(Singer singer) async {
    if (singer.id != null) {
      await _singers.doc(singer.id).update(singer.toMap());
    }
  }

  // DELETE
  Future<void> deleteSinger(String id) async {
    await _singers.doc(id).delete();
  }
}
