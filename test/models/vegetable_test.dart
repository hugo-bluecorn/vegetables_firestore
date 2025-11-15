import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:json_schema/json_schema.dart';
import 'package:vegetables_firestore/models/vegetable.dart';

/// Helper function to create valid translations for testing
VegetableTranslations createValidTranslations() {
  return const VegetableTranslations(
    en: Translation(
      name: 'Tomato',
      harvestState: HarvestStateTranslation(
        scarce: 'Scarce',
        enough: 'Enough',
        plenty: 'Plenty',
      ),
    ),
    nl: Translation(
      name: 'Tomaat',
      harvestState: HarvestStateTranslation(
        scarce: 'Schaars',
        enough: 'Genoeg',
        plenty: 'Overvloed',
      ),
    ),
    fr: Translation(
      name: 'Tomate',
      harvestState: HarvestStateTranslation(
        scarce: 'Rare',
        enough: 'Suffisant',
        plenty: 'Abondant',
      ),
    ),
    de: Translation(
      name: 'Tomate',
      harvestState: HarvestStateTranslation(
        scarce: 'Knapp',
        enough: 'Ausreichend',
        plenty: 'Reichlich',
      ),
    ),
  );
}

/// Helper function to create valid translations JSON for testing
Map<String, dynamic> createValidTranslationsJson() {
  return {
    'en': {
      'name': 'Tomato',
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
        'name': 'Wortel',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T10:30:00.000Z',
        'harvestState': 'enough',
        'translations': createValidTranslationsJson(),
      };

      final vegetable = VegetableMapper.fromMap(validJson);

      expect(vegetable, isNotNull);
      expect(vegetable.name, equals('Wortel'));
      expect(vegetable.createdAt, isA<DateTime>());
      expect(vegetable.updatedAt, isA<DateTime>());
      expect(vegetable.harvestState, equals(HarvestState.enough));
      expect(vegetable.translations, isA<VegetableTranslations>());
    });

    test('should parse timestamps correctly as DateTime objects', () {
      final validJson = {
        'name': 'Zoete aardappel',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T12:45:30.000Z',
        'harvestState': 'plenty',
        'translations': createValidTranslationsJson(),
      };

      final vegetable = VegetableMapper.fromMap(validJson);

      expect(vegetable.createdAt.year, equals(2025));
      expect(vegetable.createdAt.month, equals(11));
      expect(vegetable.createdAt.day, equals(15));
      expect(vegetable.createdAt.hour, equals(10));
      expect(vegetable.createdAt.minute, equals(30));

      expect(vegetable.updatedAt.hour, equals(12));
      expect(vegetable.updatedAt.minute, equals(45));
      expect(vegetable.harvestState, equals(HarvestState.plenty));
    });

    test('should deserialize from JSON string', () {
      final jsonString = json.encode({
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T10:30:00.000Z',
        'harvestState': 'scarce',
        'translations': createValidTranslationsJson(),
      });

      final vegetable = VegetableMapper.fromJson(jsonString);

      expect(vegetable.name, equals('Tomaat'));
      expect(vegetable.createdAt, isA<DateTime>());
      expect(vegetable.updatedAt, isA<DateTime>());
      expect(vegetable.harvestState, equals(HarvestState.scarce));
    });

    test('should handle different vegetable names', () {
      final validJson = {
        'name': 'Paprika',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T10:30:00.000Z',
        'harvestState': 'enough',
        'translations': createValidTranslationsJson(),
      };

      final vegetable = VegetableMapper.fromMap(validJson);

      expect(vegetable.name, equals('Paprika'));
      expect(vegetable.harvestState, equals(HarvestState.enough));
    });

    test('should deserialize all harvestState enum values', () {
      final states = {
        'scarce': HarvestState.scarce,
        'enough': HarvestState.enough,
        'plenty': HarvestState.plenty,
      };

      for (final entry in states.entries) {
        final validJson = {
          'name': 'Test Groente',
          'createdAt': '2025-11-15T10:30:00.000Z',
          'updatedAt': '2025-11-15T10:30:00.000Z',
          'harvestState': entry.key,
          'translations': createValidTranslationsJson(),
        };

        final vegetable = VegetableMapper.fromMap(validJson);
        expect(vegetable.harvestState, equals(entry.value),
          reason: 'harvestState "${entry.key}" should map to ${entry.value}');
      }
    });
  });

  group('Test 6: Serialize dart_mappable model to valid JSON', () {
    test('should serialize Vegetable to JSON map', () {
      final vegetable = Vegetable(
        name: 'Wortel',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
      );

      final jsonMap = vegetable.toMap();

      expect(jsonMap, isA<Map<String, dynamic>>());
      expect(jsonMap['name'], equals('Wortel'));
      expect(jsonMap['createdAt'], isNotNull);
      expect(jsonMap['updatedAt'], isNotNull);
      expect(jsonMap['harvestState'], equals('enough'));
      expect(jsonMap['translations'], isNotNull);
    });

    test('should produce JSON that passes schema validation', () {
      final vegetable = Vegetable(
        name: 'Zoete aardappel',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T12:45:30.000Z'),
        harvestState: HarvestState.plenty,
        translations: createValidTranslations(),
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
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.scarce,
        translations: createValidTranslations(),
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
        name: 'Paprika',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
      );

      final jsonString = vegetable.toJson();

      expect(jsonString, isA<String>());

      // Should be valid JSON
      final decoded = json.decode(jsonString);
      expect(decoded, isA<Map>());
      expect(decoded['name'], equals('Paprika'));
    });

    test('should only include schema-defined properties', () {
      final vegetable = Vegetable(
        name: 'Boerenkool',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.plenty,
        translations: createValidTranslations(),
      );

      final jsonMap = vegetable.toMap();

      // Should have the five properties defined in schema
      expect(jsonMap.keys.length, equals(5));
      expect(jsonMap.containsKey('name'), isTrue);
      expect(jsonMap.containsKey('createdAt'), isTrue);
      expect(jsonMap.containsKey('updatedAt'), isTrue);
      expect(jsonMap.containsKey('harvestState'), isTrue);
      expect(jsonMap.containsKey('translations'), isTrue);
    });

    test('should serialize all harvestState enum values correctly', () {
      final states = [HarvestState.scarce, HarvestState.enough, HarvestState.plenty];
      final expected = ['scarce', 'enough', 'plenty'];

      for (var i = 0; i < states.length; i++) {
        final vegetable = Vegetable(
          name: 'Test Groente',
          createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
          harvestState: states[i],
          translations: createValidTranslations(),
        );

        final jsonMap = vegetable.toMap();
        expect(jsonMap['harvestState'], equals(expected[i]),
          reason: '${states[i]} should serialize to "${expected[i]}"');

        // Also validate against schema
        final result = vegetableSchema.validate(jsonMap);
        expect(result.isValid, isTrue, reason: 'Serialized ${states[i]} should pass schema validation');
      }
    });
  });

  group('Test 7: Round-trip conversion maintains schema compliance', () {
    test('should maintain data through serialize/deserialize cycle', () {
      final original = Vegetable(
        name: 'Wortel',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T12:45:30.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
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
      expect(roundTripped.harvestState, equals(original.harvestState));
    });

    test('should maintain schema compliance through multiple cycles', () {
      var vegetable = Vegetable(
        name: 'Zoete aardappel',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.plenty,
        translations: createValidTranslations(),
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

      expect(vegetable.name, equals('Zoete aardappel'));
      expect(vegetable.harvestState, equals(HarvestState.plenty));
    });

    test('should handle different timestamp values correctly', () {
      final original = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2020-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2025-12-31T23:59:59.999Z'),
        harvestState: HarvestState.scarce,
        translations: createValidTranslations(),
      );

      final jsonMap = original.toMap();
      final validationResult = vegetableSchema.validate(jsonMap);
      expect(validationResult.isValid, isTrue);

      final roundTripped = VegetableMapper.fromMap(jsonMap);

      expect(roundTripped.createdAt.year, equals(2020));
      expect(roundTripped.updatedAt.year, equals(2025));
      expect(roundTripped.updatedAt.month, equals(12));
      expect(roundTripped.updatedAt.day, equals(31));
      expect(roundTripped.harvestState, equals(HarvestState.scarce));
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
          harvestState: HarvestState.enough,
          translations: createValidTranslations(),
        );

        final jsonMap = original.toMap();
        final result = vegetableSchema.validate(jsonMap);
        expect(result.isValid, isTrue, reason: 'Name "$name" should be valid');

        final roundTripped = VegetableMapper.fromMap(jsonMap);
        expect(roundTripped.name, equals(name));
        expect(roundTripped.harvestState, equals(HarvestState.enough));
      }
    });

    test('should preserve harvestState through round-trip for all enum values', () {
      final states = [HarvestState.scarce, HarvestState.enough, HarvestState.plenty];

      for (final state in states) {
        final original = Vegetable(
          name: 'Test Groente',
          createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
          harvestState: state,
          translations: createValidTranslations(),
        );

        final jsonMap = original.toMap();
        final result = vegetableSchema.validate(jsonMap);
        expect(result.isValid, isTrue, reason: 'harvestState $state should be valid');

        final roundTripped = VegetableMapper.fromMap(jsonMap);
        expect(roundTripped.harvestState, equals(state),
          reason: 'harvestState $state should be preserved');
      }
    });
  });

  group('Test 8: Translation model serialization', () {
    test('should serialize Vegetable with translations to valid JSON', () {
      final vegetable = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
      );

      final jsonMap = vegetable.toMap();

      // Validate against schema
      final result = vegetableSchema.validate(jsonMap);
      expect(result.isValid, isTrue, reason: 'JSON with translations should pass validation');
      expect(result.errors, isEmpty);

      // Check translations are present in JSON
      expect(jsonMap['translations'], isNotNull);
      expect(jsonMap['translations']['en'], isNotNull);
      expect(jsonMap['translations']['nl'], isNotNull);
      expect(jsonMap['translations']['fr'], isNotNull);
      expect(jsonMap['translations']['de'], isNotNull);
    });
  });

  group('Test 9: Translation model deserialization', () {
    test('should deserialize JSON with translations to Vegetable model', () {
      final validJson = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T10:30:00.000Z',
        'harvestState': 'enough',
        'translations': createValidTranslationsJson(),
      };

      final vegetable = VegetableMapper.fromMap(validJson);

      expect(vegetable.translations.en.name, equals('Tomato'));
      expect(vegetable.translations.nl.name, equals('Tomaat'));
      expect(vegetable.translations.fr.name, equals('Tomate'));
      expect(vegetable.translations.de.name, equals('Tomate'));
    });

    test('should deserialize harvestState translations correctly', () {
      final validJson = {
        'name': 'Tomaat',
        'createdAt': '2025-11-15T10:30:00.000Z',
        'updatedAt': '2025-11-15T10:30:00.000Z',
        'harvestState': 'enough',
        'translations': createValidTranslationsJson(),
      };

      final vegetable = VegetableMapper.fromMap(validJson);

      // Check English harvest state translations
      expect(vegetable.translations.en.harvestState.scarce, equals('Scarce'));
      expect(vegetable.translations.en.harvestState.enough, equals('Enough'));
      expect(vegetable.translations.en.harvestState.plenty, equals('Plenty'));

      // Check Dutch harvest state translations
      expect(vegetable.translations.nl.harvestState.scarce, equals('Schaars'));
      expect(vegetable.translations.nl.harvestState.enough, equals('Genoeg'));
      expect(vegetable.translations.nl.harvestState.plenty, equals('Overvloed'));

      // Check French harvest state translations
      expect(vegetable.translations.fr.harvestState.scarce, equals('Rare'));
      expect(vegetable.translations.fr.harvestState.enough, equals('Suffisant'));
      expect(vegetable.translations.fr.harvestState.plenty, equals('Abondant'));

      // Check German harvest state translations
      expect(vegetable.translations.de.harvestState.scarce, equals('Knapp'));
      expect(vegetable.translations.de.harvestState.enough, equals('Ausreichend'));
      expect(vegetable.translations.de.harvestState.plenty, equals('Reichlich'));
    });
  });

  group('Test 10: Translation round-trip serialization', () {
    test('should preserve all translation data through round-trip', () {
      final original = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
      );

      final jsonMap = original.toMap();
      final result = vegetableSchema.validate(jsonMap);
      expect(result.isValid, isTrue);

      final roundTripped = VegetableMapper.fromMap(jsonMap);

      // Verify all translations preserved
      expect(roundTripped.translations.en.name, equals(original.translations.en.name));
      expect(roundTripped.translations.nl.name, equals(original.translations.nl.name));
      expect(roundTripped.translations.fr.name, equals(original.translations.fr.name));
      expect(roundTripped.translations.de.name, equals(original.translations.de.name));

      // Verify harvest state translations preserved
      expect(roundTripped.translations.en.harvestState.scarce, equals(original.translations.en.harvestState.scarce));
      expect(roundTripped.translations.nl.harvestState.enough, equals(original.translations.nl.harvestState.enough));
      expect(roundTripped.translations.fr.harvestState.plenty, equals(original.translations.fr.harvestState.plenty));
      expect(roundTripped.translations.de.harvestState.scarce, equals(original.translations.de.harvestState.scarce));
    });
  });

  group('Test 11: Localized name retrieval', () {
    test('should return correct translation for each language code', () {
      final vegetable = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
      );

      expect(vegetable.getLocalizedName('en'), equals('Tomato'));
      expect(vegetable.getLocalizedName('nl'), equals('Tomaat'));
      expect(vegetable.getLocalizedName('fr'), equals('Tomate'));
      expect(vegetable.getLocalizedName('de'), equals('Tomate'));
    });
  });

  group('Test 12: Localized harvest state retrieval', () {
    test('should return correct harvest state translation for each language', () {
      final vegetable = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
      );

      expect(vegetable.getLocalizedHarvestState('en'), equals('Enough'));
      expect(vegetable.getLocalizedHarvestState('nl'), equals('Genoeg'));
      expect(vegetable.getLocalizedHarvestState('fr'), equals('Suffisant'));
      expect(vegetable.getLocalizedHarvestState('de'), equals('Ausreichend'));
    });

    test('should return correct translation for scarce harvest state', () {
      final vegetable = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.scarce,
        translations: createValidTranslations(),
      );

      expect(vegetable.getLocalizedHarvestState('en'), equals('Scarce'));
      expect(vegetable.getLocalizedHarvestState('nl'), equals('Schaars'));
      expect(vegetable.getLocalizedHarvestState('fr'), equals('Rare'));
      expect(vegetable.getLocalizedHarvestState('de'), equals('Knapp'));
    });

    test('should return correct translation for plenty harvest state', () {
      final vegetable = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.plenty,
        translations: createValidTranslations(),
      );

      expect(vegetable.getLocalizedHarvestState('en'), equals('Plenty'));
      expect(vegetable.getLocalizedHarvestState('nl'), equals('Overvloed'));
      expect(vegetable.getLocalizedHarvestState('fr'), equals('Abondant'));
      expect(vegetable.getLocalizedHarvestState('de'), equals('Reichlich'));
    });
  });

  group('Test 13: Fallback for unknown language codes', () {
    test('should fall back to primary name (Dutch) for unknown language code', () {
      final vegetable = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
      );

      expect(vegetable.getLocalizedName('es'), equals('Tomaat'));
      expect(vegetable.getLocalizedName('it'), equals('Tomaat'));
      expect(vegetable.getLocalizedName('unknown'), equals('Tomaat'));
    });

    test('should fall back to Dutch translation for unknown language code in harvest state', () {
      final vegetable = Vegetable(
        name: 'Tomaat',
        createdAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2025-11-15T10:30:00.000Z'),
        harvestState: HarvestState.enough,
        translations: createValidTranslations(),
      );

      expect(vegetable.getLocalizedHarvestState('es'), equals('Genoeg'));
      expect(vegetable.getLocalizedHarvestState('it'), equals('Genoeg'));
      expect(vegetable.getLocalizedHarvestState('unknown'), equals('Genoeg'));
    });
  });
}
