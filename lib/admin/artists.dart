import 'package:flutter/material.dart';
import 'package:guitercord/admin/singer_service.dart';
import 'package:guitercord/core/empty_state.dart';
import 'package:guitercord/model/artist.dart';
import 'package:guitercord/widget/list.dart'; // Your CustomListInput
import 'package:guitercord/widget/text_field.dart'; // Your CustomTextField

class SingerManagerTab extends StatelessWidget {
  final SingerService service;
  final Function(Singer) onEdit;
  final Function(Singer) onDelete;

  const SingerManagerTab({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  // --- STATIC METHOD TO SHOW DIALOG ---
  // This allows the AdminDashboard to call this dialog for "Add Artist"
  static void showArtistDialog(
    BuildContext context,
    SingerService service, {
    Singer? singer,
  }) {
    final nameCtrl = TextEditingController(text: singer?.name);
    final genreCtrl = TextEditingController(text: singer?.genre);
    final imgCtrl = TextEditingController(text: singer?.imageUrl);
    final bioCtrl = TextEditingController(text: singer?.bio);

    final colorCtrl = TextEditingController(
      text: singer != null
          ? '#${singer.accentColor.value.toRadixString(16).padLeft(8, '0').substring(2)}'
          : '#4776E6',
    );

    List<String> currentSongs = singer?.popularSongs ?? [];
    List<String> currentAlbums = singer?.albums ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  singer == null ? "New Artist" : "Edit Artist",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: nameCtrl,
                        label: "Name",
                        prefixIcon: Icons.person,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: genreCtrl,
                        label: "Genre",
                        prefixIcon: Icons.music_note,
                      ),
                    ),
                  ],
                ),
                CustomTextField(
                  controller: imgCtrl,
                  label: "Image URL",
                  prefixIcon: Icons.link,
                ),
                CustomTextField(
                  controller: colorCtrl,
                  label: "Accent Color (Hex)",
                  prefixIcon: Icons.color_lens,
                ),
                CustomTextField(
                  controller: bioCtrl,
                  label: "Biography",
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
                const Divider(),
                CustomListInput(
                  label: "Popular Songs",
                  initialItems: currentSongs,
                  onChanged: (val) => currentSongs = val,
                ),
                CustomListInput(
                  label: "Albums",
                  initialItems: currentAlbums,
                  onChanged: (val) => currentAlbums = val,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        int colorInt = int.parse(
                          colorCtrl.text.replaceFirst('#', '0xff'),
                        );

                        final newSinger = Singer(
                          id: singer?.id,
                          name: nameCtrl.text,
                          genre: genreCtrl.text,
                          imageUrl: imgCtrl.text,
                          bio: bioCtrl.text,
                          accentColor: Color(colorInt),
                          popularSongs: currentSongs,
                          albums: currentAlbums,
                        );

                        if (singer == null) {
                          service.addSinger(newSinger);
                        } else {
                          service.updateSinger(newSinger);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("Save Artist"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Manage Artists",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<Singer>>(
            stream: service.getSingers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: EmptyState(isDark: false, icon: Icons.music_note),
                );
              }

              final singers = snapshot.data!;
              return ListView.builder(
                itemCount: singers.length,
                itemBuilder: (context, index) {
                  final singer = singers[index];
                  return _SingerCard(
                    singer: singer,
                    onEdit: () => onEdit(singer),
                    onDelete: () => onDelete(singer),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SingerCard extends StatelessWidget {
  final Singer singer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SingerCard({
    required this.singer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(singer.imageUrl),
        ),
        title: Text(
          singer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(singer.genre),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
