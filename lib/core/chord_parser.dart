class ChordProcessor {
  static List<Map<String, String?>> parse(String rawText) {
    // Regex to find chords inside brackets [G]
    final RegExp regExp = RegExp(r"\[([^\]]+)\]([^\[]*)");
    final matches = regExp.allMatches(rawText);

    if (matches.isEmpty) {
      return [
        {"text": rawText, "chord": null},
      ];
    }

    return matches.map((m) {
      return {
        "chord": m.group(1), // The Chord (e.g., G)
        "text": m.group(2), // The following text
      };
    }).toList();
  }
}
