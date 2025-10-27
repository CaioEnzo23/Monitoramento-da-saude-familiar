class CsvParser {
  const CsvParser();

  /// Parses a CSV string into a list of lists of strings.
  static List<List<String>> parse(String csvString) {
    final List<List<String>> rows = [];
    // Split by newline, handling both \n and \r\n, and filter out empty lines
    final lines =
        csvString.split(RegExp(r'\r\n?|\n')).where((l) => l.isNotEmpty);

    for (final line in lines) {
      rows.add(_parseLine(line));
    }
    return rows;
  }

  /// Parses a single line of a CSV file, handling quoted fields.
  static List<String> _parseLine(String line) {
    final List<String> fields = [];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        // If we encounter a quote, check if it's an escaped quote (two quotes)
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // Skip the next quote
        } else {
          // Otherwise, toggle the inQuotes flag
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // If we see a comma and we're not inside quotes, it's a new field
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        // Otherwise, just add the character to our current field buffer
        buffer.write(char);
      }
    }
    // Add the last field
    fields.add(buffer.toString());
    return fields;
  }
}