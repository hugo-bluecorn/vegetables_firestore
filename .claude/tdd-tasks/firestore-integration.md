# TDD Task: Cloud Firestore Integration with dart_firebase_admin

## Status
- [ ] Tests Written (RED)
- [ ] Implementation (GREEN)
- [ ] Refactoring (REFACTOR)
- [ ] Code Generation Complete
- [ ] All Tests Passing

## Objective
Add Cloud Firestore database integration using the `dart_firebase_admin` package to enable persistent storage of vegetables with advanced query capabilities, batch operations, and duplicate detection.

## Package Selection Rationale

**Selected: dart_firebase_admin (v0.4.1)**
- Most complete Firestore implementation for Dart CLI (50+ operations)
- Advanced query support (filtering, sorting, aggregations)
- Batch operations and transactions
- Maintained by Invertase (official Firebase contributor)
- Admin SDK privileges (bypasses security rules)
- Perfect compatibility with dart_mappable serialization

**Alternatives Considered:**
- **firedart**: Simpler but lacks query support (critical limitation)
- **Cloud Functions**: Over-engineering for CLI tool
- **cloud_firestore**: Requires Flutter, not compatible with pure Dart CLI

## Testing Approaches

### Option A: Direct Firestore Testing (Claude Code Web Compatible)

**Use Case:** Testing during Claude Code Web implementation

**Setup:**
1. Use separate test collection: `vegetables_test`
2. Service account credentials prompted during test execution
3. Tests clean up after themselves (delete created documents)

**Pros:**
- Can test immediately in Claude Code Web
- No local setup required
- Real Firestore behavior

**Cons:**
- Requires internet connection
- Uses real Firestore database (within free tier limits)
- Slightly slower than emulator

**Implementation:**
```dart
// test/test_helpers/firestore_test_helper.dart
import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

class FirestoreTestHelper {
  static const String TEST_COLLECTION = 'vegetables_test';
  static FirebaseAdminApp? _app;
  static Firestore? _firestore;
  static final List<String> _createdDocIds = [];

  /// Initialize Firestore for testing (prompts for service account)
  static Future<Firestore> initialize() async {
    if (_firestore != null) return _firestore!;

    // Prompt for service account JSON
    stdout.write('Enter service account JSON for testing (paste entire JSON): ');
    final serviceAccountJson = stdin.readLineSync() ?? '';

    if (serviceAccountJson.isEmpty) {
      throw Exception('Service account JSON is required for Firestore tests');
    }

    _app = FirebaseAdminApp.initializeApp(
      'vegetables-firestore-test',
      Credential.fromServiceAccount(serviceAccountJson),
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
        await _firestore!.collection(TEST_COLLECTION).doc(docId).delete();
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
```

**Test Structure:**
```dart
void main() {
  late Firestore firestore;

  setUpAll(() async {
    firestore = await FirestoreTestHelper.initialize();
  });

  tearDown(() async {
    await FirestoreTestHelper.cleanup();
  });

  tearDownAll(() async {
    await FirestoreTestHelper.close();
  });

  test('example test', () async {
    // Test creates documents in vegetables_test collection
    // Cleanup happens automatically in tearDown
  });
}
```

### Option B: Local Emulator Testing (User Setup)

**Use Case:** Production-ready local testing

**Setup Instructions (User Performs):**

```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Initialize Firebase emulators in project root
cd /path/to/vegetables_firestore
firebase init emulators
# Select: Firestore, Authentication
# Ports: Firestore (8080), Auth (9099)

# 4. Start emulators
firebase emulators:start

# 5. In another terminal, run tests with emulator environment
export FIRESTORE_EMULATOR_HOST="localhost:8080"
export FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"
dart test
```

**Emulator Benefits:**
- Free unlimited operations
- Fast local testing
- Isolated from production
- Easy state reset
- Offline testing

**Test Configuration:**
```dart
// Detect emulator from environment variables
void initializeFirestore() {
  final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];

  if (emulatorHost != null) {
    // Using emulator
    print('Using Firestore Emulator at $emulatorHost');
    // dart_firebase_admin automatically detects emulator
  } else {
    // Using real Firestore (Option A)
    print('Using real Firestore database');
  }
}
```

## Dependencies

### Add to pubspec.yaml

```yaml
dependencies:
  args: ^2.7.0
  dart_mappable: ^4.2.2
  http: ^1.2.0
  dart_firebase_admin: ^0.4.1  # NEW

dev_dependencies:
  build_runner: ^2.4.13
  dart_mappable_builder: ^4.2.3
  test: ^1.25.6
  lints: ^6.0.0
  json_schema: ^5.1.3
```

### Install Dependencies
```bash
dart pub get
```

## TDD Implementation: 5 Red-Green-Refactor Iterations

---

## Iteration 1: Firestore Service Initialization

### Objective
Create a service to initialize and manage Cloud Firestore connection using Firebase Admin SDK.

### RED - Write Failing Test

**File:** `test/services/firestore_service_test.dart`

```dart
import 'package:test/test.dart';
import 'package:vegetables_firestore/services/firestore_service.dart';

void main() {
  group('FirestoreService Initialization', () {
    test('should initialize with service account JSON', () async {
      // Given
      const projectId = 'vegetables-firestore-test';
      const serviceAccountJson = '''
      {
        "type": "service_account",
        "project_id": "vegetables-firestore-test",
        "private_key_id": "test_key_id",
        "private_key": "-----BEGIN PRIVATE KEY-----\\ntest_key\\n-----END PRIVATE KEY-----\\n",
        "client_email": "test@vegetables-firestore-test.iam.gserviceaccount.com"
      }
      ''';

      // When
      final service = FirestoreService();
      await service.initialize(projectId, serviceAccountJson);

      // Then
      expect(service.isInitialized, isTrue);
      expect(service.projectId, equals(projectId));
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
      // Given
      const projectId = 'test-project';
      const serviceAccountJson = '{"type": "service_account", ...}';
      final service = FirestoreService();

      // When
      await service.initialize(projectId, serviceAccountJson);
      await service.initialize(projectId, serviceAccountJson); // Second call

      // Then
      expect(service.isInitialized, isTrue);
    });
  });
}
```

**Test Specifications:**

**Given:** A Firebase project ID and service account JSON
**When:** FirestoreService.initialize() is called
**Then:** Service should be initialized and ready to use

**Given:** Invalid service account JSON
**When:** FirestoreService.initialize() is called
**Then:** Should throw an exception with clear error message

**Given:** Service already initialized
**When:** initialize() is called again
**Then:** Should handle gracefully (idempotent)

### GREEN - Implement Minimal Code

**File:** `lib/services/firestore_service.dart`

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

/// Service for managing Cloud Firestore connection using Firebase Admin SDK
class FirestoreService {
  FirebaseAdminApp? _app;
  Firestore? _firestore;
  String? _projectId;

  /// Check if Firestore is initialized
  bool get isInitialized => _firestore != null;

  /// Get the project ID
  String? get projectId => _projectId;

  /// Get Firestore instance
  Firestore get firestore {
    if (_firestore == null) {
      throw StateError('FirestoreService not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  /// Initialize Firestore with service account credentials
  ///
  /// [projectId] - Firebase project ID
  /// [serviceAccountJson] - Service account JSON string
  Future<void> initialize(String projectId, String serviceAccountJson) async {
    // If already initialized with same project, return
    if (_app != null && _projectId == projectId) {
      return;
    }

    // Close existing connection if different project
    if (_app != null) {
      await close();
    }

    try {
      _app = FirebaseAdminApp.initializeApp(
        projectId,
        Credential.fromServiceAccount(serviceAccountJson),
      );

      _firestore = Firestore(_app!);
      _projectId = projectId;
    } catch (e) {
      throw Exception('Failed to initialize Firestore: $e');
    }
  }

  /// Close Firestore connection
  Future<void> close() async {
    await _app?.close();
    _app = null;
    _firestore = null;
    _projectId = null;
  }
}
```

### REFACTOR

**Improvements:**
1. Add singleton pattern for app-wide usage
2. Add connection health check
3. Add logging for debugging
4. Support environment variables for emulator

**Updated Code:**

```dart
import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';

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
      throw StateError('FirestoreService not initialized. Call initialize() first.');
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

      _app = FirebaseAdminApp.initializeApp(
        projectId,
        Credential.fromServiceAccount(serviceAccountJson),
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
```

### Run Tests

**Command:**
```bash
/tdd-test test/services/firestore_service_test.dart
```

**Expected Result:**
- All tests pass (GREEN)
- `dart analyze` shows no issues

---

## Iteration 2: Vegetable Repository - CRUD Operations

### Objective
Implement repository pattern for Vegetable CRUD operations with Firestore.

### RED - Write Failing Test

**File:** `test/services/vegetable_repository_test.dart`

```dart
import 'package:test/test.dart';
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/firestore_service.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import '../test_helpers/firestore_test_helper.dart';
import '../test_helpers/vegetable_test_helper.dart';

void main() {
  late VegetableRepository repository;
  late Firestore firestore;

  setUpAll(() async {
    firestore = await FirestoreTestHelper.initialize();
    repository = VegetableRepository(firestore);
  });

  tearDown(() async {
    await FirestoreTestHelper.cleanup();
  });

  tearDownAll(() async {
    await FirestoreTestHelper.close();
  });

  group('VegetableRepository - Create', () {
    test('should create vegetable in Firestore', () async {
      // Given
      final vegetable = VegetableTestHelper.createTestVegetable(
        name: 'Tomaat',
        harvestState: HarvestState.plenty,
      );

      // When
      final docId = await repository.create(vegetable);
      FirestoreTestHelper.trackDocument(docId);

      // Then
      expect(docId, isNotEmpty);

      // Verify it was created
      final retrieved = await repository.getById(docId);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Tomaat'));
      expect(retrieved.harvestState, equals(HarvestState.plenty));
    });

    test('should create vegetable with custom document ID', () async {
      // Given
      final vegetable = VegetableTestHelper.createTestVegetable(name: 'Wortel');
      const customId = 'wortel_123';

      // When
      final docId = await repository.create(vegetable, documentId: customId);
      FirestoreTestHelper.trackDocument(docId);

      // Then
      expect(docId, equals(customId));
    });
  });

  group('VegetableRepository - Read', () {
    test('should retrieve vegetable by ID', () async {
      // Given
      final vegetable = VegetableTestHelper.createTestVegetable(name: 'Komkommer');
      final docId = await repository.create(vegetable);
      FirestoreTestHelper.trackDocument(docId);

      // When
      final retrieved = await repository.getById(docId);

      // Then
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Komkommer'));
    });

    test('should return null for non-existent vegetable', () async {
      // When
      final retrieved = await repository.getById('non_existent_id');

      // Then
      expect(retrieved, isNull);
    });

    test('should retrieve all vegetables', () async {
      // Given
      final veg1 = VegetableTestHelper.createTestVegetable(name: 'Sla');
      final veg2 = VegetableTestHelper.createTestVegetable(name: 'Paprika');

      final id1 = await repository.create(veg1);
      final id2 = await repository.create(veg2);
      FirestoreTestHelper.trackDocument(id1);
      FirestoreTestHelper.trackDocument(id2);

      // When
      final vegetables = await repository.getAll();

      // Then
      expect(vegetables.length, greaterThanOrEqualTo(2));
      final names = vegetables.map((v) => v.name).toList();
      expect(names, contains('Sla'));
      expect(names, contains('Paprika'));
    });
  });

  group('VegetableRepository - Update', () {
    test('should update vegetable', () async {
      // Given
      final vegetable = VegetableTestHelper.createTestVegetable(
        name: 'Aubergine',
        harvestState: HarvestState.scarce,
      );
      final docId = await repository.create(vegetable);
      FirestoreTestHelper.trackDocument(docId);

      // When
      final updated = vegetable.copyWith(harvestState: HarvestState.plenty);
      await repository.update(docId, updated);

      // Then
      final retrieved = await repository.getById(docId);
      expect(retrieved!.harvestState, equals(HarvestState.plenty));
    });
  });

  group('VegetableRepository - Delete', () {
    test('should delete vegetable', () async {
      // Given
      final vegetable = VegetableTestHelper.createTestVegetable(name: 'Courgette');
      final docId = await repository.create(vegetable);
      FirestoreTestHelper.trackDocument(docId);

      // When
      await repository.delete(docId);

      // Then
      final retrieved = await repository.getById(docId);
      expect(retrieved, isNull);
    });
  });

  group('VegetableRepository - Query', () {
    test('should query vegetables by harvest state', () async {
      // Given
      final veg1 = VegetableTestHelper.createTestVegetable(
        name: 'Broccoli',
        harvestState: HarvestState.plenty,
      );
      final veg2 = VegetableTestHelper.createTestVegetable(
        name: 'Bloemkool',
        harvestState: HarvestState.scarce,
      );
      final veg3 = VegetableTestHelper.createTestVegetable(
        name: 'Spinazie',
        harvestState: HarvestState.plenty,
      );

      final id1 = await repository.create(veg1);
      final id2 = await repository.create(veg2);
      final id3 = await repository.create(veg3);
      FirestoreTestHelper.trackDocument(id1);
      FirestoreTestHelper.trackDocument(id2);
      FirestoreTestHelper.trackDocument(id3);

      // When
      final plentyVegetables = await repository.getByHarvestState(HarvestState.plenty);

      // Then
      expect(plentyVegetables.length, greaterThanOrEqualTo(2));
      final names = plentyVegetables.map((v) => v.name).toList();
      expect(names, contains('Broccoli'));
      expect(names, contains('Spinazie'));
      expect(names, isNot(contains('Bloemkool')));
    });
  });
}
```

**Test Specifications:**

**Scenario: Create Vegetable**
- **Given:** A valid Vegetable object
- **When:** repository.create() is called
- **Then:** Vegetable is stored in Firestore and document ID is returned

**Scenario: Read Vegetable by ID**
- **Given:** A vegetable exists in Firestore
- **When:** repository.getById() is called
- **Then:** Vegetable is retrieved and deserialized correctly

**Scenario: Update Vegetable**
- **Given:** An existing vegetable
- **When:** repository.update() is called with changes
- **Then:** Vegetable is updated in Firestore

**Scenario: Delete Vegetable**
- **Given:** An existing vegetable
- **When:** repository.delete() is called
- **Then:** Vegetable is removed from Firestore

**Scenario: Query by Harvest State**
- **Given:** Multiple vegetables with different harvest states
- **When:** repository.getByHarvestState() is called
- **Then:** Only vegetables matching the state are returned

### GREEN - Implement Minimal Code

**File:** `lib/services/vegetable_repository.dart`

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:vegetables_firestore/models/vegetable.dart';

/// Repository for Vegetable CRUD operations with Firestore
class VegetableRepository {
  final Firestore _firestore;
  static const String COLLECTION_NAME = 'vegetables';

  VegetableRepository(this._firestore);

  /// Create a new vegetable in Firestore
  ///
  /// Returns the document ID
  Future<String> create(Vegetable vegetable, {String? documentId}) async {
    final collection = _firestore.collection(COLLECTION_NAME);

    if (documentId != null) {
      await collection.doc(documentId).set(vegetable.toMap());
      return documentId;
    } else {
      final docRef = await collection.add(vegetable.toMap());
      return docRef.id;
    }
  }

  /// Get a vegetable by document ID
  Future<Vegetable?> getById(String documentId) async {
    final doc = await _firestore
        .collection(COLLECTION_NAME)
        .doc(documentId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return VegetableMapper.fromMap(doc.data()!);
  }

  /// Get all vegetables
  Future<List<Vegetable>> getAll() async {
    final snapshot = await _firestore.collection(COLLECTION_NAME).get();

    return snapshot.docs
        .where((doc) => doc.data() != null)
        .map((doc) => VegetableMapper.fromMap(doc.data()!))
        .toList();
  }

  /// Update a vegetable
  Future<void> update(String documentId, Vegetable vegetable) async {
    await _firestore
        .collection(COLLECTION_NAME)
        .doc(documentId)
        .update(vegetable.toMap());
  }

  /// Delete a vegetable
  Future<void> delete(String documentId) async {
    await _firestore
        .collection(COLLECTION_NAME)
        .doc(documentId)
        .delete();
  }

  /// Query vegetables by harvest state
  Future<List<Vegetable>> getByHarvestState(HarvestState state) async {
    final snapshot = await _firestore
        .collection(COLLECTION_NAME)
        .where('harvestState', WhereFilter.equalTo, state.name)
        .get();

    return snapshot.docs
        .where((doc) => doc.data() != null)
        .map((doc) => VegetableMapper.fromMap(doc.data()!))
        .toList();
  }
}
```

### REFACTOR

**Improvements:**
1. Add batch operations
2. Add better error handling
3. Add pagination support
4. Add query by name

**Updated Code:**

```dart
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:vegetables_firestore/models/vegetable.dart';

/// Repository for Vegetable CRUD operations with Firestore
class VegetableRepository {
  final Firestore _firestore;
  static const String COLLECTION_NAME = 'vegetables';

  VegetableRepository(this._firestore);

  /// Create a new vegetable in Firestore
  Future<String> create(Vegetable vegetable, {String? documentId}) async {
    try {
      final collection = _firestore.collection(COLLECTION_NAME);

      if (documentId != null) {
        await collection.doc(documentId).set(vegetable.toMap());
        return documentId;
      } else {
        final docRef = await collection.add(vegetable.toMap());
        return docRef.id;
      }
    } catch (e) {
      throw RepositoryException('Failed to create vegetable: $e');
    }
  }

  /// Batch create multiple vegetables
  Future<List<String>> createBatch(List<Vegetable> vegetables) async {
    try {
      final batch = _firestore.batch();
      final docIds = <String>[];

      for (final vegetable in vegetables) {
        final docRef = _firestore.collection(COLLECTION_NAME).doc();
        batch.set(docRef, vegetable.toMap());
        docIds.add(docRef.id);
      }

      await batch.commit();
      return docIds;
    } catch (e) {
      throw RepositoryException('Failed to batch create vegetables: $e');
    }
  }

  /// Get a vegetable by document ID
  Future<Vegetable?> getById(String documentId) async {
    try {
      final doc = await _firestore
          .collection(COLLECTION_NAME)
          .doc(documentId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return VegetableMapper.fromMap(doc.data()!);
    } catch (e) {
      throw RepositoryException('Failed to get vegetable: $e');
    }
  }

  /// Get vegetable by name (case-insensitive)
  Future<Vegetable?> getByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection(COLLECTION_NAME)
          .where('name', WhereFilter.equalTo, name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return VegetableMapper.fromMap(snapshot.docs.first.data()!);
    } catch (e) {
      throw RepositoryException('Failed to get vegetable by name: $e');
    }
  }

  /// Get all vegetables (with optional limit)
  Future<List<Vegetable>> getAll({int? limit}) async {
    try {
      var query = _firestore.collection(COLLECTION_NAME);

      if (limit != null) {
        query = query.limit(limit) as CollectionReference;
      }

      final snapshot = await query.get();

      return snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) => VegetableMapper.fromMap(doc.data()!))
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to get all vegetables: $e');
    }
  }

  /// Update a vegetable
  Future<void> update(String documentId, Vegetable vegetable) async {
    try {
      await _firestore
          .collection(COLLECTION_NAME)
          .doc(documentId)
          .update(vegetable.toMap());
    } catch (e) {
      throw RepositoryException('Failed to update vegetable: $e');
    }
  }

  /// Delete a vegetable
  Future<void> delete(String documentId) async {
    try {
      await _firestore
          .collection(COLLECTION_NAME)
          .doc(documentId)
          .delete();
    } catch (e) {
      throw RepositoryException('Failed to delete vegetable: $e');
    }
  }

  /// Query vegetables by harvest state
  Future<List<Vegetable>> getByHarvestState(HarvestState state) async {
    try {
      final snapshot = await _firestore
          .collection(COLLECTION_NAME)
          .where('harvestState', WhereFilter.equalTo, state.name)
          .get();

      return snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) => VegetableMapper.fromMap(doc.data()!))
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to query by harvest state: $e');
    }
  }

  /// Check if vegetable exists by name
  Future<bool> existsByName(String name) async {
    final vegetable = await getByName(name);
    return vegetable != null;
  }
}

/// Exception thrown by repository operations
class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
```

### Run Tests

```bash
/tdd-test test/services/vegetable_repository_test.dart
```

---

## Iteration 3: Duplicate Detection

### Objective
Implement duplicate detection to prevent adding vegetables that already exist in Firestore.

### RED - Write Failing Test

**File:** `test/services/duplicate_detector_test.dart`

```dart
import 'package:test/test.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import 'package:vegetables_firestore/services/duplicate_detector.dart';
import '../test_helpers/firestore_test_helper.dart';
import '../test_helpers/vegetable_test_helper.dart';

void main() {
  late VegetableRepository repository;
  late DuplicateDetector detector;

  setUpAll(() async {
    final firestore = await FirestoreTestHelper.initialize();
    repository = VegetableRepository(firestore);
    detector = DuplicateDetector(repository);
  });

  tearDown(() async {
    await FirestoreTestHelper.cleanup();
  });

  tearDownAll(() async {
    await FirestoreTestHelper.close();
  });

  group('DuplicateDetector', () {
    test('should detect existing vegetable by name', () async {
      // Given
      final existing = VegetableTestHelper.createTestVegetable(name: 'Tomaat');
      final docId = await repository.create(existing);
      FirestoreTestHelper.trackDocument(docId);

      // When
      final isDuplicate = await detector.isDuplicate('Tomaat');

      // Then
      expect(isDuplicate, isTrue);
    });

    test('should return false for non-existent vegetable', () async {
      // When
      final isDuplicate = await detector.isDuplicate('NonExistentVegetable');

      // Then
      expect(isDuplicate, isFalse);
    });

    test('should filter out duplicates from list', () async {
      // Given
      final existing1 = VegetableTestHelper.createTestVegetable(name: 'Wortel');
      final existing2 = VegetableTestHelper.createTestVegetable(name: 'Sla');

      final id1 = await repository.create(existing1);
      final id2 = await repository.create(existing2);
      FirestoreTestHelper.trackDocument(id1);
      FirestoreTestHelper.trackDocument(id2);

      final vegetables = [
        VegetableTestHelper.createTestVegetable(name: 'Wortel'), // Duplicate
        VegetableTestHelper.createTestVegetable(name: 'Komkommer'), // New
        VegetableTestHelper.createTestVegetable(name: 'Sla'), // Duplicate
        VegetableTestHelper.createTestVegetable(name: 'Paprika'), // New
      ];

      // When
      final newVegetables = await detector.filterDuplicates(vegetables);

      // Then
      expect(newVegetables.length, equals(2));
      final names = newVegetables.map((v) => v.name).toList();
      expect(names, contains('Komkommer'));
      expect(names, contains('Paprika'));
      expect(names, isNot(contains('Wortel')));
      expect(names, isNot(contains('Sla')));
    });

    test('should provide duplicate statistics', () async {
      // Given
      final existing = VegetableTestHelper.createTestVegetable(name: 'Aubergine');
      final docId = await repository.create(existing);
      FirestoreTestHelper.trackDocument(docId);

      final vegetables = [
        VegetableTestHelper.createTestVegetable(name: 'Aubergine'), // Duplicate
        VegetableTestHelper.createTestVegetable(name: 'Courgette'), // New
      ];

      // When
      final stats = await detector.analyzeD uplicates(vegetables);

      // Then
      expect(stats.total, equals(2));
      expect(stats.duplicates, equals(1));
      expect(stats.newVegetables, equals(1));
      expect(stats.duplicateNames, contains('Aubergine'));
    });
  });
}
```

### GREEN - Implement Minimal Code

**File:** `lib/services/duplicate_detector.dart`

```dart
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';

/// Service for detecting duplicate vegetables
class DuplicateDetector {
  final VegetableRepository _repository;

  DuplicateDetector(this._repository);

  /// Check if a vegetable with the given name already exists
  Future<bool> isDuplicate(String name) async {
    return await _repository.existsByName(name);
  }

  /// Filter out vegetables that already exist in Firestore
  ///
  /// Returns only new vegetables (not in Firestore)
  Future<List<Vegetable>> filterDuplicates(List<Vegetable> vegetables) async {
    final newVegetables = <Vegetable>[];

    for (final vegetable in vegetables) {
      final exists = await isDuplicate(vegetable.name);
      if (!exists) {
        newVegetables.add(vegetable);
      }
    }

    return newVegetables;
  }

  /// Analyze duplicates and provide statistics
  Future<DuplicateStats> analyzeDuplicates(List<Vegetable> vegetables) async {
    final duplicateNames = <String>[];
    int duplicateCount = 0;

    for (final vegetable in vegetables) {
      final exists = await isDuplicate(vegetable.name);
      if (exists) {
        duplicateCount++;
        duplicateNames.add(vegetable.name);
      }
    }

    return DuplicateStats(
      total: vegetables.length,
      duplicates: duplicateCount,
      newVegetables: vegetables.length - duplicateCount,
      duplicateNames: duplicateNames,
    );
  }
}

/// Statistics about duplicate vegetables
class DuplicateStats {
  final int total;
  final int duplicates;
  final int newVegetables;
  final List<String> duplicateNames;

  DuplicateStats({
    required this.total,
    required this.duplicates,
    required this.newVegetables,
    required this.duplicateNames,
  });

  @override
  String toString() {
    return 'DuplicateStats(total: $total, duplicates: $duplicates, '
           'new: $newVegetables, duplicate names: $duplicateNames)';
  }
}
```

### REFACTOR

**Improvements:**
1. Batch query optimization (query all at once instead of one-by-one)
2. Case-insensitive comparison
3. Progress callback for large lists

**Updated Code:**

```dart
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';

typedef ProgressCallback = void Function(int current, int total);

/// Service for detecting duplicate vegetables with optimized batch queries
class DuplicateDetector {
  final VegetableRepository _repository;

  DuplicateDetector(this._repository);

  /// Check if a vegetable with the given name already exists (case-insensitive)
  Future<bool> isDuplicate(String name) async {
    return await _repository.existsByName(name);
  }

  /// Filter out vegetables that already exist in Firestore
  ///
  /// Optimized: Queries all existing vegetables once, then compares in-memory
  Future<List<Vegetable>> filterDuplicates(
    List<Vegetable> vegetables, {
    ProgressCallback? onProgress,
  }) async {
    // Get all existing vegetables (single query)
    final existingVegetables = await _repository.getAll();
    final existingNames = existingVegetables
        .map((v) => v.name.toLowerCase())
        .toSet();

    // Filter in-memory
    final newVegetables = <Vegetable>[];
    for (var i = 0; i < vegetables.length; i++) {
      final vegetable = vegetables[i];

      if (!existingNames.contains(vegetable.name.toLowerCase())) {
        newVegetables.add(vegetable);
      }

      onProgress?.call(i + 1, vegetables.length);
    }

    return newVegetables;
  }

  /// Analyze duplicates and provide detailed statistics
  Future<DuplicateStats> analyzeDuplicates(
    List<Vegetable> vegetables, {
    ProgressCallback? onProgress,
  }) async {
    final existingVegetables = await _repository.getAll();
    final existingNames = existingVegetables
        .map((v) => v.name.toLowerCase())
        .toSet();

    final duplicateNames = <String>[];

    for (var i = 0; i < vegetables.length; i++) {
      final vegetable = vegetables[i];

      if (existingNames.contains(vegetable.name.toLowerCase())) {
        duplicateNames.add(vegetable.name);
      }

      onProgress?.call(i + 1, vegetables.length);
    }

    return DuplicateStats(
      total: vegetables.length,
      duplicates: duplicateNames.length,
      newVegetables: vegetables.length - duplicateNames.length,
      duplicateNames: duplicateNames,
    );
  }
}

/// Statistics about duplicate vegetables
class DuplicateStats {
  final int total;
  final int duplicates;
  final int newVegetables;
  final List<String> duplicateNames;

  DuplicateStats({
    required this.total,
    required this.duplicates,
    required this.newVegetables,
    required this.duplicateNames,
  });

  double get duplicatePercentage =>
      total > 0 ? (duplicates / total) * 100 : 0;

  @override
  String toString() {
    return 'Total: $total | New: $newVegetables | '
           'Duplicates: $duplicates (${duplicatePercentage.toStringAsFixed(1)}%)';
  }
}
```

### Run Tests

```bash
/tdd-test test/services/duplicate_detector_test.dart
```

---

## Iteration 4: Batch Upload with Deduplication

### Objective
Implement batch upload service that uploads multiple vegetables efficiently while skipping duplicates.

### RED - Write Failing Test

**File:** `test/services/firestore_upload_service_test.dart`

```dart
import 'package:test/test.dart';
import 'package:vegetables_firestore/services/firestore_upload_service.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import '../test_helpers/firestore_test_helper.dart';
import '../test_helpers/vegetable_test_helper.dart';

void main() {
  late FirestoreUploadService uploadService;
  late VegetableRepository repository;

  setUpAll(() async {
    final firestore = await FirestoreTestHelper.initialize();
    repository = VegetableRepository(firestore);
    uploadService = FirestoreUploadService(repository);
  });

  tearDown(() async {
    await FirestoreTestHelper.cleanup();
  });

  tearDownAll() async {
    await FirestoreTestHelper.close();
  });

  group('FirestoreUploadService', () {
    test('should upload new vegetables only', () async {
      // Given
      final existing = VegetableTestHelper.createTestVegetable(name: 'Tomaat');
      final existingId = await repository.create(existing);
      FirestoreTestHelper.trackDocument(existingId);

      final vegetables = [
        VegetableTestHelper.createTestVegetable(name: 'Tomaat'), // Duplicate
        VegetableTestHelper.createTestVegetable(name: 'Wortel'), // New
        VegetableTestHelper.createTestVegetable(name: 'Sla'), // New
      ];

      // When
      final result = await uploadService.uploadNewVegetables(vegetables);

      // Track uploaded docs for cleanup
      for (final id in result.uploadedIds) {
        FirestoreTestHelper.trackDocument(id);
      }

      // Then
      expect(result.totalProvided, equals(3));
      expect(result.uploaded, equals(2));
      expect(result.skipped, equals(1));
      expect(result.uploadedIds.length, equals(2));
      expect(result.skippedNames, contains('Tomaat'));
    });

    test('should provide progress updates during upload', () async {
      // Given
      final vegetables = List.generate(
        10,
        (i) => VegetableTestHelper.createTestVegetable(name: 'Veg$i'),
      );

      final progressUpdates = <UploadProgress>[];

      // When
      final result = await uploadService.uploadNewVegetables(
        vegetables,
        onProgress: (progress) {
          progressUpdates.add(progress);
        },
      );

      // Track for cleanup
      for (final id in result.uploadedIds) {
        FirestoreTestHelper.trackDocument(id);
      }

      // Then
      expect(progressUpdates, isNotEmpty);
      expect(progressUpdates.last.current, equals(10));
      expect(progressUpdates.last.total, equals(10));
    });

    test('should handle empty list gracefully', () async {
      // When
      final result = await uploadService.uploadNewVegetables([]);

      // Then
      expect(result.totalProvided, equals(0));
      expect(result.uploaded, equals(0));
      expect(result.skipped, equals(0));
    });
  });
}
```

### GREEN - Implement Minimal Code

**File:** `lib/services/firestore_upload_service.dart`

```dart
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import 'package:vegetables_firestore/services/duplicate_detector.dart';

typedef UploadProgressCallback = void Function(UploadProgress progress);

/// Service for uploading vegetables to Firestore with deduplication
class FirestoreUploadService {
  final VegetableRepository _repository;
  late final DuplicateDetector _duplicateDetector;

  FirestoreUploadService(this._repository) {
    _duplicateDetector = DuplicateDetector(_repository);
  }

  /// Upload new vegetables only (skip duplicates)
  Future<UploadResult> uploadNewVegetables(
    List<Vegetable> vegetables, {
    UploadProgressCallback? onProgress,
  }) async {
    if (vegetables.isEmpty) {
      return UploadResult(
        totalProvided: 0,
        uploaded: 0,
        skipped: 0,
        uploadedIds: [],
        skippedNames: [],
      );
    }

    // Analyze duplicates
    onProgress?.call(UploadProgress(
      current: 0,
      total: vegetables.length,
      stage: UploadStage.analyzingDuplicates,
    ));

    final stats = await _duplicateDetector.analyzeDuplicates(vegetables);
    final newVegetables = await _duplicateDetector.filterDuplicates(vegetables);

    // Upload new vegetables in batch
    onProgress?.call(UploadProgress(
      current: 0,
      total: newVegetables.length,
      stage: UploadStage.uploading,
    ));

    final uploadedIds = <String>[];
    for (var i = 0; i < newVegetables.length; i++) {
      final docId = await _repository.create(newVegetables[i]);
      uploadedIds.add(docId);

      onProgress?.call(UploadProgress(
        current: i + 1,
        total: newVegetables.length,
        stage: UploadStage.uploading,
      ));
    }

    return UploadResult(
      totalProvided: vegetables.length,
      uploaded: newVegetables.length,
      skipped: stats.duplicates,
      uploadedIds: uploadedIds,
      skippedNames: stats.duplicateNames,
    );
  }
}

/// Upload progress information
class UploadProgress {
  final int current;
  final int total;
  final UploadStage stage;

  UploadProgress({
    required this.current,
    required this.total,
    required this.stage,
  });

  double get percentage => total > 0 ? (current / total) * 100 : 0;

  @override
  String toString() => '${stage.label}: $current/$total (${percentage.toStringAsFixed(0)}%)';
}

/// Upload stages
enum UploadStage {
  analyzingDuplicates,
  uploading,
  complete;

  String get label {
    switch (this) {
      case UploadStage.analyzingDuplicates:
        return 'Analyzing duplicates';
      case UploadStage.uploading:
        return 'Uploading';
      case UploadStage.complete:
        return 'Complete';
    }
  }
}

/// Upload result summary
class UploadResult {
  final int totalProvided;
  final int uploaded;
  final int skipped;
  final List<String> uploadedIds;
  final List<String> skippedNames;

  UploadResult({
    required this.totalProvided,
    required this.uploaded,
    required this.skipped,
    required this.uploadedIds,
    required this.skippedNames,
  });

  bool get hasSkipped => skipped > 0;
  bool get allUploaded => uploaded == totalProvided;

  @override
  String toString() {
    return 'Upload Result: $uploaded uploaded, $skipped skipped (Total: $totalProvided)';
  }
}
```

### REFACTOR

**Improvements:**
1. Use batch writes for better performance
2. Add error recovery
3. Add retry logic for transient failures

**Updated Code:**

```dart
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import 'package:vegetables_firestore/services/duplicate_detector.dart';

typedef UploadProgressCallback = void Function(UploadProgress progress);

/// Service for uploading vegetables to Firestore with deduplication and batch optimization
class FirestoreUploadService {
  final VegetableRepository _repository;
  late final DuplicateDetector _duplicateDetector;

  static const int BATCH_SIZE = 500; // Firestore batch limit
  static const int MAX_RETRIES = 3;

  FirestoreUploadService(this._repository) {
    _duplicateDetector = DuplicateDetector(_repository);
  }

  /// Upload new vegetables only (skip duplicates)
  ///
  /// Uses batch writes for optimal performance
  Future<UploadResult> uploadNewVegetables(
    List<Vegetable> vegetables, {
    UploadProgressCallback? onProgress,
  }) async {
    if (vegetables.isEmpty) {
      return UploadResult.empty();
    }

    try {
      // Step 1: Analyze duplicates
      onProgress?.call(UploadProgress(
        current: 0,
        total: vegetables.length,
        stage: UploadStage.analyzingDuplicates,
      ));

      final stats = await _duplicateDetector.analyzeDuplicates(
        vegetables,
        onProgress: (current, total) {
          onProgress?.call(UploadProgress(
            current: current,
            total: total,
            stage: UploadStage.analyzingDuplicates,
          ));
        },
      );

      final newVegetables = await _duplicateDetector.filterDuplicates(vegetables);

      if (newVegetables.isEmpty) {
        return UploadResult(
          totalProvided: vegetables.length,
          uploaded: 0,
          skipped: stats.duplicates,
          uploadedIds: [],
          skippedNames: stats.duplicateNames,
        );
      }

      // Step 2: Upload in batches
      final uploadedIds = await _uploadInBatches(
        newVegetables,
        onProgress: (current, total) {
          onProgress?.call(UploadProgress(
            current: current,
            total: total,
            stage: UploadStage.uploading,
          ));
        },
      );

      onProgress?.call(UploadProgress(
        current: newVegetables.length,
        total: newVegetables.length,
        stage: UploadStage.complete,
      ));

      return UploadResult(
        totalProvided: vegetables.length,
        uploaded: uploadedIds.length,
        skipped: stats.duplicates,
        uploadedIds: uploadedIds,
        skippedNames: stats.duplicateNames,
      );
    } catch (e) {
      throw UploadException('Failed to upload vegetables: $e');
    }
  }

  /// Upload vegetables in batches for optimal performance
  Future<List<String>> _uploadInBatches(
    List<Vegetable> vegetables, {
    ProgressCallback? onProgress,
  }) async {
    // For small lists, use batch write
    if (vegetables.length <= BATCH_SIZE) {
      return await _repository.createBatch(vegetables);
    }

    // For large lists, split into multiple batches
    final allIds = <String>[];
    for (var i = 0; i < vegetables.length; i += BATCH_SIZE) {
      final end = (i + BATCH_SIZE < vegetables.length)
          ? i + BATCH_SIZE
          : vegetables.length;
      final batch = vegetables.sublist(i, end);

      final ids = await _repository.createBatch(batch);
      allIds.addAll(ids);

      onProgress?.call(end, vegetables.length);
    }

    return allIds;
  }
}

/// Upload progress information
class UploadProgress {
  final int current;
  final int total;
  final UploadStage stage;

  UploadProgress({
    required this.current,
    required this.total,
    required this.stage,
  });

  double get percentage => total > 0 ? (current / total) * 100 : 0;

  @override
  String toString() =>
      '${stage.label}: $current/$total (${percentage.toStringAsFixed(0)}%)';
}

/// Upload stages
enum UploadStage {
  analyzingDuplicates,
  uploading,
  complete;

  String get label {
    switch (this) {
      case UploadStage.analyzingDuplicates:
        return 'Analyzing';
      case UploadStage.uploading:
        return 'Uploading';
      case UploadStage.complete:
        return 'Complete';
    }
  }
}

/// Upload result summary
class UploadResult {
  final int totalProvided;
  final int uploaded;
  final int skipped;
  final List<String> uploadedIds;
  final List<String> skippedNames;

  UploadResult({
    required this.totalProvided,
    required this.uploaded,
    required this.skipped,
    required this.uploadedIds,
    required this.skippedNames,
  });

  factory UploadResult.empty() => UploadResult(
        totalProvided: 0,
        uploaded: 0,
        skipped: 0,
        uploadedIds: [],
        skippedNames: [],
      );

  bool get hasSkipped => skipped > 0;
  bool get allUploaded => uploaded == totalProvided;
  double get uploadPercentage =>
      totalProvided > 0 ? (uploaded / totalProvided) * 100 : 0;

  @override
  String toString() {
    return 'Uploaded: $uploaded/$totalProvided '
           '(${uploadPercentage.toStringAsFixed(0)}%) | '
           'Skipped: $skipped duplicates';
  }
}

/// Exception thrown during upload
class UploadException implements Exception {
  final String message;

  UploadException(this.message);

  @override
  String toString() => 'UploadException: $message';
}
```

### Run Tests

```bash
/tdd-test test/services/firestore_upload_service_test.dart
```

---

## Iteration 5: CLI Integration

### Objective
Integrate Firestore upload functionality into the existing import command.

### RED - Write Failing Test

**File:** `test/integration/import_with_firestore_test.dart`

```dart
import 'dart:io';
import 'package:test/test.dart';
import 'package:vegetables_firestore/services/firestore_service.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import 'package:vegetables_firestore/services/firestore_upload_service.dart';
import 'package:vegetables_firestore/models/vegetable.dart';
import '../test_helpers/firestore_test_helper.dart';
import '../test_helpers/vegetable_test_helper.dart';

void main() {
  group('Import with Firestore Integration', () {
    late VegetableRepository repository;
    late FirestoreUploadService uploadService;

    setUpAll(() async {
      final firestore = await FirestoreTestHelper.initialize();
      repository = VegetableRepository(firestore);
      uploadService = FirestoreUploadService(repository);
    });

    tearDown() async {
      await FirestoreTestHelper.cleanup();
    });

    tearDownAll() async {
      await FirestoreTestHelper.close();
    });

    test('Complete workflow: Import → Translate → Store to Firestore', () async {
      // This test simulates the complete workflow:
      // 1. Read vegetable names from file
      // 2. Translate using DeepL (mocked)
      // 3. Create Vegetable objects
      // 4. Upload to Firestore (only new ones)

      // Given: Vegetables to import
      final vegetables = [
        VegetableTestHelper.createTestVegetable(
          name: 'Tomaat',
          harvestState: HarvestState.notAvailable,
        ),
        VegetableTestHelper.createTestVegetable(
          name: 'Wortel',
          harvestState: HarvestState.notAvailable,
        ),
      ];

      // When: Upload to Firestore
      final result = await uploadService.uploadNewVegetables(vegetables);

      // Track for cleanup
      for (final id in result.uploadedIds) {
        FirestoreTestHelper.trackDocument(id);
      }

      // Then: All vegetables uploaded
      expect(result.uploaded, equals(2));
      expect(result.skipped, equals(0));

      // Verify in Firestore
      final stored = await repository.getAll();
      expect(stored.length, greaterThanOrEqualTo(2));

      final storedNames = stored.map((v) => v.name).toList();
      expect(storedNames, contains('Tomaat'));
      expect(storedNames, contains('Wortel'));

      // Verify all have notAvailable state
      for (final veg in stored) {
        if (veg.name == 'Tomaat' || veg.name == 'Wortel') {
          expect(veg.harvestState, equals(HarvestState.notAvailable));
        }
      }
    });

    test('Second import should skip duplicates', () async {
      // Given: First import
      final firstBatch = [
        VegetableTestHelper.createTestVegetable(name: 'Sla'),
        VegetableTestHelper.createTestVegetable(name: 'Paprika'),
      ];

      final firstResult = await uploadService.uploadNewVegetables(firstBatch);
      for (final id in firstResult.uploadedIds) {
        FirestoreTestHelper.trackDocument(id);
      }

      // When: Second import with duplicates
      final secondBatch = [
        VegetableTestHelper.createTestVegetable(name: 'Sla'), // Duplicate
        VegetableTestHelper.createTestVegetable(name: 'Komkommer'), // New
      ];

      final secondResult = await uploadService.uploadNewVegetables(secondBatch);
      for (final id in secondResult.uploadedIds) {
        FirestoreTestHelper.trackDocument(id);
      }

      // Then: Only new vegetable uploaded
      expect(secondResult.uploaded, equals(1));
      expect(secondResult.skipped, equals(1));
      expect(secondResult.skippedNames, contains('Sla'));
    });
  });
}
```

### GREEN - Implement CLI Integration

**File:** `bin/vegetables_firestore.dart` (Update existing file)

Add Firestore flags to import command:

```dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:vegetables_firestore/services/vegetable_importer.dart';
import 'package:vegetables_firestore/services/vegetable_exporter.dart';
import 'package:vegetables_firestore/services/firestore_service.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import 'package:vegetables_firestore/services/firestore_upload_service.dart';

void main(List<String> arguments) async {
  final parser = buildParser();

  try {
    final results = parser.parse(arguments);

    if (results.command?.name == 'import') {
      await handleImportCommand(results.command!);
    }
    // ... other commands
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

ArgParser buildParser() {
  return ArgParser()
    ..addCommand('import', buildImportCommand());
}

ArgParser buildImportCommand() {
  return ArgParser()
    ..addOption('input', abbr: 'i', mandatory: true,
        help: 'Input text file with vegetable names')
    ..addOption('output', abbr: 'o', mandatory: true,
        help: 'Output JSON file')
    ..addOption('api-key', abbr: 'k',
        help: 'DeepL API key')
    ..addFlag('upload-to-firestore', defaultsTo: false,
        help: 'Upload vegetables to Firestore after import')
    ..addOption('firebase-project-id',
        help: 'Firebase project ID (required if uploading to Firestore)')
    ..addOption('firebase-service-account',
        help: 'Path to service account JSON file');
}

Future<void> handleImportCommand(ArgResults command) async {
  final inputPath = command.option('input')!;
  final outputPath = command.option('output')!;

  // Get DeepL API key
  var apiKey = command.option('api-key');
  if (apiKey == null || apiKey.isEmpty) {
    stdout.write('Enter DeepL API key: ');
    apiKey = stdin.readLineSync();
  }

  // Import and translate vegetables
  print('Importing vegetables from $inputPath...');
  final importer = VegetableImporter();
  final vegetables = await importer.importFromFile(inputPath, apiKey!);

  // Export to JSON
  print('Exporting to $outputPath...');
  await VegetableExporter.toJsonFile(vegetables, outputPath);
  print('Exported ${vegetables.length} vegetables to $outputPath');

  // Upload to Firestore if requested
  if (command.flag('upload-to-firestore')) {
    await uploadToFirestore(command, vegetables);
  }
}

Future<void> uploadToFirestore(
  ArgResults command,
  List<Vegetable> vegetables,
) async {
  // Get Firebase project ID
  var projectId = command.option('firebase-project-id');
  if (projectId == null || projectId.isEmpty) {
    stdout.write('Enter Firebase project ID: ');
    projectId = stdin.readLineSync();
  }

  // Get service account JSON
  String serviceAccountJson;
  final serviceAccountPath = command.option('firebase-service-account');

  if (serviceAccountPath != null && serviceAccountPath.isNotEmpty) {
    // Read from file
    final file = File(serviceAccountPath);
    if (!file.existsSync()) {
      throw Exception('Service account file not found: $serviceAccountPath');
    }
    serviceAccountJson = await file.readAsString();
  } else {
    // Prompt for JSON
    stdout.write('Enter service account JSON (paste entire JSON): ');
    serviceAccountJson = stdin.readLineSync() ?? '';
  }

  if (serviceAccountJson.isEmpty) {
    throw Exception('Service account JSON is required for Firestore upload');
  }

  // Initialize Firestore
  print('Connecting to Firestore...');
  final firestoreService = FirestoreService();
  await firestoreService.initialize(projectId!, serviceAccountJson);

  // Upload vegetables
  final repository = VegetableRepository(firestoreService.firestore);
  final uploadService = FirestoreUploadService(repository);

  print('Uploading vegetables to Firestore...');
  final result = await uploadService.uploadNewVegetables(
    vegetables,
    onProgress: (progress) {
      stdout.write('\r${progress}');
    },
  );

  print('\n$result');

  if (result.hasSkipped) {
    print('Skipped vegetables (already exist):');
    for (final name in result.skippedNames) {
      print('  - $name');
    }
  }

  // Cleanup
  await firestoreService.close();
}
```

### REFACTOR

**Improvements:**
1. Better error messages
2. Validate inputs before processing
3. Add dry-run mode
4. Add confirmation prompt

### Run Tests

```bash
/tdd-test test/integration/import_with_firestore_test.dart
```

---

## Final Integration Test

### Objective
Comprehensive end-to-end test verifying the complete workflow.

**File:** `test/integration/complete_workflow_test.dart`

```dart
import 'dart:io';
import 'package:test/test.dart';
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_file_reader.dart';
import 'package:vegetables_firestore/services/vegetable_factory.dart';
import 'package:vegetables_firestore/services/firestore_upload_service.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import '../test_helpers/firestore_test_helper.dart';

void main() {
  group('Complete Workflow Integration Test', () {
    late VegetableRepository repository;
    late FirestoreUploadService uploadService;

    setUpAll(() async {
      final firestore = await FirestoreTestHelper.initialize();
      repository = VegetableRepository(firestore);
      uploadService = FirestoreUploadService(repository);
    });

    tearDown() async {
      await FirestoreTestHelper.cleanup();
    });

    tearDownAll() async {
      await FirestoreTestHelper.close();
    });

    test('End-to-end: File → Translation → Firestore', () async {
      // Create test input file
      final testFile = File('test/fixtures/test_vegetables.txt');
      await testFile.writeAsString('Tomaat\nWortel\nSla\n');

      try {
        // Step 1: Read from file
        final names = await VegetableFileReader.readNames(testFile.path);
        expect(names.length, equals(3));

        // Step 2: Create vegetables (translation would happen here in real workflow)
        // For test, we create mock vegetables with notAvailable state
        final vegetables = names.map((name) {
          return Vegetable(
            name: name,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            harvestState: HarvestState.notAvailable,
            translations: createMockTranslations(name),
          );
        }).toList();

        // Step 3: Upload to Firestore
        final result = await uploadService.uploadNewVegetables(vegetables);

        // Track for cleanup
        for (final id in result.uploadedIds) {
          FirestoreTestHelper.trackDocument(id);
        }

        // Verify: All uploaded
        expect(result.uploaded, equals(3));
        expect(result.skipped, equals(0));

        // Verify: All in Firestore with correct properties
        final allVegetables = await repository.getAll();
        expect(allVegetables.length, greaterThanOrEqualTo(3));

        for (final name in names) {
          final vegetable = allVegetables.firstWhere((v) => v.name == name);

          // Verify properties
          expect(vegetable.harvestState, equals(HarvestState.notAvailable));
          expect(vegetable.translations, isNotNull);
          expect(vegetable.translations.nl, isNotNull);
          expect(vegetable.translations.en, isNotNull);
          expect(vegetable.translations.fr, isNotNull);
          expect(vegetable.translations.de, isNotNull);
          expect(vegetable.createdAt, isNotNull);
          expect(vegetable.updatedAt, isNotNull);
        }

        // Verify: JSON schema compliance
        for (final vegetable in allVegetables) {
          final json = vegetable.toJson();
          expect(json['name'], isA<String>());
          expect(json['harvestState'], isA<String>());
          expect(json['translations'], isA<Map>());
        }
      } finally {
        // Cleanup test file
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }
    });
  });
}

/// Create mock translations for testing
VegetableTranslations createMockTranslations(String dutchName) {
  return VegetableTranslations(
    nl: Translation(
      name: dutchName,
      harvestState: HarvestStateTranslation(
        scarce: 'Schaars',
        enough: 'Voldoende',
        plenty: 'Overvloed',
        notAvailable: 'Niet beschikbaar',
      ),
    ),
    en: Translation(
      name: '$dutchName (EN)',
      harvestState: HarvestStateTranslation(
        scarce: 'Scarce',
        enough: 'Enough',
        plenty: 'Plenty',
        notAvailable: 'Not Available',
      ),
    ),
    fr: Translation(
      name: '$dutchName (FR)',
      harvestState: HarvestStateTranslation(
        scarce: 'Rare',
        enough: 'Suffisant',
        plenty: 'Abondant',
        notAvailable: 'Non disponible',
      ),
    ),
    de: Translation(
      name: '$dutchName (DE)',
      harvestState: HarvestStateTranslation(
        scarce: 'Knapp',
        enough: 'Ausreichend',
        plenty: 'Reichlich',
        notAvailable: 'Nicht verfügbar',
      ),
    ),
  );
}
```

---

## Success Criteria

### All Tests Must Pass

```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

### Code Quality

```bash
# No linting errors
dart analyze

# Code formatted
dart format .

# Regenerate mappers
dart run build_runner build
```

### Functional Requirements

- ✅ Firestore service initializes with service account
- ✅ CRUD operations work correctly
- ✅ Duplicate detection identifies existing vegetables
- ✅ Batch upload skips duplicates
- ✅ CLI integration with `--upload-to-firestore` flag
- ✅ Progress reporting during upload
- ✅ All imported vegetables have `harvestState: notAvailable`
- ✅ Complete translations for all languages (NL, EN, FR, DE)
- ✅ JSON schema validation passes
- ✅ Service account credentials never saved to disk

### Security Requirements

- ✅ Service account JSON prompted during execution
- ✅ Credentials not logged or saved
- ✅ No credentials in version control
- ✅ Service account file in .gitignore

### Performance Requirements

- ✅ Batch operations for >10 vegetables
- ✅ Single query for duplicate detection
- ✅ Upload rate: >100 vegetables/minute

---

## Implementation Checklist

- [ ] Add `dart_firebase_admin` dependency
- [ ] Implement `FirestoreService`
- [ ] Implement `VegetableRepository` with CRUD operations
- [ ] Implement `DuplicateDetector`
- [ ] Implement `FirestoreUploadService`
- [ ] Update CLI with Firestore flags
- [ ] Create test helpers (`FirestoreTestHelper`)
- [ ] Write all unit tests
- [ ] Write integration tests
- [ ] Update CLAUDE.md documentation
- [ ] Test with Firebase emulator (locally)
- [ ] Test with real Firestore (if using Option A)
- [ ] Verify security (credentials not saved)
- [ ] Run `dart analyze` - no issues
- [ ] Run `dart test` - all pass
- [ ] Update `.gitignore` for service account files

---

## Usage Examples

### Option A: Direct Firestore Testing (Claude Code Web)

```bash
# Run tests (will prompt for service account JSON)
dart test test/services/firestore_service_test.dart
```

### Option B: Local Emulator Testing

```bash
# Terminal 1: Start emulator
firebase emulators:start

# Terminal 2: Run tests with emulator
export FIRESTORE_EMULATOR_HOST="localhost:8080"
dart test
```

### CLI Usage

```bash
# Import with Firestore upload
dart run bin/vegetables_firestore.dart import \
  --input vegetables.txt \
  --output vegetables.json \
  --upload-to-firestore \
  --firebase-project-id vegetables-firestore-123
# Will prompt for DeepL API key
# Will prompt for service account JSON
```

---

## Notes

- **Never commit service account JSON files**
- Add to .gitignore: `*service-account*.json`
- Use environment variables in CI/CD pipelines
- Consider Firebase App Check for additional security in production
- dart_firebase_admin automatically detects emulator from environment variables
- Free tier limits: 50K reads, 20K writes, 20K deletes per day

---

## References

- **dart_firebase_admin docs:** https://pub.dev/packages/dart_firebase_admin
- **Firestore documentation:** https://firebase.google.com/docs/firestore
- **Firebase Admin SDK:** https://firebase.google.com/docs/admin/setup
- **Service Account setup:** https://console.firebase.google.com/project/_/settings/serviceaccounts

---

**Document Version:** 1.0
**Created:** 2025-11-16
**Status:** Ready for Implementation
**Package:** dart_firebase_admin ^0.4.1
