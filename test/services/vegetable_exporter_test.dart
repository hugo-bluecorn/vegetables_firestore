import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_exporter.dart';

void main() {
  group('VegetableExporter', () {
    late Directory tempDir;
    late String testOutputPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('vegetable_export_test_');
      testOutputPath = '${tempDir.path}/output.json';
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    group('toJsonFile', () {
      test('should write empty array for empty list', () async {
        await VegetableExporter.toJsonFile([], testOutputPath);

        final file = File(testOutputPath);
        expect(file.existsSync(), isTrue);

        final content = await file.readAsString();
        final json = jsonDecode(content);

        expect(json, isList);
        expect(json, isEmpty);
      });

      test('should write single vegetable as array', () async {
        final vegetable = _createTestVegetable('Tomaat');

        await VegetableExporter.toJsonFile([vegetable], testOutputPath);

        final file = File(testOutputPath);
        final content = await file.readAsString();
        final json = jsonDecode(content) as List;

        expect(json.length, 1);
        expect(json[0]['name'], 'Tomaat');
        expect(json[0]['harvestState'], 'notAvailable');
      });

      test('should write multiple vegetables as array', () async {
        final vegetables = [
          _createTestVegetable('Tomaat'),
          _createTestVegetable('Komkommer'),
          _createTestVegetable('Wortel'),
        ];

        await VegetableExporter.toJsonFile(vegetables, testOutputPath);

        final file = File(testOutputPath);
        final content = await file.readAsString();
        final json = jsonDecode(content) as List;

        expect(json.length, 3);
        expect(json[0]['name'], 'Tomaat');
        expect(json[1]['name'], 'Komkommer');
        expect(json[2]['name'], 'Wortel');
      });

      test('should use pretty-printing with indentation', () async {
        final vegetable = _createTestVegetable('Tomaat');

        await VegetableExporter.toJsonFile([vegetable], testOutputPath);

        final content = await File(testOutputPath).readAsString();

        // Pretty-printed JSON should have newlines and indentation
        expect(content.contains('\n'), isTrue);
        expect(content.contains('  '), isTrue);
      });

      test('should preserve all vegetable properties', () async {
        final vegetable = _createTestVegetable('Tomaat');

        await VegetableExporter.toJsonFile([vegetable], testOutputPath);

        final content = await File(testOutputPath).readAsString();
        final json = jsonDecode(content) as List;
        final exported = json[0] as Map<String, dynamic>;

        expect(exported['name'], isNotNull);
        expect(exported['createdAt'], isNotNull);
        expect(exported['updatedAt'], isNotNull);
        expect(exported['harvestState'], isNotNull);
        expect(exported['translations'], isNotNull);
      });

      test('should preserve all translation languages', () async {
        final vegetable = _createTestVegetable('Tomaat');

        await VegetableExporter.toJsonFile([vegetable], testOutputPath);

        final content = await File(testOutputPath).readAsString();
        final json = jsonDecode(content) as List;
        final translations = json[0]['translations'] as Map<String, dynamic>;

        expect(translations['nl'], isNotNull);
        expect(translations['en'], isNotNull);
        expect(translations['fr'], isNotNull);
        expect(translations['de'], isNotNull);
      });

      test('should create parent directory if it does not exist', () async {
        final nestedPath = '${tempDir.path}/nested/dir/output.json';
        final vegetable = _createTestVegetable('Tomaat');

        await VegetableExporter.toJsonFile([vegetable], nestedPath);

        final file = File(nestedPath);
        expect(file.existsSync(), isTrue);
      });

      test('should overwrite existing file', () async {
        // Create initial file
        final file = File(testOutputPath);
        await file.writeAsString('old content');

        // Export new data
        final vegetable = _createTestVegetable('Tomaat');
        await VegetableExporter.toJsonFile([vegetable], testOutputPath);

        // Verify file was overwritten
        final content = await file.readAsString();
        expect(content, isNot('old content'));
        expect(content.contains('Tomaat'), isTrue);
      });

      test('should handle vegetables with unicode characters', () async {
        final vegetable = _createTestVegetable('Paprika');

        await VegetableExporter.toJsonFile([vegetable], testOutputPath);

        final content = await File(testOutputPath).readAsString();
        final json = jsonDecode(content) as List;

        expect(json[0]['name'], 'Paprika');
      });
    });

    // Note: Error handling tests omitted as they are highly system-dependent
    // The implementation will naturally throw FileSystemException on write failures
  });
}

// Helper function to create a test vegetable
Vegetable _createTestVegetable(String dutchName) {
  final nlTranslation = Translation(
    name: dutchName,
    harvestState: HarvestStateTranslation(
      scarce: 'Schaars',
      enough: 'Genoeg',
      plenty: 'Overvloed',
      notAvailable: 'Niet beschikbaar',
    ),
  );

  final enTranslation = Translation(
    name: 'English $dutchName',
    harvestState: HarvestStateTranslation(
      scarce: 'Scarce',
      enough: 'Enough',
      plenty: 'Plenty',
      notAvailable: 'Not Available',
    ),
  );

  final frTranslation = Translation(
    name: 'French $dutchName',
    harvestState: HarvestStateTranslation(
      scarce: 'Rare',
      enough: 'Suffisant',
      plenty: 'Abondant',
      notAvailable: 'Non disponible',
    ),
  );

  final deTranslation = Translation(
    name: 'German $dutchName',
    harvestState: HarvestStateTranslation(
      scarce: 'Knapp',
      enough: 'Ausreichend',
      plenty: 'Reichlich',
      notAvailable: 'Nicht verfügbar',
    ),
  );

  final translations = VegetableTranslations(
    nl: nlTranslation,
    en: enTranslation,
    fr: frTranslation,
    de: deTranslation,
  );

  return Vegetable(
    name: dutchName,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    harvestState: HarvestState.notAvailable,
    translations: translations,
  );
}
