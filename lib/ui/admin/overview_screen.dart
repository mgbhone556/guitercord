import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "System Statistics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatStream(
                  collection: "users",
                  label: "Total Users",
                  icon: Icons.people_alt_rounded,
                  color: Colors.blue,
                ),

                _buildStatStream(
                  collection: "artists",
                  label: "Artists",
                  icon: Icons.mic_external_on,
                  color: Colors.purple,
                ),

                _buildTotalSongsStat(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Artist တစ်ဦးချင်းစီရဲ့ အောက်က songs collection အားလုံးကို ပေါင်းပြီး ရေတွက်တဲ့ function
  Widget _buildTotalSongsStat() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('cords').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error");
        int totalSongs = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return _buildStatCard(
          "Total Cords",
          totalSongs.toString(),
          Icons.music_note_rounded,
          Colors.green,
        );
      },
    );
  }

  // ရိုးရိုး collection (users သို့မဟုတ် singers) အရေအတွက်ကို ရေတွက်တဲ့ function
  Widget _buildStatStream({
    required String collection,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _buildStatCard(label, count.toString(), icon, color);
      },
    );
  }

  // Card Design
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
