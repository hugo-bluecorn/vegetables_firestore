import 'package:dart_mappable/dart_mappable.dart';

part 'vegetable.mapper.dart';

/// Harvest state of a vegetable
@MappableEnum()
enum HarvestState {
  /// Scarce availability
  scarce,

  /// Enough availability
  enough,

  /// Plenty availability
  plenty,
}

/// Translations for all harvest state values in a specific language
@MappableClass()
class HarvestStateTranslation with HarvestStateTranslationMappable {
  /// Translation for 'scarce' harvest state
  final String scarce;

  /// Translation for 'enough' harvest state
  final String enough;

  /// Translation for 'plenty' harvest state
  final String plenty;

  const HarvestStateTranslation({
    required this.scarce,
    required this.enough,
    required this.plenty,
  });

  /// Creates a HarvestStateTranslation from a Map
  static const fromMap = HarvestStateTranslationMapper.fromMap;

  /// Creates a HarvestStateTranslation from a JSON string
  static const fromJson = HarvestStateTranslationMapper.fromJson;
}

/// Translation data for a specific language
@MappableClass()
class Translation with TranslationMappable {
  /// The translated name of the vegetable
  final String name;

  /// Translations for harvest state values
  final HarvestStateTranslation harvestState;

  const Translation({
    required this.name,
    required this.harvestState,
  });

  /// Creates a Translation from a Map
  static const fromMap = TranslationMapper.fromMap;

  /// Creates a Translation from a JSON string
  static const fromJson = TranslationMapper.fromJson;
}

/// Internationalization data for all supported languages
@MappableClass()
class VegetableTranslations with VegetableTranslationsMappable {
  /// English translations
  final Translation en;

  /// Dutch translations
  final Translation nl;

  /// French translations
  final Translation fr;

  /// German translations
  final Translation de;

  const VegetableTranslations({
    required this.en,
    required this.nl,
    required this.fr,
    required this.de,
  });

  /// Creates a VegetableTranslations from a Map
  static const fromMap = VegetableTranslationsMapper.fromMap;

  /// Creates a VegetableTranslations from a JSON string
  static const fromJson = VegetableTranslationsMapper.fromJson;
}

/// A vegetable with name, timestamps, harvest state, and internationalization support
///
/// This model is based on the JSON Schema at schemas/vegetable.schema.json
/// and provides serialization/deserialization using dart_mappable.
///
/// All fields are required:
/// - [name]: The default/primary name of the vegetable (typically Dutch, 1-100 characters)
/// - [createdAt]: ISO 8601 timestamp when the vegetable was created
/// - [updatedAt]: ISO 8601 timestamp when the vegetable was last updated
/// - [harvestState]: The harvest state enum (scarce, enough, or plenty)
/// - [translations]: Internationalization data for NL, EN, FR, DE languages
@MappableClass()
class Vegetable with VegetableMappable {
  /// The default/primary name of the vegetable (typically Dutch)
  final String name;

  /// ISO 8601 timestamp when the vegetable was created
  final DateTime createdAt;

  /// ISO 8601 timestamp when the vegetable was last updated
  final DateTime updatedAt;

  /// The default harvest state of the vegetable
  final HarvestState harvestState;

  /// Internationalization data for all supported languages
  final VegetableTranslations translations;

  const Vegetable({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.harvestState,
    required this.translations,
  });

  /// Gets the localized name for the specified language code
  ///
  /// Supported language codes: 'en', 'nl', 'fr', 'de'
  /// Falls back to the primary [name] field (typically Dutch) for unsupported languages
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return translations.en.name;
      case 'nl':
        return translations.nl.name;
      case 'fr':
        return translations.fr.name;
      case 'de':
        return translations.de.name;
      default:
        return name;
    }
  }

  /// Gets the localized harvest state for the specified language code
  ///
  /// Supported language codes: 'en', 'nl', 'fr', 'de'
  /// Falls back to Dutch translation for unsupported languages
  String getLocalizedHarvestState(String languageCode) {
    final translation = _getTranslation(languageCode);
    switch (harvestState) {
      case HarvestState.scarce:
        return translation.harvestState.scarce;
      case HarvestState.enough:
        return translation.harvestState.enough;
      case HarvestState.plenty:
        return translation.harvestState.plenty;
    }
  }

  /// Gets the translation for the specified language code
  /// Falls back to Dutch for unsupported languages
  Translation _getTranslation(String languageCode) {
    switch (languageCode) {
      case 'en':
        return translations.en;
      case 'nl':
        return translations.nl;
      case 'fr':
        return translations.fr;
      case 'de':
        return translations.de;
      default:
        return translations.nl;
    }
  }

  /// Creates a Vegetable from a Map
  static const fromMap = VegetableMapper.fromMap;

  /// Creates a Vegetable from a JSON string
  static const fromJson = VegetableMapper.fromJson;
}
