import 'dart:convert';
import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

class FirestoreTestHelper {
  static const String testCollection = 'vegetables_test';
  static FirebaseAdminApp? _app;
  static Firestore? _firestore;
  static final List<String> _createdDocIds = [];

  /// Initialize Firestore for testing (prompts for service account)
  static Future<Firestore> initialize() async {
    if (_firestore != null) return _firestore!;

    // Check if using emulator
    final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];

    String serviceAccountJson;

    if (emulatorHost != null) {
      print('[FirestoreTestHelper] Using emulator at $emulatorHost');

      // For emulator, we can use a dummy service account
      serviceAccountJson = '''
      {
        "type": "service_account",
        "project_id": "test-project",
        "private_key_id": "test_key_id",
        "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC8W3xK\\n-----END PRIVATE KEY-----\\n",
        "client_email": "test@test-project.iam.gserviceaccount.com",
        "client_id": "test_client_id"
      }
      ''';
    } else {
      // Prompt for service account JSON for real Firestore
      stdout.write('Enter service account JSON for testing (paste entire JSON): ');
      serviceAccountJson = stdin.readLineSync() ?? '';

      if (serviceAccountJson.isEmpty) {
        throw Exception('Service account JSON is required for Firestore tests');
      }
    }

    // Parse and create credential
    final serviceAccountData = jsonDecode(serviceAccountJson) as Map<String, dynamic>;
    final credential = Credential.fromServiceAccountParams(
      clientId: serviceAccountData['client_id'] as String? ?? '',
      privateKey: serviceAccountData['private_key'] as String,
      email: serviceAccountData['client_email'] as String,
    );

    _app = FirebaseAdminApp.initializeApp(
      'vegetables-firestore-test',
      credential,
    );

    _firestore = Firestore(_app!);
    return _firestore!;
  }

  /// Track created document for cleanup
  static void trackDocument(String docId) {
    _createdDocIds.add(docId);
  }

  /// Clean up all test documents
  static Future<void> cleanup() async {
    if (_firestore == null) return;

    for (final docId in _createdDocIds) {
      try {
        await _firestore!.collection(testCollection).doc(docId).delete();
      } catch (e) {
        // Ignore cleanup errors
      }
    }

    _createdDocIds.clear();
  }

  /// Close Firestore connection
  static Future<void> close() async {
    await cleanup();
    await _app?.close();
    _app = null;
    _firestore = null;
  }
}
