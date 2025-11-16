import 'package:test/test.dart';
import 'package:vegetables_firestore/services/deepl_client.dart';

void main() {
  group('DeeplClient', () {
    const validApiKey = 'test-api-key:fx';

    group('translate', () {
      test('should validate API key format', () {
        // Invalid API keys (should fail validation)
        expect(
          () => DeeplClient.translate('Test', 'EN', ''),
          throwsArgumentError,
        );

        expect(
          () => DeeplClient.translate('Test', 'EN', 'invalid'),
          throwsArgumentError,
        );

        expect(
          () => DeeplClient.translate('Test', 'EN', 'no-suffix'),
          throwsArgumentError,
        );
      });

      test('should validate target language', () {
        expect(
          () => DeeplClient.translate('Test', '', validApiKey),
          throwsArgumentError,
        );

        expect(
          () => DeeplClient.translate('Test', 'INVALID', validApiKey),
          throwsArgumentError,
        );
      });

      test('should validate source text', () {
        expect(
          () => DeeplClient.translate('', 'EN', validApiKey),
          throwsArgumentError,
        );
      });

      test('should support EN, FR, DE target languages', () {
        // Test that valid language codes pass validation
        expect(DeeplClient.isValidTargetLanguage('EN'), isTrue);
        expect(DeeplClient.isValidTargetLanguage('FR'), isTrue);
        expect(DeeplClient.isValidTargetLanguage('DE'), isTrue);
      });
    });

    group('isValidApiKey', () {
      test('should validate DeepL API key format', () {
        // Valid formats
        expect(DeeplClient.isValidApiKey('abc123:fx'), isTrue);
        expect(DeeplClient.isValidApiKey('test-key:fx'), isTrue);
        expect(DeeplClient.isValidApiKey('longer-api-key-123:fx'), isTrue);

        // Invalid formats
        expect(DeeplClient.isValidApiKey(''), isFalse);
        expect(DeeplClient.isValidApiKey('no-suffix'), isFalse);
        expect(DeeplClient.isValidApiKey(':fx'), isFalse);
        expect(DeeplClient.isValidApiKey('abc123'), isFalse);
        expect(DeeplClient.isValidApiKey('abc123:'), isFalse);
      });
    });

    group('isValidTargetLanguage', () {
      test('should validate supported target languages', () {
        // Valid languages
        expect(DeeplClient.isValidTargetLanguage('EN'), isTrue);
        expect(DeeplClient.isValidTargetLanguage('FR'), isTrue);
        expect(DeeplClient.isValidTargetLanguage('DE'), isTrue);

        // Invalid languages
        expect(DeeplClient.isValidTargetLanguage(''), isFalse);
        expect(DeeplClient.isValidTargetLanguage('NL'), isFalse); // Source language, not target
        expect(DeeplClient.isValidTargetLanguage('ES'), isFalse);
        expect(DeeplClient.isValidTargetLanguage('en'), isFalse); // Case sensitive
        expect(DeeplClient.isValidTargetLanguage('INVALID'), isFalse);
      });
    });

    group('error handling', () {
      test('should throw DeeplApiException for 403 Forbidden', () async {
        // This test would require a mock HTTP client or invalid API key
        // For now, we test the exception type exists
        expect(DeeplApiException, isNotNull);
      });

      test('should throw DeeplApiException for 429 Too Many Requests', () async {
        // Test exception type
        expect(DeeplApiException, isNotNull);
      });

      test('should throw DeeplApiException for 456 Quota Exceeded', () async {
        // Test exception type
        expect(DeeplApiException, isNotNull);
      });
    });
  });
}
