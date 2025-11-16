import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/deepl_client.dart';
import 'package:vegetables_firestore/services/harvest_state_translation_service.dart';

/// Factory for creating Vegetable objects from Dutch names
class VegetableFactory {
  /// Creates a complete Vegetable object from a Dutch name
  ///
  /// Translates the Dutch name to all supported languages (EN, FR, DE),
  /// retrieves harvest state translations, and creates a complete Vegetable
  /// with all translation data.
  ///
  /// Parameters:
  /// - [dutchName]: The Dutch name of the vegetable
  /// - [apiKey]: DeepL API key for translation
  ///
  /// Returns a [Vegetable] with:
  /// - name: Dutch name (original input)
  /// - harvestState: HarvestState.notAvailable
  /// - createdAt: Current timestamp
  /// - updatedAt: Current timestamp
  /// - translations: Complete translations for all languages
  ///
  /// Throws:
  /// - [ArgumentError] if parameters are invalid
  /// - [DeeplApiException] if translation fails
  static Future<Vegetable> fromDutchName(
    String dutchName,
    String apiKey,
  ) async {
    // Validate parameters
    if (dutchName.isEmpty) {
      throw ArgumentError('Dutch name cannot be empty');
    }

    if (!DeeplClient.isValidApiKey(apiKey)) {
      throw ArgumentError('Invalid API key format');
    }

    // Translate vegetable name to all languages
    final englishName = await DeeplClient.translate(dutchName, 'EN', apiKey);
    final frenchName = await DeeplClient.translate(dutchName, 'FR', apiKey);
    final germanName = await DeeplClient.translate(dutchName, 'DE', apiKey);

    // Get harvest state translations for all languages
    final nlHarvestStates =
        await HarvestStateTranslationService.getTranslations('NL');
    final enHarvestStates =
        await HarvestStateTranslationService.getTranslations('EN', apiKey: apiKey);
    final frHarvestStates =
        await HarvestStateTranslationService.getTranslations('FR', apiKey: apiKey);
    final deHarvestStates =
        await HarvestStateTranslationService.getTranslations('DE', apiKey: apiKey);

    // Build translations object
    final translations = VegetableTranslations(
      nl: Translation(name: dutchName, harvestState: nlHarvestStates),
      en: Translation(name: englishName, harvestState: enHarvestStates),
      fr: Translation(name: frenchName, harvestState: frHarvestStates),
      de: Translation(name: germanName, harvestState: deHarvestStates),
    );

    // Create and return Vegetable object
    return createWithTranslations(
      dutchName: dutchName,
      translations: translations,
    );
  }

  /// Creates a Vegetable with pre-built translations
  ///
  /// Useful for testing or when translations are already available.
  ///
  /// Parameters:
  /// - [dutchName]: The Dutch name of the vegetable
  /// - [translations]: Complete VegetableTranslations object
  /// - [harvestState]: Optional harvest state (defaults to notAvailable)
  /// - [createdAt]: Optional creation timestamp (defaults to now)
  /// - [updatedAt]: Optional update timestamp (defaults to now)
  ///
  /// Returns a [Vegetable] instance.
  static Vegetable createWithTranslations({
    required String dutchName,
    required VegetableTranslations translations,
    HarvestState harvestState = HarvestState.notAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();

    return Vegetable(
      name: dutchName,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      harvestState: harvestState,
      translations: translations,
    );
  }
}
