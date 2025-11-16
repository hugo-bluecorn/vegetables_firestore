import 'package:test/test.dart';
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/harvest_state_translation_service.dart';

void main() {
  group('HarvestStateTranslationService', () {
    group('getTranslations', () {
      test('should return Dutch translations for NL without API call', () async {
        // Act
        final translations =
            await HarvestStateTranslationService.getTranslations('NL');

        // Assert
        expect(translations.scarce, 'Schaars');
        expect(translations.enough, 'Genoeg');
        expect(translations.plenty, 'Overvloed');
        expect(translations.notAvailable, 'Niet beschikbaar');
      });

      test('should throw ArgumentError for invalid language code', () {
        expect(
          () => HarvestStateTranslationService.getTranslations(''),
          throwsArgumentError,
        );

        expect(
          () => HarvestStateTranslationService.getTranslations('ES'),
          throwsArgumentError,
        );

        expect(
          () => HarvestStateTranslationService.getTranslations('nl'),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for EN/FR/DE without API key', () {
        expect(
          () => HarvestStateTranslationService.getTranslations('EN'),
          throwsArgumentError,
        );

        expect(
          () => HarvestStateTranslationService.getTranslations('FR'),
          throwsArgumentError,
        );

        expect(
          () => HarvestStateTranslationService.getTranslations('DE'),
          throwsArgumentError,
        );
      });
    });

    group('isValidLanguageCode', () {
      test('should validate supported language codes', () {
        expect(HarvestStateTranslationService.isValidLanguageCode('NL'), isTrue);
        expect(HarvestStateTranslationService.isValidLanguageCode('EN'), isTrue);
        expect(HarvestStateTranslationService.isValidLanguageCode('FR'), isTrue);
        expect(HarvestStateTranslationService.isValidLanguageCode('DE'), isTrue);

        expect(HarvestStateTranslationService.isValidLanguageCode(''), isFalse);
        expect(HarvestStateTranslationService.isValidLanguageCode('ES'), isFalse);
        expect(HarvestStateTranslationService.isValidLanguageCode('nl'), isFalse);
        expect(
          HarvestStateTranslationService.isValidLanguageCode('INVALID'),
          isFalse,
        );
      });
    });

    group('getDutchTranslations', () {
      test('should return Dutch harvest state translations', () {
        final translations =
            HarvestStateTranslationService.getDutchTranslations();

        expect(translations.scarce, 'Schaars');
        expect(translations.enough, 'Genoeg');
        expect(translations.plenty, 'Overvloed');
        expect(translations.notAvailable, 'Niet beschikbaar');
      });

      test('should return a const instance', () {
        final first = HarvestStateTranslationService.getDutchTranslations();
        final second = HarvestStateTranslationService.getDutchTranslations();

        // Should be the same instance (const)
        expect(identical(first, second), isTrue);
      });
    });

    group('clearCache', () {
      test('should clear translation cache', () {
        // This test verifies the cache can be cleared
        // Actual cache behavior will be tested in integration tests
        expect(
          () => HarvestStateTranslationService.clearCache(),
          returnsNormally,
        );
      });
    });
  });
}
