import 'dart:convert';
import 'package:http/http.dart' as http;

/// Exception thrown when DeepL API request fails
class DeeplApiException implements Exception {
  final int statusCode;
  final String message;

  DeeplApiException(this.statusCode, this.message);

  @override
  String toString() => 'DeeplApiException($statusCode): $message';
}

/// Client for interacting with DeepL Translation API
class DeeplClient {
  /// DeepL Free tier endpoint
  static const String _apiEndpoint =
      'https://api-free.deepl.com/v2/translate';

  /// Supported target languages for translation
  static const Set<String> _supportedTargetLanguages = {'EN', 'FR', 'DE'};

  /// Request timeout duration
  static const Duration _timeout = Duration(seconds: 10);

  /// Maximum number of retry attempts for transient failures
  static const int _maxRetries = 3;

  /// Translates text from Dutch to the specified target language
  ///
  /// Parameters:
  /// - [text]: The text to translate (must not be empty)
  /// - [targetLang]: Target language code (EN, FR, or DE)
  /// - [apiKey]: DeepL API key (must be in format: xxx:fx)
  ///
  /// Returns the translated text.
  ///
  /// Throws:
  /// - [ArgumentError] if parameters are invalid
  /// - [DeeplApiException] if the API request fails
  static Future<String> translate(
    String text,
    String targetLang,
    String apiKey,
  ) async {
    // Validate parameters
    if (text.isEmpty) {
      throw ArgumentError('Text to translate cannot be empty');
    }

    if (!isValidApiKey(apiKey)) {
      throw ArgumentError(
        'Invalid API key format. DeepL API keys end with ":fx"',
      );
    }

    if (!isValidTargetLanguage(targetLang)) {
      throw ArgumentError(
        'Invalid target language. Supported: ${_supportedTargetLanguages.join(", ")}',
      );
    }

    // Perform translation with retry logic
    return await _translateWithRetry(text, targetLang, apiKey);
  }

  /// Internal method to translate with retry logic
  static Future<String> _translateWithRetry(
    String text,
    String targetLang,
    String apiKey, {
    int attempt = 0,
  }) async {
    try {
      return await _performTranslation(text, targetLang, apiKey);
    } catch (e) {
      if (e is DeeplApiException) {
        // Retry on transient errors (500, 503)
        if ((e.statusCode == 500 || e.statusCode == 503) &&
            attempt < _maxRetries) {
          // Exponential backoff: 2^attempt seconds
          final delay = Duration(seconds: 1 << attempt);
          await Future.delayed(delay);
          return await _translateWithRetry(
            text,
            targetLang,
            apiKey,
            attempt: attempt + 1,
          );
        }

        // Retry on rate limiting (429)
        if (e.statusCode == 429 && attempt < _maxRetries) {
          // Wait 5 seconds before retry
          await Future.delayed(const Duration(seconds: 5));
          return await _translateWithRetry(
            text,
            targetLang,
            apiKey,
            attempt: attempt + 1,
          );
        }
      }

      // Re-throw if not a retryable error or max retries exceeded
      rethrow;
    }
  }

  /// Performs the actual API translation request
  static Future<String> _performTranslation(
    String text,
    String targetLang,
    String apiKey,
  ) async {
    final uri = Uri.parse(_apiEndpoint);

    final requestBody = jsonEncode({
      'text': [text],
      'source_lang': 'NL',
      'target_lang': targetLang,
    });

    final response = await http
        .post(
          uri,
          headers: {
            'Authorization': 'DeepL-Auth-Key $apiKey',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        )
        .timeout(_timeout);

    // Handle HTTP errors
    if (response.statusCode != 200) {
      throw DeeplApiException(
        response.statusCode,
        _getErrorMessage(response.statusCode, response.body),
      );
    }

    // Parse response
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final translations = responseData['translations'] as List<dynamic>;

    if (translations.isEmpty) {
      throw DeeplApiException(
        response.statusCode,
        'No translations returned from API',
      );
    }

    final translatedText = translations[0]['text'] as String;
    return translatedText;
  }

  /// Generates user-friendly error message based on status code
  static String _getErrorMessage(int statusCode, String responseBody) {
    switch (statusCode) {
      case 403:
        return 'Invalid API key. Please check your DeepL API key.';
      case 429:
        return 'Rate limit exceeded. Too many requests.';
      case 456:
        return 'Quota exceeded. Monthly character limit reached.';
      case 500:
      case 503:
        return 'DeepL service is temporarily unavailable.';
      default:
        return 'API request failed: $responseBody';
    }
  }

  /// Validates DeepL API key format
  ///
  /// DeepL Free tier API keys end with ":fx"
  static bool isValidApiKey(String apiKey) {
    if (apiKey.isEmpty) return false;

    // Check if it ends with :fx and has content before the colon
    if (!apiKey.endsWith(':fx')) return false;

    final parts = apiKey.split(':');
    if (parts.length != 2) return false;
    if (parts[0].isEmpty) return false;

    return true;
  }

  /// Validates if the target language is supported
  static bool isValidTargetLanguage(String languageCode) {
    return _supportedTargetLanguages.contains(languageCode);
  }
}
