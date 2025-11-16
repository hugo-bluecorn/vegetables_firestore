import 'dart:io';
import 'package:args/args.dart';
import 'package:vegetables_firestore/services/vegetable_importer.dart';
import 'package:vegetables_firestore/services/vegetable_exporter.dart';
import 'package:vegetables_firestore/services/firestore_service.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import 'package:vegetables_firestore/services/firestore_upload_service.dart';
import 'package:vegetables_firestore/models/vegetable.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addCommand('import', buildImportCommand());
}

ArgParser buildImportCommand() {
  return ArgParser()
    ..addOption(
      'input',
      abbr: 'i',
      help: 'Path to input text file with vegetable names (one per line)',
      mandatory: true,
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Path to output JSON file',
      mandatory: true,
    )
    ..addOption(
      'api-key',
      abbr: 'k',
      help: 'DeepL API key (will prompt if not provided)',
    )
    ..addFlag(
      'upload-to-firestore',
      defaultsTo: false,
      help: 'Upload vegetables to Firestore after import',
    )
    ..addOption(
      'firebase-project-id',
      help: 'Firebase project ID (required if uploading to Firestore)',
    )
    ..addOption(
      'firebase-service-account',
      help: 'Path to service account JSON file',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart vegetables_firestore.dart <command> [options]');
  print('');
  print('Commands:');
  print('  import    Import vegetables from a text file');
  print('');
  print('Global options:');
  print(argParser.usage);
  print('');
  print('Run "dart vegetables_firestore.dart import --help" for import options.');
}

void printImportUsage(ArgParser importParser) {
  print('Usage: dart vegetables_firestore.dart import [options]');
  print('');
  print('Import vegetables from a text file and translate to multiple languages.');
  print('');
  print('Options:');
  print(importParser.usage);
  print('');
  print('Example:');
  print('  dart vegetables_firestore.dart import \\');
  print('    --input vegetables.txt \\');
  print('    --output vegetables.json \\');
  print('    --api-key YOUR_DEEPL_API_KEY');
}

Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    // Check for commands first
    if (results.command?.name == 'import') {
      await handleImportCommand(results.command!);
      return;
    }

    // Process global flags (only if no command)
    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('vegetables_firestore version: $version');
      return;
    }

    // No command provided
    printUsage(argParser);
  } on FormatException catch (e) {
    print(e.message);
    print('');
    printUsage(argParser);
    exit(1);
  }
}

Future<void> handleImportCommand(ArgResults command) async {
  // Check for help flag
  if (command.arguments.contains('--help') ||
      command.arguments.contains('-h')) {
    printImportUsage(buildImportCommand());
    return;
  }

  final inputPath = command.option('input')!;
  final outputPath = command.option('output')!;
  String? apiKey = command.option('api-key');

  // Validate input file exists
  if (!File(inputPath).existsSync()) {
    print('Error: Input file not found: $inputPath');
    exit(1);
  }

  // Prompt for API key if not provided
  if (apiKey == null || apiKey.isEmpty) {
    stdout.write('Enter DeepL API key: ');
    apiKey = stdin.readLineSync();

    if (apiKey == null || apiKey.isEmpty) {
      print('Error: API key is required');
      exit(1);
    }
  }

  print('Starting vegetable import...');
  print('Input: $inputPath');
  print('Output: $outputPath');
  print('');

  try {
    // Import vegetables with progress reporting
    final result = await VegetableImporter.importFromFile(
      inputPath,
      apiKey,
      onProgress: (name, current, total) {
        stdout.write('\rProcessing: $name ($current/$total)');
      },
    );

    print(''); // New line after progress
    print('');
    print('Import complete!');
    print('Successfully imported: ${result.successful}');
    if (result.failed > 0) {
      print('Failed: ${result.failed}');
      print('');
      print('Errors:');
      result.errors.forEach((name, error) {
        print('  - $name: $error');
      });
    }

    // Export to JSON
    print('');
    print('Writing to $outputPath...');
    await VegetableExporter.toJsonFile(result.vegetables, outputPath);
    print('Done! Exported ${result.vegetables.length} vegetables.');

    // Upload to Firestore if requested
    if (command.flag('upload-to-firestore')) {
      print('');
      await uploadToFirestore(command, result.vegetables);
    }
  } catch (e) {
    print('');
    print('Error during import: $e');
    exit(1);
  }
}

Future<void> uploadToFirestore(
  ArgResults command,
  List<Vegetable> vegetables,
) async {
  // Get Firebase project ID
  var projectId = command.option('firebase-project-id');
  if (projectId == null || projectId.isEmpty) {
    stdout.write('Enter Firebase project ID: ');
    projectId = stdin.readLineSync();

    if (projectId == null || projectId.isEmpty) {
      print('Error: Firebase project ID is required');
      exit(1);
    }
  }

  // Get service account JSON
  String serviceAccountJson;
  final serviceAccountPath = command.option('firebase-service-account');

  if (serviceAccountPath != null && serviceAccountPath.isNotEmpty) {
    // Read from file
    final file = File(serviceAccountPath);
    if (!file.existsSync()) {
      print('Error: Service account file not found: $serviceAccountPath');
      exit(1);
    }
    serviceAccountJson = await file.readAsString();
  } else {
    // Prompt for JSON
    print('Enter service account JSON (paste entire JSON on one line): ');
    stdout.write('> ');
    serviceAccountJson = stdin.readLineSync() ?? '';
  }

  if (serviceAccountJson.isEmpty) {
    print('Error: Service account JSON is required for Firestore upload');
    exit(1);
  }

  try {
    // Initialize Firestore
    print('Connecting to Firestore...');
    final firestoreService = FirestoreService();
    await firestoreService.initialize(projectId, serviceAccountJson);

    // Upload vegetables
    final repository = VegetableRepository(firestoreService.firestore);
    final uploadService = FirestoreUploadService(repository);

    print('Uploading vegetables to Firestore...');
    final result = await uploadService.uploadNewVegetables(
      vegetables,
      onProgress: (progress) {
        stdout.write('\r${progress}');
      },
    );

    print('');
    print('');
    print('Upload complete!');
    print(result);

    if (result.hasSkipped) {
      print('');
      print('Skipped vegetables (already exist in Firestore):');
      for (final name in result.skippedNames) {
        print('  - $name');
      }
    }

    // Cleanup
    await firestoreService.close();
  } catch (e) {
    print('');
    print('Error uploading to Firestore: $e');
    exit(1);
  }
}
