class FavoritesManager {
  static final List<String> _favoriteSongs = [];

  static void toggle(String songName) {
    if (_favoriteSongs.contains(songName)) {
      _favoriteSongs.remove(songName);
    } else {
      _favoriteSongs.add(songName);
    }
  }

  static List<String> getFavoriteSongs() {
    return _favoriteSongs;
  }

  static void clearAll() {
    _favoriteSongs.clear();
  }
}
