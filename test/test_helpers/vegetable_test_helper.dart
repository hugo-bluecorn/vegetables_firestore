import 'package:vegetables_firestore/models/vegetable.dart';

class VegetableTestHelper {
  /// Create a test vegetable with default values
  static Vegetable createTestVegetable({
    required String name,
    HarvestState harvestState = HarvestState.notAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();

    return Vegetable(
      name: name,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      harvestState: harvestState,
      translations: _createDefaultTranslations(name, harvestState),
    );
  }

  /// Create default translations for a vegetable
  static VegetableTranslations _createDefaultTranslations(
    String dutchName,
    HarvestState harvestState,
  ) {
    return VegetableTranslations(
      nl: Translation(
        name: dutchName,
        harvestState: _getHarvestStateTranslation('nl'),
      ),
      en: Translation(
        name: '$dutchName (EN)',
        harvestState: _getHarvestStateTranslation('en'),
      ),
      fr: Translation(
        name: '$dutchName (FR)',
        harvestState: _getHarvestStateTranslation('fr'),
      ),
      de: Translation(
        name: '$dutchName (DE)',
        harvestState: _getHarvestStateTranslation('de'),
      ),
    );
  }

  static HarvestStateTranslation _getHarvestStateTranslation(String lang) {
    switch (lang) {
      case 'nl':
        return const HarvestStateTranslation(
          scarce: 'Schaars',
          enough: 'Voldoende',
          plenty: 'Overvloed',
          notAvailable: 'Niet beschikbaar',
        );
      case 'en':
        return const HarvestStateTranslation(
          scarce: 'Scarce',
          enough: 'Enough',
          plenty: 'Plenty',
          notAvailable: 'Not Available',
        );
      case 'fr':
        return const HarvestStateTranslation(
          scarce: 'Rare',
          enough: 'Suffisant',
          plenty: 'Abondant',
          notAvailable: 'Non disponible',
        );
      case 'de':
        return const HarvestStateTranslation(
          scarce: 'Knapp',
          enough: 'Ausreichend',
          plenty: 'Reichlich',
          notAvailable: 'Nicht verfügbar',
        );
      default:
        throw ArgumentError('Unsupported language: $lang');
    }
  }
}
