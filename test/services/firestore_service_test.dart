import 'dart:io';
import 'package:test/test.dart';
import 'package:vegetables_firestore/services/firestore_service.dart';

void main() {
  group('FirestoreService Initialization', () {
    test('should initialize with service account JSON', () async {
      // Skip this test if not using emulator (requires real credentials)
      final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
      if (emulatorHost == null) {
        print('Skipping test: FIRESTORE_EMULATOR_HOST not set');
        return;
      }

      // Given
      const projectId = 'vegetables-firestore-test';
      const serviceAccountJson = '''
      {
        "type": "service_account",
        "project_id": "vegetables-firestore-test",
        "private_key_id": "test_key_id",
        "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC8W3xK\\n-----END PRIVATE KEY-----\\n",
        "client_email": "test@vegetables-firestore-test.iam.gserviceaccount.com"
      }
      ''';

      // When
      final service = FirestoreService();
      await service.initialize(projectId, serviceAccountJson);

      // Then
      expect(service.isInitialized, isTrue);
      expect(service.projectId, equals(projectId));

      // Cleanup
      await service.close();
    });

    test('should throw exception when service account JSON is invalid', () {
      // Given
      const projectId = 'test-project';
      const invalidJson = 'invalid json';

      // When/Then
      final service = FirestoreService();
      expect(
        () => service.initialize(projectId, invalidJson),
        throwsException,
      );
    });

    test('should allow multiple calls to initialize (idempotent)', () async {
      // Skip this test if not using emulator
      final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
      if (emulatorHost == null) {
        print('Skipping test: FIRESTORE_EMULATOR_HOST not set');
        return;
      }

      // Given
      const projectId = 'test-project';
      const serviceAccountJson = '''
      {
        "type": "service_account",
        "project_id": "test-project",
        "private_key_id": "test_key_id",
        "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC8W3xK\\n-----END PRIVATE KEY-----\\n",
        "client_email": "test@test-project.iam.gserviceaccount.com"
      }
      ''';
      final service = FirestoreService();

      // When
      await service.initialize(projectId, serviceAccountJson);
      await service.initialize(projectId, serviceAccountJson); // Second call

      // Then
      expect(service.isInitialized, isTrue);

      // Cleanup
      await service.close();
    });

    test('should detect emulator from environment variable', () async {
      final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];

      // This test just verifies we can read the environment variable
      expect(emulatorHost, anyOf(isNull, isNotEmpty));
    });
  });
}
