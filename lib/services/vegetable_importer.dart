import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/deepl_client.dart';
import 'package:vegetables_firestore/services/vegetable_factory.dart';
import 'package:vegetables_firestore/services/vegetable_file_reader.dart';

/// Callback function for import progress updates
typedef ProgressCallback = void Function(String vegetableName, int current, int total);

/// Result of a vegetable import operation
class ImportResult {
  /// Successfully imported vegetables
  final List<Vegetable> vegetables;

  /// Number of successful imports
  final int successful;

  /// Number of failed imports
  final int failed;

  /// Map of vegetable names to error messages
  final Map<String, String> errors;

  const ImportResult({
    required this.vegetables,
    required this.successful,
    required this.failed,
    required this.errors,
  });

  /// Total number of vegetables processed
  int get total => successful + failed;

  /// Whether any errors occurred during import
  bool get hasErrors => failed > 0;

  /// Formatted summary of import results
  String get summary {
    return 'Import complete: $total total, $successful successful, $failed failed';
  }
}

/// Service for importing vegetables from text files
class VegetableImporter {
  /// Delay between API requests to respect rate limits (milliseconds)
  static const int _delayBetweenRequests = 100;

  /// Imports vegetables from a text file
  ///
  /// Reads vegetable names from the file (one per line), translates each to
  /// all supported languages using DeepL API, and creates complete Vegetable objects.
  ///
  /// Parameters:
  /// - [inputPath]: Path to the input text file
  /// - [apiKey]: DeepL API key for translation
  /// - [onProgress]: Optional callback for progress updates
  ///
  /// Returns an [ImportResult] with imported vegetables and statistics.
  ///
  /// Throws:
  /// - [FileSystemException] if the file cannot be read
  /// - [ArgumentError] if the API key is invalid
  static Future<ImportResult> importFromFile(
    String inputPath,
    String apiKey, {
    ProgressCallback? onProgress,
  }) async {
    // Validate API key
    if (!DeeplClient.isValidApiKey(apiKey)) {
      throw ArgumentError('Invalid API key format');
    }

    // Read vegetable names from file
    final names = await VegetableFileReader.readNames(inputPath);

    // Handle empty file
    if (names.isEmpty) {
      return const ImportResult(
        vegetables: [],
        successful: 0,
        failed: 0,
        errors: {},
      );
    }

    // Import each vegetable
    final vegetables = <Vegetable>[];
    final errors = <String, String>{};
    int successful = 0;
    int failed = 0;

    for (var i = 0; i < names.length; i++) {
      final name = names[i];
      final current = i + 1;
      final total = names.length;

      // Report progress
      if (onProgress != null) {
        onProgress(name, current, total);
      }

      try {
        // Create vegetable with translations
        final vegetable = await VegetableFactory.fromDutchName(name, apiKey);
        vegetables.add(vegetable);
        successful++;

        // Add delay to respect rate limits (except for last item)
        if (i < names.length - 1) {
          await Future.delayed(
            const Duration(milliseconds: _delayBetweenRequests),
          );
        }
      } catch (e) {
        // Log error and continue with next vegetable
        errors[name] = e.toString();
        failed++;
      }
    }

    return ImportResult(
      vegetables: vegetables,
      successful: successful,
      failed: failed,
      errors: errors,
    );
  }

  /// Creates an ImportResult (useful for testing)
  static ImportResult createResult({
    required List<Vegetable> vegetables,
    required int successful,
    required int failed,
    required Map<String, String> errors,
  }) {
    return ImportResult(
      vegetables: vegetables,
      successful: successful,
      failed: failed,
      errors: errors,
    );
  }
}
