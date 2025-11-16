import 'package:test/test.dart';
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_factory.dart';

void main() {
  group('VegetableFactory', () {
    const testApiKey = 'test-key:fx';

    group('fromDutchName', () {
      test('should validate Dutch name', () {
        expect(
          () => VegetableFactory.fromDutchName('', testApiKey),
          throwsArgumentError,
        );
      });

      test('should validate API key', () {
        expect(
          () => VegetableFactory.fromDutchName('Tomaat', ''),
          throwsArgumentError,
        );

        expect(
          () => VegetableFactory.fromDutchName('Tomaat', 'invalid'),
          throwsArgumentError,
        );
      });

      test('should set harvestState to notAvailable', () async {
        // Note: This test requires a valid API key to run
        // For unit testing, we'll test the structure
        final vegetable = VegetableFactory.createWithTranslations(
          dutchName: 'Tomaat',
          translations: _createMockTranslations(),
        );

        expect(vegetable.harvestState, HarvestState.notAvailable);
      });

      test('should set createdAt and updatedAt to current time', () {
        final before = DateTime.now();
        final vegetable = VegetableFactory.createWithTranslations(
          dutchName: 'Tomaat',
          translations: _createMockTranslations(),
        );
        final after = DateTime.now();

        expect(
          vegetable.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(vegetable.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);

        expect(
          vegetable.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(vegetable.updatedAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('should use Dutch name as primary name', () {
        final vegetable = VegetableFactory.createWithTranslations(
          dutchName: 'Tomaat',
          translations: _createMockTranslations(),
        );

        expect(vegetable.name, 'Tomaat');
      });

      test('should create valid VegetableTranslations structure', () {
        final vegetable = VegetableFactory.createWithTranslations(
          dutchName: 'Tomaat',
          translations: _createMockTranslations(),
        );

        expect(vegetable.translations, isNotNull);
        expect(vegetable.translations.nl, isNotNull);
        expect(vegetable.translations.en, isNotNull);
        expect(vegetable.translations.fr, isNotNull);
        expect(vegetable.translations.de, isNotNull);
      });

      test('should serialize to valid JSON', () {
        final vegetable = VegetableFactory.createWithTranslations(
          dutchName: 'Tomaat',
          translations: _createMockTranslations(),
        );

        final json = vegetable.toMap();

        expect(json['name'], 'Tomaat');
        expect(json['harvestState'], 'notAvailable');
        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
        expect(json['translations'], isNotNull);
      });

      test('should round-trip serialize/deserialize correctly', () {
        final original = VegetableFactory.createWithTranslations(
          dutchName: 'Tomaat',
          translations: _createMockTranslations(),
        );

        final json = original.toMap();
        final deserialized = Vegetable.fromMap(json);

        expect(deserialized.name, original.name);
        expect(deserialized.harvestState, original.harvestState);
        // Compare timestamps as milliseconds since epoch
        expect(
          deserialized.createdAt.millisecondsSinceEpoch,
          original.createdAt.millisecondsSinceEpoch,
        );
        expect(
          deserialized.updatedAt.millisecondsSinceEpoch,
          original.updatedAt.millisecondsSinceEpoch,
        );
      });
    });
  });
}

// Helper function to create mock translations for testing
VegetableTranslations _createMockTranslations() {
  final nlTranslation = Translation(
    name: 'Tomaat',
    harvestState: HarvestStateTranslation(
      scarce: 'Schaars',
      enough: 'Genoeg',
      plenty: 'Overvloed',
      notAvailable: 'Niet beschikbaar',
    ),
  );

  final enTranslation = Translation(
    name: 'Tomato',
    harvestState: HarvestStateTranslation(
      scarce: 'Scarce',
      enough: 'Enough',
      plenty: 'Plenty',
      notAvailable: 'Not Available',
    ),
  );

  final frTranslation = Translation(
    name: 'Tomate',
    harvestState: HarvestStateTranslation(
      scarce: 'Rare',
      enough: 'Suffisant',
      plenty: 'Abondant',
      notAvailable: 'Non disponible',
    ),
  );

  final deTranslation = Translation(
    name: 'Tomate',
    harvestState: HarvestStateTranslation(
      scarce: 'Knapp',
      enough: 'Ausreichend',
      plenty: 'Reichlich',
      notAvailable: 'Nicht verfügbar',
    ),
  );

  return VegetableTranslations(
    nl: nlTranslation,
    en: enTranslation,
    fr: frTranslation,
    de: deTranslation,
  );
}
