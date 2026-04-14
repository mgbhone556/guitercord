import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitercord/model/singer.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({super.key});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to show the "Add/Edit" Form
  void _showArtistForm({Singer? existingSinger}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SingerFormSheet(
        singer: existingSinger,
        onSave: (singer) async {
          if (existingSinger == null) {
            await _firestore.collection("artists").add(singer.toMap());
          } else {
            await _firestore
                .collection("artists")
                .doc(existingSinger.id)
                .update(singer.toMap());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Artist Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showArtistForm(),
        label: const Text("Add Artist"),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("artists").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final artists = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final singer = Singer.fromMap(
                artists[index].data() as Map<String, dynamic>,
                artists[index].id,
              );

              return _buildArtistCard(singer, artists[index].reference);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
          const Text(
            "No artists found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistCard(Singer singer, DocumentReference docRef) {
    return Dismissible(
      key: Key(singer.id!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Artist?"),
            content: Text("Are you sure you want to remove ${singer.name}?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => docRef.delete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: singer.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: () => _showArtistForm(existingSinger: singer),
          contentPadding: const EdgeInsets.all(12),
          leading: Hero(
            tag: singer.id!,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: singer.accentColor.withOpacity(0.2),
              backgroundImage: singer.imageUrl.isNotEmpty
                  ? NetworkImage(singer.imageUrl)
                  : null,
              child: singer.imageUrl.isEmpty
                  ? Icon(Icons.person, color: singer.accentColor)
                  : null,
            ),
          ),
          title: Text(
            singer.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                singer.genre,
                style: TextStyle(
                  color: singer.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
          trailing: const Icon(Icons.edit_note),
        ),
      ),
    );
  }
}

// --- SEPARATE COMPONENT FOR THE FORM ---
class SingerFormSheet extends StatefulWidget {
  final Singer? singer;
  final Function(Singer) onSave;

  const SingerFormSheet({super.key, this.singer, required this.onSave});

  @override
  State<SingerFormSheet> createState() => _SingerFormSheetState();
}

class _SingerFormSheetState extends State<SingerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCont, _genreCont, _imgCont, _bioCont;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameCont = TextEditingController(text: widget.singer?.name);
    _genreCont = TextEditingController(text: widget.singer?.genre);
    _imgCont = TextEditingController(text: widget.singer?.imageUrl);
    _bioCont = TextEditingController(text: widget.singer?.bio);
    _selectedColor = widget.singer?.accentColor ?? Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.singer == null ? "Create New Artist" : "Edit Artist",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(_nameCont, "Name", Icons.person),
              _buildField(_genreCont, "Genre", Icons.music_note),
              _buildField(_imgCont, "Image URL", Icons.link),
              _buildField(_bioCont, "Bio", Icons.description, lines: 3),
              ListTile(
                title: const Text("Theme Color"),
                trailing: CircleAvatar(backgroundColor: _selectedColor),
                onTap: () => setState(
                  () => _selectedColor = (Colors.primaries..shuffle()).first,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final s = Singer(
                      id: widget.singer?.id,
                      name: _nameCont.text.trim(),
                      genre: _genreCont.text.trim(),
                      imageUrl: _imgCont.text.trim(),
                      accentColor: _selectedColor,
                      bio: _bioCont.text.trim(),
                    );
                    widget.onSave(s);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Confirm & Save"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }
}
