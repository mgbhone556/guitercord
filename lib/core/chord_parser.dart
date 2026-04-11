class ChordParser {
  /// Parses a string like "[G] Hello [C] World"
  /// into a List of Maps: [{'chord': 'G', 'text': 'Hello '}, {'chord': 'C', 'text': 'World'}]
  static List<Map<String, String>> parse(String rawData) {
    final List<Map<String, String>> result = [];

    // Regular expression to find content inside brackets
    final RegExp exp = RegExp(r'\[(.*?)\]([^\[]*)');
    final Iterable<RegExpMatch> matches = exp.allMatches(rawData);

    if (matches.isEmpty) {
      // If no brackets found, return the whole thing as plain text
      result.add({'chord': '', 'text': rawData});
      return result;
    }

    for (var match in matches) {
      result.add({
        'chord': match.group(1)?.trim() ?? "", // Content inside []
        'text': match.group(2) ?? "", // Content after []
      });
    }

    return result;
  }
}
