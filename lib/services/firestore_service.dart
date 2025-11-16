import 'dart:convert';
import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

/// Service for managing Cloud Firestore connection using Firebase Admin SDK
class FirestoreService {
  static FirestoreService? _instance;

  FirebaseAdminApp? _app;
  Firestore? _firestore;
  String? _projectId;

  /// Singleton instance
  static FirestoreService get instance {
    _instance ??= FirestoreService._();
    return _instance!;
  }

  FirestoreService._();

  /// Factory constructor for testing
  factory FirestoreService() => instance;

  /// Check if Firestore is initialized
  bool get isInitialized => _firestore != null;

  /// Get the project ID
  String? get projectId => _projectId;

  /// Get Firestore instance
  Firestore get firestore {
    if (_firestore == null) {
      throw StateError(
          'FirestoreService not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  /// Initialize Firestore with service account credentials
  ///
  /// Automatically detects Firebase emulator from environment variables:
  /// - FIRESTORE_EMULATOR_HOST
  /// - FIREBASE_AUTH_EMULATOR_HOST
  Future<void> initialize(String projectId, String serviceAccountJson) async {
    if (_app != null && _projectId == projectId) {
      return; // Already initialized
    }

    if (_app != null) {
      await close();
    }

    try {
      final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
      if (emulatorHost != null) {
        print('[FirestoreService] Using emulator at $emulatorHost');
      }

      // Parse the service account JSON
      final serviceAccountData = jsonDecode(serviceAccountJson) as Map<String, dynamic>;

      // Create credential from the parsed data
      final credential = Credential.fromServiceAccountParams(
        clientId: serviceAccountData['client_id'] as String? ?? '',
        privateKey: serviceAccountData['private_key'] as String,
        email: serviceAccountData['client_email'] as String,
      );

      _app = FirebaseAdminApp.initializeApp(
        projectId,
        credential,
      );

      _firestore = Firestore(_app!);
      _projectId = projectId;

      print('[FirestoreService] Initialized for project: $projectId');
    } catch (e) {
      throw Exception('Failed to initialize Firestore: $e');
    }
  }

  /// Test connection health
  Future<bool> checkConnection() async {
    try {
      await _firestore?.collection('_health_check').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Close Firestore connection and cleanup
  Future<void> close() async {
    await _app?.close();
    _app = null;
    _firestore = null;
    _projectId = null;
    print('[FirestoreService] Connection closed');
  }
}
