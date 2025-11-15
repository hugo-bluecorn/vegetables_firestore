import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:json_schema/json_schema.dart';
import 'package:vegetables_firestore/models/vegetable.dart';

void main() {
  late JsonSchema vegetableSchema;

  setUpAll(() {
    // Load the schema for validation
    final schemaFile = File('schemas/vegetable.schema.json');
    final schemaContent = schemaFile.readAsStringSync();
    final schemaJson = json.decode(schemaContent) as Map<String, dynamic>;
    vegetableSchema = JsonSchema.create(schemaJson);
  });

  group('Test 5: Create dart_mappable model from valid JSON', () {
    test('should deserialize valid JSON to Vegetable model', () {
      final validJson = {
        'name': 'Carrot',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T10:30:00.000Z',
      };

      final vegetable = VegetableMapper.fromMap(validJson);

      expect(vegetable, isNotNull);
      expect(vegetable.name, equals('Carrot'));
      expect(vegetable.createdAt, isA<DateTime>());
      expect(vegetable.updatedAt, isA<DateTime>());
    });

    test('should parse timestamps correctly as DateTime objects', () {
      final validJson = {
        'name': 'Sweet Potato',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T12:45:30.000Z',
      };

      final vegetable = VegetableMapper.fromMap(validJson);

      expect(vegetable.createdAt.year, equals(2025));
      expect(vegetable.createdAt.month, equals(11));
      expect(vegetable.createdAt.day, equals(15));
      expect(vegetable.createdAt.hour, equals(10));
      expect(vegetable.createdAt.minute, equals(30));

      expect(vegetable.updatedAt.hour, equals(12));
      expect(vegetable.updatedAt.minute, equals(45));
    });

    test('should deserialize from JSON string', () {
      final jsonString = json.encode({
        'name': 'Tomato',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T10:30:00.000Z',
      });

      final vegetable = VegetableMapper.fromJson(jsonString);

      expect(vegetable.name, equals('Tomato'));
      expect(vegetable.createdAt, isA<DateTime>());
      expect(vegetable.updatedAt, isA<DateTime>());
    });

    test('should handle different vegetable names', () {
      final validJson = {
        'name': 'Bell Pepper',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T10:30:00.000Z',
      };

      final vegetable = VegetableMapper.fromMap(validJson);

      expect(vegetable.name, equals('Bell Pepper'));
    });
  });

  group('Test 6: Serialize dart_mappable model to valid JSON', () {
    test('should serialize Vegetable to JSON map', () {
      final vegetable = Vegetable(
        name: 'Carrot',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
      );

      final jsonMap = vegetable.toMap();

      expect(jsonMap, isA<Map<String, dynamic>>());
      expect(jsonMap['name'], equals('Carrot'));
      expect(jsonMap['createdAt'], isNotNull);
      expect(jsonMap['updatedAt'], isNotNull);
    });

    test('should produce JSON that passes schema validation', () {
      final vegetable = Vegetable(
        name: 'Sweet Potato',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T12:45:30.000Z'),
      );

      final jsonMap = vegetable.toMap();

      // Validate against schema
      final result = vegetableSchema.validate(jsonMap);
      expect(result.isValid, isTrue,
        reason: 'Serialized JSON should pass schema validation. Errors: ${result.errors}');
      expect(result.errors, isEmpty);
    });

    test('should format timestamps as ISO 8601 strings', () {
      final vegetable = Vegetable(
        name: 'Tomato',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
      );

      final jsonMap = vegetable.toMap();

      // ISO 8601 format should be a string
      expect(jsonMap['createdAt'], isA<String>());
      expect(jsonMap['updatedAt'], isA<String>());

      // Should be parseable back to DateTime
      expect(() => DateTime.parse(jsonMap['createdAt'] as String), returnsNormally);
      expect(() => DateTime.parse(jsonMap['updatedAt'] as String), returnsNormally);
    });

    test('should serialize to JSON string', () {
      final vegetable = Vegetable(
        name: 'Bell Pepper',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
      );

      final jsonString = vegetable.toJson();

      expect(jsonString, isA<String>());

      // Should be valid JSON
      final decoded = json.decode(jsonString);
      expect(decoded, isA<Map>());
      expect(decoded['name'], equals('Bell Pepper'));
    });

    test('should only include schema-defined properties', () {
      final vegetable = Vegetable(
        name: 'Kale',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
      );

      final jsonMap = vegetable.toMap();

      // Should only have the three properties defined in schema
      expect(jsonMap.keys.length, equals(3));
      expect(jsonMap.containsKey('name'), isTrue);
      expect(jsonMap.containsKey('createdAt'), isTrue);
      expect(jsonMap.containsKey('updatedAt'), isTrue);
    });
  });

  group('Test 7: Round-trip conversion maintains schema compliance', () {
    test('should maintain data through serialize/deserialize cycle', () {
      final original = Vegetable(
        name: 'Carrot',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T12:45:30.000Z'),
      );

      // Serialize to JSON
      final jsonMap = original.toMap();

      // Validate against schema
      final validationResult = vegetableSchema.validate(jsonMap);
      expect(validationResult.isValid, isTrue,
        reason: 'Intermediate JSON should pass schema validation');

      // Deserialize back to Vegetable
      final roundTripped = VegetableMapper.fromMap(jsonMap);

      // Check equality
      expect(roundTripped.name, equals(original.name));
      expect(roundTripped.createdAt.toIso8601String(),
        equals(original.createdAt.toIso8601String()));
      expect(roundTripped.updatedAt.toIso8601String(),
        equals(original.updatedAt.toIso8601String()));
    });

    test('should maintain schema compliance through multiple cycles', () {
      var vegetable = Vegetable(
        name: 'Sweet Potato',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
      );

      // Perform multiple round-trips
      for (var i = 0; i < 3; i++) {
        final jsonMap = vegetable.toMap();

        // Validate each serialization
        final result = vegetableSchema.validate(jsonMap);
        expect(result.isValid, isTrue,
          reason: 'Cycle $i: JSON should pass schema validation');

        vegetable = VegetableMapper.fromMap(jsonMap);
      }

      expect(vegetable.name, equals('Sweet Potato'));
    });

    test('should handle different timestamp values correctly', () {
      final original = Vegetable(
        name: 'Tomato',
        createdAt: DateTime.parse('2020-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2025-12-31T23:59:59.999Z'),
      );

      final jsonMap = original.toMap();
      final validationResult = vegetableSchema.validate(jsonMap);
      expect(validationResult.isValid, isTrue);

      final roundTripped = VegetableMapper.fromMap(jsonMap);

      expect(roundTripped.createdAt.year, equals(2020));
      expect(roundTripped.updatedAt.year, equals(2025));
      expect(roundTripped.updatedAt.month, equals(12));
      expect(roundTripped.updatedAt.day, equals(31));
    });

    test('should preserve name exactly through round-trip', () {
      final testNames = [
        'Carrot',
        'Sweet Potato',
        'Bell Pepper',
        'Cherry Tomato',
        'A',
        'A' * 100, // Max length
      ];

      for (final name in testNames) {
        final original = Vegetable(
          name: name,
          createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        );

        final jsonMap = original.toMap();
        final result = vegetableSchema.validate(jsonMap);
        expect(result.isValid, isTrue, reason: 'Name "$name" should be valid');

        final roundTripped = VegetableMapper.fromMap(jsonMap);
        expect(roundTripped.name, equals(name));
      }
    });
  });
}
