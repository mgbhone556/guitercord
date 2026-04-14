class ChordParser {
  static List<Map<String, String>> parse(String rawData) {
    final List<Map<String, String>> result = [];

    final RegExp exp = RegExp(r'\[(.*?)\]([^\[]*)');
    final Iterable<RegExpMatch> matches = exp.allMatches(rawData);

    if (matches.isEmpty) {
      result.add({'chord': '', 'text': rawData});
      return result;
    }

    for (var match in matches) {
      result.add({
        'chord': match.group(1)?.trim() ?? "",
        'text': match.group(2) ?? "",
      });
    }

    return result;
  }
}
