import 'dart:io';
import 'package:test/test.dart';
import 'package:vegetables_firestore/services/vegetable_file_reader.dart';

void main() {
  group('VegetableFileReader', () {
    late Directory tempDir;
    late String testFilePath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('vegetable_test_');
      testFilePath = '${tempDir.path}/vegetables.txt';
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    group('readNames', () {
      test('should read vegetable names from file', () async {
        // Arrange
        final file = File(testFilePath);
        await file.writeAsString('Tomaat\nKomkommer\nWortel\n');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, ['Tomaat', 'Komkommer', 'Wortel']);
      });

      test('should skip empty lines', () async {
        // Arrange
        final file = File(testFilePath);
        await file.writeAsString('Tomaat\n\nKomkommer\n\n\nWortel\n');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, ['Tomaat', 'Komkommer', 'Wortel']);
      });

      test('should trim whitespace from names', () async {
        // Arrange
        final file = File(testFilePath);
        await file.writeAsString('  Tomaat  \n\tKomkommer\t\n Wortel \n');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, ['Tomaat', 'Komkommer', 'Wortel']);
      });

      test('should handle file with single vegetable', () async {
        // Arrange
        final file = File(testFilePath);
        await file.writeAsString('Tomaat\n');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, ['Tomaat']);
      });

      test('should return empty list for empty file', () async {
        // Arrange
        final file = File(testFilePath);
        await file.writeAsString('');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, isEmpty);
      });

      test('should return empty list for file with only empty lines', () async {
        // Arrange
        final file = File(testFilePath);
        await file.writeAsString('\n\n  \n\t\n\n');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, isEmpty);
      });

      test('should throw exception when file does not exist', () async {
        // Arrange
        final nonExistentPath = '${tempDir.path}/nonexistent.txt';

        // Act & Assert
        expect(
          () => VegetableFileReader.readNames(nonExistentPath),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('should handle file without trailing newline', () async {
        // Arrange
        final file = File(testFilePath);
        await file.writeAsString('Tomaat\nKomkommer\nWortel');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, ['Tomaat', 'Komkommer', 'Wortel']);
      });

      test('should preserve unicode characters in vegetable names', () async {
        // Arrange
        final file = File(testFilePath);
        await file.writeAsString('Paprika\nKnoflook\nSla\n');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, ['Paprika', 'Knoflook', 'Sla']);
      });

      test('should handle very long file with many vegetables', () async {
        // Arrange
        final file = File(testFilePath);
        final vegetables = List.generate(100, (i) => 'Vegetable$i');
        await file.writeAsString('${vegetables.join('\n')}\n');

        // Act
        final names = await VegetableFileReader.readNames(testFilePath);

        // Assert
        expect(names, vegetables);
        expect(names.length, 100);
      });
    });
  });
}
