import 'dart:io';

/// Service for reading vegetable names from text files
class VegetableFileReader {
  /// Reads vegetable names from a text file
  ///
  /// Expects one vegetable name per line in the file.
  /// Empty lines and whitespace-only lines are skipped.
  /// Leading and trailing whitespace is trimmed from each name.
  ///
  /// Parameters:
  /// - [filePath]: Path to the text file containing vegetable names
  ///
  /// Returns a [List<String>] of vegetable names.
  ///
  /// Throws:
  /// - [FileSystemException] if the file does not exist or cannot be read
  static Future<List<String>> readNames(String filePath) async {
    final file = File(filePath);

    // Read all lines from the file
    final lines = await file.readAsLines();

    // Process lines: trim whitespace and filter out empty lines
    final names = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return names;
  }
}
