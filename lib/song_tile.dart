import 'package:flutter/material.dart';
import 'package:guitercord/cord.dart';
import 'package:guitercord/model.dart';

class SongTile extends StatelessWidget {
  final String song;
  final Singer singer;
  final VoidCallback? onReturn;

  const SongTile({
    super.key,
    required this.song,
    required this.singer,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(
          Icons.play_circle_filled_rounded,
          color: singer.accentColor,
          size: 32,
        ),
        title: Text(song, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Text("4 Chords", style: TextStyle(color: Colors.grey)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChordViewScreen(songName: song, singer: singer),
            ),
          ).then((_) {
            // When we come back, run the refresh function if it exists
            if (onReturn != null) onReturn!();
          });
        },
      ),
    );
  }
}
