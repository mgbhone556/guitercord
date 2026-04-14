import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/ui/admin/song_create_with_cord.dart';

class ManageArtistForSongPage extends StatelessWidget {
  const ManageArtistForSongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Select Artist to Add Song"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("artists").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No artists found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var singer = Singer.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: singer.imageUrl.isNotEmpty
                        ? NetworkImage(singer.imageUrl)
                        : null,
                    child: singer.imageUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    singer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // ManageArtistForSongPage ထဲက Card ရဲ့ subtitle မှာ ဒါလေးထည့်ပါ
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(singer.genre),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('artists')
                            .doc(singer.id)
                            .collection('cords')
                            .snapshots(),
                        builder: (context, snapshot) {
                          int count = snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                          return Text(
                            "Chords Created: $count",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.add_circle, color: Colors.blue),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminAddSongPage(
                          singer: singer,
                          song: Song(
                            id: null,
                            title: "",
                            chordsUsed: [],
                            lyricsWithChords: [],
                            albums: [],
                            singerId: '',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
