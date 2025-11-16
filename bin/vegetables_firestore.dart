import 'dart:io';
import 'package:args/args.dart';
import 'package:vegetables_firestore/services/vegetable_importer.dart';
import 'package:vegetables_firestore/services/vegetable_exporter.dart';

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
  } catch (e) {
    print('');
    print('Error during import: $e');
    exit(1);
  }
}
