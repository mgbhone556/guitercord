import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static late SharedPreferences _prefs;
  static const String _key = 'favorite_songs';
  static List<String> _favoriteSongs = [];

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _favoriteSongs = _prefs.getStringList(_key) ?? [];
  }

  static void toggle(String songName) async {
    if (_favoriteSongs.contains(songName)) {
      _favoriteSongs.remove(songName);
    } else {
      _favoriteSongs.add(songName);
    }
    await _prefs.setStringList(_key, _favoriteSongs);
  }

  static List<String> getFavoriteSongs() => _favoriteSongs;

  static bool isFavorite(String songName) => _favoriteSongs.contains(songName);
}
