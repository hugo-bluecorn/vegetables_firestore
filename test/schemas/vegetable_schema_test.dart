import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:json_schema/json_schema.dart';

/// Helper function to create valid translations for testing
Map<String, dynamic> createValidTranslations() {
  return {
    'en': {
      'name': 'Tomaat',
      'harvestState': {
        'scarce': 'Scarce',
        'enough': 'Enough',
        'plenty': 'Plenty',
      },
    },
    'nl': {
      'name': 'Tomaat',
      'harvestState': {
        'scarce': 'Schaars',
        'enough': 'Genoeg',
        'plenty': 'Overvloed',
      },
    },
    'fr': {
      'name': 'Tomate',
      'harvestState': {
        'scarce': 'Rare',
        'enough': 'Suffisant',
        'plenty': 'Abondant',
      },
    },
    'de': {
      'name': 'Tomate',
      'harvestState': {
        'scarce': 'Knapp',
        'enough': 'Ausreichend',
        'plenty': 'Reichlich',
      },
    },
  };
}

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

    test('should define required fields: name, createdAt, updatedAt, harvestState, translations', () {
      final required = schemaJson['required'] as List;
      expect(required, contains('name'));
      expect(required, contains('createdAt'));
      expect(required, contains('updatedAt'));
      expect(required, contains('harvestState'));
      expect(required, contains('translations'));
      expect(required.length, equals(5));
    });

    test('should specify proper types for each field', () {
      final properties = schemaJson['properties'] as Map<String, dynamic>;

      expect(properties['name']['type'], equals('string'));
      expect(properties['createdAt']['type'], equals('string'));
      expect(properties['createdAt']['format'], equals('date-time'));
      expect(properties['updatedAt']['type'], equals('string'));
      expect(properties['updatedAt']['format'], equals('date-time'));
      expect(properties['harvestState']['type'], equals('string'));
    });

    test('should define harvestState enum with valid values', () {
      final properties = schemaJson['properties'] as Map<String, dynamic>;
      final harvestState = properties['harvestState'] as Map<String, dynamic>;

      expect(harvestState['enum'], isNotNull);
      final enumValues = harvestState['enum'] as List;
      expect(enumValues, contains('scarce'));
      expect(enumValues, contains('enough'));
      expect(enumValues, contains('plenty'));
      expect(enumValues.length, equals(3));
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
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(validVegetable);
      expect(result.isValid, isTrue, reason: 'Valid vegetable JSON should pass validation');
      expect(result.errors, isEmpty);
    });

    test('should validate vegetable with different name', () {
      final validVegetable = {
        'name': 'Zoete aardappel',
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-01T00:00:00Z',
        'harvestState': 'plenty',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(validVegetable);
      expect(result.isValid, isTrue);
    });

    test('should validate vegetable with updated timestamp different from created', () {
      final validVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:00:00Z',
        'updatedAt': '2025-11-15T12:00:00Z',
        'harvestState': 'scarce',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(validVegetable);
      expect(result.isValid, isTrue);
    });

    test('should validate all harvestState enum values', () {
      for (final state in ['scarce', 'enough', 'plenty']) {
        final validVegetable = {
          'name': 'Test Groente',
          'createdAt': '2025-11-15T10:30:00Z',
          'updatedAt': '2025-11-15T10:30:00Z',
          'harvestState': state,
          'translations': createValidTranslations(),
        };

        final result = vegetableSchema.validate(validVegetable);
        expect(result.isValid, isTrue, reason: 'harvestState "$state" should be valid');
      }
    });
  });

  group('Test 3: Validate JSON against schema - missing required fields', () {
    test('should reject JSON missing name field', () {
      final invalidVegetable = {
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThan(0));
      expect(result.errors.first.message, contains('name'));
    });

    test('should reject JSON missing createdAt field', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.first.message, contains('createdAt'));
    });

    test('should reject JSON missing updatedAt field', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.first.message, contains('updatedAt'));
    });

    test('should reject JSON missing harvestState field', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.first.message, contains('harvestState'));
    });

    test('should reject JSON missing translations field', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.first.message, contains('translations'));
    });

    test('should reject JSON missing all fields', () {
      final invalidVegetable = <String, dynamic>{};

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThanOrEqualTo(5));
    });
  });

  group('Test 4: Validate JSON against schema - invalid data types', () {
    test('should reject JSON with name as number', () {
      final invalidVegetable = {
        'name': 123,
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });

    test('should reject JSON with empty name string', () {
      final invalidVegetable = {
        'name': '',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Empty name should fail minLength constraint');
    });

    test('should reject JSON with name exceeding maxLength', () {
      final invalidVegetable = {
        'name': 'A' * 101, // 101 characters, exceeds maxLength of 100
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Name exceeding maxLength should fail');
    });

    test('should reject JSON with invalid timestamp format for createdAt', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': 'not-a-valid-timestamp',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Invalid date-time format should fail');
    });

    test('should reject JSON with timestamp as number', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': 1700000000,
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });

    test('should reject JSON with invalid harvestState value', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'abundant', // Invalid enum value
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Invalid enum value should fail');
    });

    test('should reject JSON with harvestState as number', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 1,
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'harvestState must be a string');
    });

    test('should reject JSON with empty harvestState string', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': '',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Empty string not in enum values');
    });

    test('should reject JSON with additional properties', () {
      final invalidVegetable = {
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
        'extraField': 'should not be allowed',
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Additional properties should not be allowed');
    });
  });

  group('Test 5: Translation validation - valid translations', () {
    test('should validate complete translations with all four languages', () {
      final validVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': createValidTranslations(),
      };

      final result = vegetableSchema.validate(validVegetable);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });
  });

  group('Test 6: Translation validation - missing languages', () {
    test('should reject translations missing "de" language', () {
      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': {
          'en': {
            'name': 'Tomaat',
            'harvestState': {
              'scarce': 'Scarce',
              'enough': 'Enough',
              'plenty': 'Plenty',
            },
          },
          'nl': {
            'name': 'Tomaat',
            'harvestState': {
              'scarce': 'Schaars',
              'enough': 'Genoeg',
              'plenty': 'Overvloed',
            },
          },
          'fr': {
            'name': 'Tomate',
            'harvestState': {
              'scarce': 'Rare',
              'enough': 'Suffisant',
              'plenty': 'Abondant',
            },
          },
          // Missing 'de'
        },
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });

    test('should reject translations missing "nl" language', () {
      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': {
          'en': {
            'name': 'Tomaat',
            'harvestState': {
              'scarce': 'Scarce',
              'enough': 'Enough',
              'plenty': 'Plenty',
            },
          },
          'fr': {
            'name': 'Tomate',
            'harvestState': {
              'scarce': 'Rare',
              'enough': 'Suffisant',
              'plenty': 'Abondant',
            },
          },
          'de': {
            'name': 'Tomate',
            'harvestState': {
              'scarce': 'Knapp',
              'enough': 'Ausreichend',
              'plenty': 'Reichlich',
            },
          },
          // Missing 'nl'
        },
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });
  });

  group('Test 7: Translation validation - missing translation fields', () {
    test('should reject translation missing "name" field', () {
      final translations = createValidTranslations();
      (translations['nl'] as Map<String, dynamic>).remove('name');

      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': translations,
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });

    test('should reject translation missing "harvestState" field', () {
      final translations = createValidTranslations();
      (translations['fr'] as Map<String, dynamic>).remove('harvestState');

      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': translations,
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });
  });

  group('Test 8: Translation validation - missing harvest state translations', () {
    test('should reject harvestState translation missing "plenty" value', () {
      final translations = createValidTranslations();
      final enHarvestState = (translations['en'] as Map<String, dynamic>)['harvestState'] as Map<String, dynamic>;
      enHarvestState.remove('plenty');

      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': translations,
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });

    test('should reject harvestState translation missing "scarce" value', () {
      final translations = createValidTranslations();
      final deHarvestState = (translations['de'] as Map<String, dynamic>)['harvestState'] as Map<String, dynamic>;
      deHarvestState.remove('scarce');

      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': translations,
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });

    test('should reject harvestState translation missing "enough" value', () {
      final translations = createValidTranslations();
      final nlHarvestState = (translations['nl'] as Map<String, dynamic>)['harvestState'] as Map<String, dynamic>;
      nlHarvestState.remove('enough');

      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': translations,
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse);
    });
  });

  group('Test 9: Translation validation - extra languages not allowed', () {
    test('should reject translations with extra language "es"', () {
      final translations = createValidTranslations();
      translations['es'] = {
        'name': 'Tomate',
        'harvestState': {
          'scarce': 'Escaso',
          'enough': 'Suficiente',
          'plenty': 'Abundante',
        },
      };

      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': translations,
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Additional language should not be allowed');
    });
  });

  group('Test 10: Translation validation - empty string translations', () {
    test('should reject translation with empty name string', () {
      final translations = createValidTranslations();
      (translations['en'] as Map<String, dynamic>)['name'] = '';

      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': translations,
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Empty name should fail minLength constraint');
    });

    test('should reject harvestState translation with empty string value', () {
      final translations = createValidTranslations();
      final frHarvestState = (translations['fr'] as Map<String, dynamic>)['harvestState'] as Map<String, dynamic>;
      frHarvestState['scarce'] = '';

      final invalidVegetable = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00Z',
        'updatedAt': '2025-11-15T10:30:00Z',
        'harvestState': 'enough',
        'translations': translations,
      };

      final result = vegetableSchema.validate(invalidVegetable);
      expect(result.isValid, isFalse, reason: 'Empty harvestState value should fail minLength constraint');
    });
  });
}
