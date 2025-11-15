import 'package:test/test.dart';
import 'package:vegetables_firestore/vegetable_validator.dart';

void main() {
  group('Vegetable Name Validator', () {
    group('Test 1: Valid vegetable names should pass validation', () {
      test('should return true for "Carrot"', () {
        expect(isValidVegetableName('Carrot'), isTrue);
      });

      test('should return true for "Sweet Potato"', () {
        expect(isValidVegetableName('Sweet Potato'), isTrue);
      });

      test('should return true for "Bell Pepper"', () {
        expect(isValidVegetableName('Bell Pepper'), isTrue);
      });

      test('should not throw exceptions for valid names', () {
        expect(() => isValidVegetableName('Tomato'), returnsNormally);
      });
    });

    group('Test 2: Empty or null names should fail validation', () {
      test('should return false for empty string', () {
        expect(isValidVegetableName(''), isFalse);
      });

      test('should return false for null value', () {
        expect(isValidVegetableName(null), isFalse);
      });

      test('should handle null gracefully without throwing', () {
        expect(() => isValidVegetableName(null), returnsNormally);
      });
    });

    group('Test 3: Names with invalid characters should fail validation', () {
      test('should return false for "Carrot123"', () {
        expect(isValidVegetableName('Carrot123'), isFalse);
      });

      test('should return false for "2Tomatoes"', () {
        expect(isValidVegetableName('2Tomatoes'), isFalse);
      });

      test('should return false for "Carrot!"', () {
        expect(isValidVegetableName('Carrot!'), isFalse);
      });

      test('should return false for "Bell@Pepper"', () {
        expect(isValidVegetableName('Bell@Pepper'), isFalse);
      });

      test('should return false for "Kale#"', () {
        expect(isValidVegetableName('Kale#'), isFalse);
      });
    });

    group('Test 4: Names exceeding length limits should fail validation', () {
      test('should return false for names longer than 50 characters', () {
        final longName = 'This is an extremely long vegetable name that exceeds fifty characters';
        expect(isValidVegetableName(longName), isFalse);
      });

      test('should return true for names exactly 50 characters', () {
        final exactlyFifty = 'A' * 50;
        expect(isValidVegetableName(exactlyFifty), isTrue);
      });

      test('should return true for names with 49 characters', () {
        final fortyNine = 'A' * 49;
        expect(isValidVegetableName(fortyNine), isTrue);
      });
    });

    group('Test 5: Names with only spaces should fail validation', () {
      test('should return false for three spaces', () {
        expect(isValidVegetableName('   '), isFalse);
      });

      test('should return false for spaces and tabs', () {
        expect(isValidVegetableName('  \t  '), isFalse);
      });

      test('should return false for single space', () {
        expect(isValidVegetableName(' '), isFalse);
      });
    });
  });
}
