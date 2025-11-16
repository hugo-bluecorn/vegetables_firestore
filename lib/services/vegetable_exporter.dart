import 'dart:convert';
import 'dart:io';
import 'package:vegetables_firestore/models/vegetable.dart';

/// Service for exporting vegetables to JSON files
class VegetableExporter {
  /// Exports vegetables to a JSON file with pretty-printing
  ///
  /// Serializes the list of vegetables to JSON format and writes to the
  /// specified file path. Uses indentation for readability.
  ///
  /// Parameters:
  /// - [vegetables]: List of vegetables to export
  /// - [outputPath]: Path to the output JSON file
  ///
  /// The output file will contain a JSON array of vegetable objects,
  /// even if the list contains only one vegetable.
  ///
  /// If the parent directory does not exist, it will be created.
  /// If the output file already exists, it will be overwritten.
  ///
  /// Throws:
  /// - [FileSystemException] if the file cannot be written
  static Future<void> toJsonFile(
    List<Vegetable> vegetables,
    String outputPath,
  ) async {
    // Convert vegetables to JSON-serializable maps
    final jsonList = vegetables.map((v) => v.toMap()).toList();

    // Encode with pretty-printing (2-space indentation)
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(jsonList);

    // Create parent directory if it doesn't exist
    final file = File(outputPath);
    final parentDir = file.parent;
    if (!parentDir.existsSync()) {
      parentDir.createSync(recursive: true);
    }

    // Write to file
    await file.writeAsString(jsonString);
  }
}
