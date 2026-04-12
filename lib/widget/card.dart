import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guitercord/model/singer.dart';
import 'package:guitercord/model/song.dart';
import 'package:guitercord/ui/user/cord.dart';
import 'package:guitercord/ui/user/detail.dart';

class TrendingCard extends StatelessWidget {
  final String songName;
  final Song song;
  final Singer singer;

  const TrendingCard({
    super.key,
    required this.songName,
    required this.singer,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return _PressedWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChordViewScreen(
              songName: songName,
              singer: singer,
              songData: '', // Pass any extra metadata string here if needed
              lyricsData: song.lyricsWithChords,
              chordsUsed: song.chordsUsed,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Gradient using Singer's accent color
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      singer.accentColor.withOpacity(0.8),
                      const Color(0xFF1E1E26),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const Spacer(),
                    Text(
                      songName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      singer.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SingerCard extends StatelessWidget {
  final Singer singer;
  const SingerCard({super.key, required this.singer});

  @override
  Widget build(BuildContext context) {
    final String heroTag = "hero-${singer.id}";

    return _PressedWrapper(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(singer: singer, heroTag: heroTag),
        ),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bottom Info Card
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 165,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      singer.accentColor,
                      Color.lerp(singer.accentColor, Colors.black, 0.2)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: singer.accentColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            // Floating Profile Image
            Positioned(
              top: -25,
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: singer.imageUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 42,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => const CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.grey,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        radius: 42,
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Name and Genre text
            Positioned(
              bottom: 20,
              left: 14,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          singer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.verified,
                        color: Colors.blueAccent,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    singer.genre.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
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

class SongTile extends StatelessWidget {
  final Song song; // Changed from String to Song for better data flow
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
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          "${song.chordsUsed.length} Chords",
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChordViewScreen(
                songName: song.title,
                singer: singer,
                songData: '',
                lyricsData: song.lyricsWithChords,
                chordsUsed: song.chordsUsed,
              ),
            ),
          ).then((_) {
            if (onReturn != null) onReturn!();
          });
        },
      ),
    );
  }
}

// Internal wrapper to handle haptic feedback and scale animations
class _PressedWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressedWrapper({required this.child, required this.onTap});

  @override
  State<_PressedWrapper> createState() => _PressedWrapperState();
}

class _PressedWrapperState extends State<_PressedWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
