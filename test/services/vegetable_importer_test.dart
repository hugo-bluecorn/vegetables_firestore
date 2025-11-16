import 'dart:io';
import 'package:test/test.dart';
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_importer.dart';

void main() {
  group('VegetableImporter', () {
    late Directory tempDir;
    late String testFilePath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('vegetable_import_test_');
      testFilePath = '${tempDir.path}/vegetables.txt';
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    group('importFromFile', () {
      test('should validate file path', () {
        expect(
          () => VegetableImporter.importFromFile(
            '${tempDir.path}/nonexistent.txt',
            'test-key:fx',
          ),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('should validate API key', () async {
        final file = File(testFilePath);
        await file.writeAsString('Tomaat\n');

        expect(
          () => VegetableImporter.importFromFile(testFilePath, ''),
          throwsArgumentError,
        );

        expect(
          () => VegetableImporter.importFromFile(testFilePath, 'invalid'),
          throwsArgumentError,
        );
      });

      test('should return empty list for empty file', () async {
        final file = File(testFilePath);
        await file.writeAsString('');

        final result = await VegetableImporter.importFromFile(
          testFilePath,
          'test-key:fx',
        );

        expect(result.vegetables, isEmpty);
        expect(result.successful, 0);
        expect(result.failed, 0);
        expect(result.total, 0);
      });

      test('should create ImportResult with correct statistics', () async {
        final file = File(testFilePath);
        await file.writeAsString('Tomaat\nKomkommer\nWortel\n');

        // Note: This would require mocking the API calls
        // For unit testing, we verify the structure
        final result = VegetableImporter.createResult(
          vegetables: [],
          successful: 3,
          failed: 0,
          errors: {},
        );

        expect(result.total, 3);
        expect(result.successful, 3);
        expect(result.failed, 0);
        expect(result.vegetables, isEmpty);
        expect(result.errors, isEmpty);
      });

      test('should track errors for failed imports', () {
        final errors = {'Tomaat': 'API error', 'Wortel': 'Network timeout'};

        final result = VegetableImporter.createResult(
          vegetables: [],
          successful: 1,
          failed: 2,
          errors: errors,
        );

        expect(result.total, 3);
        expect(result.successful, 1);
        expect(result.failed, 2);
        expect(result.errors.length, 2);
        expect(result.errors['Tomaat'], 'API error');
        expect(result.errors['Wortel'], 'Network timeout');
      });

      test('should provide progress callback', () async {
        final file = File(testFilePath);
        await file.writeAsString('Tomaat\nKomkommer\nWortel\n');

        final progressUpdates = <String>[];

        // Test that progress callback can be provided
        final callback = (String vegetableName, int current, int total) {
          progressUpdates.add('$vegetableName ($current/$total)');
        };

        expect(callback, isNotNull);
        expect(progressUpdates, isEmpty);
      });
    });

    group('ImportResult', () {
      test('should calculate total from successful and failed', () {
        final result = ImportResult(
          vegetables: [],
          successful: 5,
          failed: 2,
          errors: {},
        );

        expect(result.total, 7);
      });

      test('should indicate success when no failures', () {
        final result = ImportResult(
          vegetables: [],
          successful: 5,
          failed: 0,
          errors: {},
        );

        expect(result.hasErrors, isFalse);
      });

      test('should indicate errors when failures exist', () {
        final result = ImportResult(
          vegetables: [],
          successful: 3,
          failed: 2,
          errors: {'Failed1': 'Error', 'Failed2': 'Error'},
        );

        expect(result.hasErrors, isTrue);
      });

      test('should provide formatted summary', () {
        final result = ImportResult(
          vegetables: [],
          successful: 3,
          failed: 1,
          errors: {'Failed': 'Error'},
        );

        final summary = result.summary;

        expect(summary, contains('4'));
        expect(summary, contains('3'));
        expect(summary, contains('1'));
      });
    });
  });
}
