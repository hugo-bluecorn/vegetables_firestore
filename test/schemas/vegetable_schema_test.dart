import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:json_schema/json_schema.dart';

void main() {
  late JsonSchema vegetableSchema;
  late Map<String, dynamic> schemaJson;

  setUpAll(() {
    // Load the schema file
    final schemaFile = File('schemas/vegetable.schema.json');
    final schemaContent = schemaFile.readAsStringSync();
    schemaJson = json.decode(schemaContent) as Map<String, dynamic>;
    vegetableSchema = JsonSchema.create(schemaJson);
  });

  group('Test 1: JSON Schema is valid and well-formed', () {
    test('should load and parse schema file successfully', () {
      expect(schemaJson, isNotNull);
      expect(schemaJson['\$schema'], equals('http://json-schema.org/draft-07/schema#'));
    });

    test('should define required fields: name, createdAt, updatedAt', () {
      final required = schemaJson['required'] as List;
      expect(required, contains('name'));
      expect(required, contains('createdAt'));
      expect(required, contains('updatedAt'));
      expect(required.length, equals(3));
    });

    test('should specify proper types for each field', () {
      final properties = schemaJson['properties'] as Map<String, dynamic>;

      expect(properties['name']['type'], equals('string'));
      expect(properties['createdAt']['type'], equals('string'));
      expect(properties['createdAt']['format'], equals('date-time'));
      expect(properties['updatedAt']['type'], equals('string'));
      expect(properties['updatedAt']['format'], equals('date-time'));
    });

    test('should have minLength and maxLength constraints for name', () {
      final properties = schemaJson['properties'] as Map<String, dynamic>;
      final nameProperty = properties['name'] as Map<String, dynamic>;

      expect(nameProperty['minLength'], equals(1));
      expect(nameProperty['maxLength'], equals(100));
    });

    test('should not allow additional properties', () {
      expect(schemaJson['additionalProperties'], equals(false));
    });
  });

  group('Test 2: Validate JSON against schema - valid vegetable', () {
    test('should validate a valid vegetable JSON', () {
      final validVegetable = {
        'name': 'Carrot',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(validVegetable);
      expect(result.isValid, isTrue, reason: 'Valid vegetable JSON should pass validation');
      expect(result.errors, isEmpty);
    });

    test('should validate vegetable with different name', () {
      final validVegetable = {
        'name': 'Sweet Potato',
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-01T00:00:00Z',
      };

      final result = vegetableSchema.validate(validVegetable);
      expect(result.isValid, isTrue);
    });

    test('should validate vegetable with updated timestamp different from created', () {
      final validVegetable = {
        'name': 'Tomato',
        'createdAt': '2025-11-15T10:00:00Z',
        'updatedAt': '2025-11-15T12:00:00Z',
      };

      final result = vegetableSchema.validate(validVegetable);
      expect(result.isValid, isTrue);
    });
  });

  group('Test 3: Validate JSON against schema - missing required fields', () {
    test('should reject JSON missing name field', () {
      final invalidVegetable = {
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThan(0));
      expect(result.errors.first.message, contains('name'));
    });

    test('should reject JSON missing createdAt field', () {
      final invalidVegetable = {
        'name': 'Carrot',
        'updatedAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.first.message, contains('createdAt'));
    });

    test('should reject JSON missing updatedAt field', () {
      final invalidVegetable = {
        'name': 'Carrot',
        'createdAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.first.message, contains('updatedAt'));
    });

    test('should reject JSON missing all fields', () {
      final invalidVegetable = <String, dynamic>{};

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThanOrEqualTo(3));
    });
  });

  group('Test 4: Validate JSON against schema - invalid data types', () {
    test('should reject JSON with name as number', () {
      final invalidVegetable = {
        'name': 123,
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });

    test('should reject JSON with empty name string', () {
      final invalidVegetable = {
        'name': '',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Empty name should fail minLength constraint');
    });

    test('should reject JSON with name exceeding maxLength', () {
      final invalidVegetable = {
        'name': 'A' * 101, // 101 characters, exceeds maxLength of 100
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Name exceeding maxLength should fail');
    });

    test('should reject JSON with invalid timestamp format for createdAt', () {
      final invalidVegetable = {
        'name': 'Carrot',
        'createdAt': 'not-a-valid-timestamp',
        'updatedAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Invalid date-time format should fail');
    });

    test('should reject JSON with timestamp as number', () {
      final invalidVegetable = {
        'name': 'Carrot',
        'createdAt': 1700000000,
        'updatedAt': '2025-11-15T10:30:00Z',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });

    test('should reject JSON with additional properties', () {
      final invalidVegetable = {
        'name': 'Carrot',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'extraField': 'should not be allowed',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Additional properties should not be allowed');
    });
  });
}
