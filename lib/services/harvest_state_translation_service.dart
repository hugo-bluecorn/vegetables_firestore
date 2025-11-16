import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/deepl_client.dart';

/// Service for translating harvest state labels to different languages
class HarvestStateTranslationService {
  /// Supported language codes
  static const Set<String> _supportedLanguages = {'NL', 'EN', 'FR', 'DE'};

  /// Cache for translated harvest state translations
  /// Key: language code (EN, FR, DE)
  static final Map<String, HarvestStateTranslation> _cache = {};

  /// Dutch source values for harvest states
  static const String _dutchScarce = 'Schaars';
  static const String _dutchEnough = 'Genoeg';
  static const String _dutchPlenty = 'Overvloed';
  static const String _dutchNotAvailable = 'Niet beschikbaar';

  /// Gets harvest state translations for the specified language
  ///
  /// For Dutch (NL), returns the Dutch values directly without API call.
  /// For other languages (EN, FR, DE), translates using DeepL API and caches results.
  ///
  /// Parameters:
  /// - [languageCode]: Language code (NL, EN, FR, or DE)
  /// - [apiKey]: DeepL API key (required for EN, FR, DE; not used for NL)
  ///
  /// Returns a [HarvestStateTranslation] with all four harvest state labels.
  ///
  /// Throws:
  /// - [ArgumentError] if language code is invalid or API key is missing for non-NL languages
  static Future<HarvestStateTranslation> getTranslations(
    String languageCode, {
    String? apiKey,
  }) async {
    // Validate language code
    if (!isValidLanguageCode(languageCode)) {
      throw ArgumentError(
        'Invalid language code. Supported: ${_supportedLanguages.join(", ")}',
      );
    }

    // For Dutch, return directly without API call
    if (languageCode == 'NL') {
      return getDutchTranslations();
    }

    // For other languages, require API key
    if (apiKey == null || apiKey.isEmpty) {
      throw ArgumentError(
        'API key is required for translating to $languageCode',
      );
    }

    // Check cache first
    if (_cache.containsKey(languageCode)) {
      return _cache[languageCode]!;
    }

    // Translate all four harvest state labels
    final scarce = await DeeplClient.translate(_dutchScarce, languageCode, apiKey);
    final enough = await DeeplClient.translate(_dutchEnough, languageCode, apiKey);
    final plenty = await DeeplClient.translate(_dutchPlenty, languageCode, apiKey);
    final notAvailable = await DeeplClient.translate(
      _dutchNotAvailable,
      languageCode,
      apiKey,
    );

    // Create and cache the translation object
    final translation = HarvestStateTranslation(
      scarce: scarce,
      enough: enough,
      plenty: plenty,
      notAvailable: notAvailable,
    );

    _cache[languageCode] = translation;

    return translation;
  }

  /// Returns Dutch harvest state translations (no API call needed)
  static HarvestStateTranslation getDutchTranslations() {
    return const HarvestStateTranslation(
      scarce: _dutchScarce,
      enough: _dutchEnough,
      plenty: _dutchPlenty,
      notAvailable: _dutchNotAvailable,
    );
  }

  /// Validates if the language code is supported
  static bool isValidLanguageCode(String languageCode) {
    return _supportedLanguages.contains(languageCode);
  }

  /// Clears the translation cache
  ///
  /// Useful for testing or when you want to force re-translation
  static void clearCache() {
    _cache.clear();
  }
}
