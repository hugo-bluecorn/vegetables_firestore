# TDD Task: Dual CLI Architecture with dart_firebase_admin

## Status
- **Created**: 2025-11-17
- **Status**: Not Started
- **Estimated Tests**: ~170 total (~144 existing + ~26 new)

## Overview

Implement a dual CLI architecture that provides separate tools for development (with emulator) and production (with real Firebase). This addresses the critical issue of hardcoded collection names and improves developer experience by auto-providing credentials in development mode.

### Key Objectives

1. Fix hardcoded `vegetables_test` collection name
2. Create `vegetables_dev` CLI with automatic emulator integration
3. Create `vegetables_prod` CLI with production safety validations
4. Leverage dart_firebase_admin's automatic emulator routing
5. Maintain backward compatibility with existing CLI
6. Platform-aware error messages (Linux & Windows)

### Prerequisites

Developers must complete environment setup before implementing:
- See `DUAL_CLI_SETUP.md` in project root
- Firebase Emulator must be installed and running
- `FIRESTORE_EMULATOR_HOST` environment variable set

---

## TDD Implementation Phases

### Phase 1: Configuration Foundation (Critical Fix)

**Objective**: Fix hardcoded collection name and create configuration layer

#### Task 1.1: Create FirestoreConfig class

**Given**: Application needs configurable Firestore settings
**When**: Developer creates FirestoreConfig
**Then**: Config provides environment-specific settings (collection name, validation rules)

**Test File**: `test/config/firestore_config_test.dart`

**Tests to Write** (RED):
```dart
group('FirestoreConfig', () {
  test('development config uses vegetables_test collection', () {
    final config = FirestoreConfig.development();
    expect(config.collectionName, equals('vegetables_test'));
    expect(config.requireEmulator, isTrue);
    expect(config.requireProduction, isFalse);
  });

  test('production config uses vegetables collection', () {
    final config = FirestoreConfig.production();
    expect(config.collectionName, equals('vegetables'));
    expect(config.requireProduction, isTrue);
    expect(config.requireEmulator, isFalse);
  });

  test('auto config detects emulator from environment', () {
    // When FIRESTORE_EMULATOR_HOST is set
    final config = FirestoreConfig.auto();
    expect(config.isEmulatorMode, isTrue);
    expect(config.collectionName, equals('vegetables_test'));
  });

  test('auto config uses production when emulator not detected', () {
    // When FIRESTORE_EMULATOR_HOST is NOT set
    final config = FirestoreConfig.auto();
    expect(config.isEmulatorMode, isFalse);
    expect(config.collectionName, equals('vegetables'));
  });

  test('config provides default project ID', () {
    final config = FirestoreConfig.development();
    expect(config.defaultProjectId, equals('vegetables-firestore-dev'));
  });
});
```

**Implementation** (GREEN): Create `lib/config/firestore_config.dart`

**Implementation Details**:
```dart
enum FirestoreEnvironment { development, production, auto }

class FirestoreConfig {
  final String collectionName;
  final bool requireEmulator;
  final bool requireProduction;
  final String defaultProjectId;
  final FirestoreEnvironment environment;

  const FirestoreConfig._({
    required this.collectionName,
    required this.requireEmulator,
    required this.requireProduction,
    required this.defaultProjectId,
    required this.environment,
  });

  factory FirestoreConfig.development() {
    return const FirestoreConfig._(
      collectionName: 'vegetables_test',
      requireEmulator: true,
      requireProduction: false,
      defaultProjectId: 'vegetables-firestore-dev',
      environment: FirestoreEnvironment.development,
    );
  }

  factory FirestoreConfig.production() {
    return const FirestoreConfig._(
      collectionName: 'vegetables',
      requireEmulator: false,
      requireProduction: true,
      defaultProjectId: 'vegetables-firestore-prod',
      environment: FirestoreEnvironment.production,
    );
  }

  factory FirestoreConfig.auto() {
    final isEmulator = Platform.environment['FIRESTORE_EMULATOR_HOST'] != null;
    return isEmulator ? FirestoreConfig.development() : FirestoreConfig.production();
  }

  bool get isEmulatorMode => Platform.environment['FIRESTORE_EMULATOR_HOST'] != null;
}
```

**Refactor**: Extract common logic, add documentation

---

#### Task 1.2: Make VegetableRepository configurable

**Given**: VegetableRepository has hardcoded collection name
**When**: Developer provides custom collection name
**Then**: Repository uses specified collection for all operations

**Test File**: `test/services/vegetable_repository_test.dart` (extend existing)

**Tests to Write** (RED):
```dart
group('VegetableRepository - Collection Configuration', () {
  test('constructor accepts custom collection name', () {
    final repo = VegetableRepository(
      firestore,
      collectionName: 'vegetables_custom',
    );
    expect(repo.collectionName, equals('vegetables_custom'));
  });

  test('defaults to vegetables_test for backward compatibility', () {
    final repo = VegetableRepository(firestore);
    expect(repo.collectionName, equals('vegetables_test'));
  });

  test('create() uses configured collection name', () async {
    final prodRepo = VegetableRepository(
      firestore,
      collectionName: 'vegetables',
    );

    final vegetable = VegetableTestHelper.createTestVegetable('Tomaat');
    final docId = await prodRepo.create(vegetable);

    // Verify document exists in 'vegetables' collection
    final doc = await firestore.collection('vegetables').doc(docId).get();
    expect(doc.exists, isTrue);
  });

  test('all CRUD operations use configured collection', () async {
    final testRepo = VegetableRepository(
      firestore,
      collectionName: 'vegetables_integration_test',
    );

    final vegetable = VegetableTestHelper.createTestVegetable('Komkommer');
    final docId = await testRepo.create(vegetable);

    final retrieved = await testRepo.getById(docId);
    expect(retrieved, isNotNull);
    expect(retrieved!.name, equals('Komkommer'));

    await testRepo.delete(docId);
    final deleted = await testRepo.getById(docId);
    expect(deleted, isNull);
  });
});
```

**Implementation** (GREEN): Modify `lib/services/vegetable_repository.dart`

**Changes**:
```dart
class VegetableRepository {
  final Firestore _firestore;
  final String collectionName;

  VegetableRepository(
    this._firestore, {
    this.collectionName = 'vegetables_test', // Default for safety
  });

  // Update all methods to use this.collectionName instead of static constant
  Future<String> create(Vegetable vegetable) async {
    final docRef = _firestore.collection(collectionName).doc();
    // ... rest of implementation
  }
}
```

**Refactor**: Remove static `collectionName` constant, update all method usages

---

### Phase 2: Environment Detection & Validation

**Objective**: Create platform-aware environment validation

#### Task 2.1: Create EnvironmentValidator class

**Given**: Application needs to validate environment configuration
**When**: Developer validates dev or prod environment
**Then**: Clear platform-specific error messages guide setup

**Test File**: `test/config/environment_validator_test.dart`

**Tests to Write** (RED):
```dart
group('EnvironmentValidator', () {
  test('detects emulator when FIRESTORE_EMULATOR_HOST is set', () {
    // Test with mocked environment variable
    expect(EnvironmentValidator.isEmulatorActive(), isTrue);
  });

  test('detects no emulator when environment variable not set', () {
    // Test without environment variable
    expect(EnvironmentValidator.isEmulatorActive(), isFalse);
  });

  test('provides Linux-specific setup instructions', () {
    // When running on Linux
    final error = EnvironmentValidator.getEmulatorNotRunningError();
    expect(error, contains('export FIRESTORE_EMULATOR_HOST'));
    expect(error, contains('firebase emulators:start'));
  });

  test('provides Windows-specific setup instructions', () {
    // When running on Windows
    final error = EnvironmentValidator.getEmulatorNotRunningError();
    expect(error, contains('set FIRESTORE_EMULATOR_HOST') ||
                 contains('\$env:FIRESTORE_EMULATOR_HOST'));
  });

  test('validateDevEnvironment() succeeds when emulator active', () {
    expect(
      () => EnvironmentValidator.validateDevEnvironment(),
      returnsNormally,
    );
  });

  test('validateDevEnvironment() throws when emulator not active', () {
    // Mock emulator not running
    expect(
      () => EnvironmentValidator.validateDevEnvironment(),
      throwsA(isA<EnvironmentException>()),
    );
  });

  test('validateProdEnvironment() succeeds when emulator NOT active', () {
    expect(
      () => EnvironmentValidator.validateProdEnvironment(),
      returnsNormally,
    );
  });

  test('validateProdEnvironment() throws when emulator is active', () {
    // Mock emulator running
    expect(
      () => EnvironmentValidator.validateProdEnvironment(),
      throwsA(isA<EnvironmentException>()),
    );
  });

  test('error messages include platform detection', () {
    final platform = EnvironmentValidator.detectPlatform();
    expect(platform, anyOf(equals('Linux'), equals('Windows'), equals('macOS')));
  });
});
```

**Implementation** (GREEN): Create `lib/config/environment_validator.dart`

**Refactor**: Extract error message templates, improve clarity

---

### Phase 3: Enhanced FirestoreService

**Objective**: Add configuration support with environment validation

#### Task 3.1: Add configuration parameter to FirestoreService

**Given**: FirestoreService needs environment-aware initialization
**When**: Service initialized with FirestoreConfig
**Then**: dart_firebase_admin connects correctly with environment validation

**Test File**: `test/services/firestore_service_test.dart` (extend existing)

**Tests to Write** (RED):
```dart
group('FirestoreService - Configuration Support', () {
  test('initialize() works with dummy credentials in emulator mode', () async {
    // Requires FIRESTORE_EMULATOR_HOST to be set
    final service = FirestoreService();
    final dummyCredentials = '''
    {
      "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC8W3xK\\n-----END PRIVATE KEY-----\\n",
      "client_email": "test@emulator.iam.gserviceaccount.com",
      "client_id": "emulator_client_id"
    }
    ''';

    await service.initialize('emulator-project', dummyCredentials);
    expect(service.isInitialized, isTrue);
    expect(service.firestore, isNotNull);
  });

  test('initialize() with dev config validates emulator is running', () async {
    final config = FirestoreConfig.development();
    final service = FirestoreService();

    // Should succeed if emulator running
    await service.initialize(
      'test-project',
      dummyCredentials,
      config: config,
    );
    expect(service.isInitialized, isTrue);
  });

  test('initialize() with dev config throws if emulator not running', () async {
    // Mock emulator not running
    final config = FirestoreConfig.development();
    final service = FirestoreService();

    expect(
      () => service.initialize('test-project', dummyJson, config: config),
      throwsA(isA<EnvironmentException>()),
    );
  });

  test('dart_firebase_admin routes to emulator when env var set', () async {
    final service = FirestoreService();
    await service.initialize('test-project', dummyCredentials);

    // Create test document via dart_firebase_admin
    final docRef = service.firestore
      .collection('test_collection')
      .doc('test_doc');
    await docRef.set({'test': 'value'});

    // Verify it exists (proves emulator connection works)
    final snapshot = await docRef.get();
    expect(snapshot.exists, isTrue);
    expect(snapshot.data['test'], equals('value'));

    // Cleanup
    await docRef.delete();
  });

  test('initialize() with prod config validates emulator NOT running', () async {
    final config = FirestoreConfig.production();
    final service = FirestoreService();

    // Should throw if emulator is running
    expect(
      () => service.initialize('prod-project', realCredentials, config: config),
      throwsA(isA<EnvironmentException>()),
    );
  });

  test('backward compatibility: initialize without config still works', () async {
    final service = FirestoreService();

    // Existing signature should still work
    await service.initialize('test-project', dummyCredentials);
    expect(service.isInitialized, isTrue);
  });
});
```

**Implementation** (GREEN): Modify `lib/services/firestore_service.dart`

**Changes**:
```dart
Future<void> initialize(
  String projectId,
  String serviceAccountJson, {
  FirestoreConfig? config,
}) async {
  if (_isInitialized) return;

  // Validate environment if config provided
  if (config != null) {
    if (config.requireEmulator) {
      EnvironmentValidator.validateDevEnvironment();
    }
    if (config.requireProduction) {
      EnvironmentValidator.validateProdEnvironment();
    }
  }

  // Existing dart_firebase_admin initialization code
  // (no changes to actual SDK initialization logic)

  try {
    final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
    if (emulatorHost != null) {
      print('[FirestoreService] Using emulator at $emulatorHost');
    }

    final serviceAccountData = jsonDecode(serviceAccountJson);
    final credential = Credential.fromServiceAccountParams(
      clientId: serviceAccountData['client_id'] as String? ?? '',
      privateKey: serviceAccountData['private_key'] as String,
      email: serviceAccountData['client_email'] as String,
    );

    _app = FirebaseAdminApp.initializeApp(projectId, credential);
    _firestore = Firestore(_app!);
    _projectId = projectId;
    _isInitialized = true;

    print('[FirestoreService] Initialized for project: $projectId');
  } catch (e) {
    throw Exception('Failed to initialize Firestore: $e');
  }
}
```

**Refactor**: Extract validation logic, improve error messages

---

### Phase 4: Credential Provider

**Objective**: Streamline credential handling with auto-detection

#### Task 4.1: Create CredentialProvider class

**Given**: Application needs flexible credential management
**When**: Emulator is active
**Then**: Auto-provide dummy credentials for dart_firebase_admin

**Test File**: `test/config/credential_provider_test.dart`

**Tests to Write** (RED):
```dart
group('CredentialProvider', () {
  test('getDummyCredentials() returns valid dart_firebase_admin format', () {
    final credentials = CredentialProvider.getDummyCredentials();
    final parsed = jsonDecode(credentials) as Map<String, dynamic>;

    expect(parsed['private_key'], isNotNull);
    expect(parsed['private_key'], contains('BEGIN PRIVATE KEY'));
    expect(parsed['client_email'], contains('@'));
    expect(parsed['client_id'], isNotNull);
  });

  test('getDummyCredentials() can initialize dart_firebase_admin', () async {
    // Integration test: verify dummy credentials work with SDK
    final credentials = CredentialProvider.getDummyCredentials();
    final service = FirestoreService();

    // Should not throw when emulator is running
    await service.initialize('emulator-project', credentials);
    expect(service.isInitialized, isTrue);
  });

  test('getCredentials() auto-provides dummy when emulator detected', () async {
    final config = FirestoreConfig.development();
    final credentials = await CredentialProvider.getCredentials(config);

    final parsed = jsonDecode(credentials) as Map<String, dynamic>;
    expect(parsed['client_email'], contains('emulator'));
  });

  test('getCredentials() prompts user when production mode', () async {
    final config = FirestoreConfig.production();
    // Mock stdin for user input
    // Verify prompting behavior
  });

  test('loadCredentialsFromFile() reads and validates format', () async {
    final credentials = await CredentialProvider.loadCredentialsFromFile(
      'test/fixtures/test-service-account.json',
    );

    final parsed = jsonDecode(credentials) as Map<String, dynamic>;
    expect(parsed['private_key'], isNotNull);
    expect(parsed['client_email'], isNotNull);
  });

  test('validateCredentialFormat() accepts valid JSON', () {
    const validJson = '''
    {
      "private_key": "-----BEGIN PRIVATE KEY-----\\nkey\\n-----END PRIVATE KEY-----\\n",
      "client_email": "test@test.iam.gserviceaccount.com"
    }
    ''';

    expect(
      () => CredentialProvider.validateCredentialFormat(validJson),
      returnsNormally,
    );
  });

  test('validateCredentialFormat() rejects invalid JSON', () {
    expect(
      () => CredentialProvider.validateCredentialFormat('not json'),
      throwsA(isA<FormatException>()),
    );
  });

  test('validateCredentialFormat() rejects missing required fields', () {
    const missingFields = '{"project_id": "test"}';

    expect(
      () => CredentialProvider.validateCredentialFormat(missingFields),
      throwsA(isA<Exception>()),
    );
  });
});
```

**Implementation** (GREEN): Create `lib/config/credential_provider.dart`

**Refactor**: Extract validation logic, improve error handling

---

### Phase 5: Shared CLI Runner

**Objective**: Extract common CLI logic to avoid duplication

#### Task 5.1: Create CLIRunner class

**Given**: Multiple CLIs need shared argument parsing and execution logic
**When**: CLIRunner initialized with FirestoreConfig
**Then**: Appropriate credential and collection strategies applied

**Test File**: `test/cli/cli_runner_test.dart`

**Tests to Write** (RED):
```dart
group('CLIRunner', () {
  test('buildParser() creates argument parser with all commands', () {
    final runner = CLIRunner(FirestoreConfig.development());
    final parser = runner.buildParser();

    expect(parser.commands.keys, contains('import'));
  });

  test('run() with dev config uses vegetables_test collection', () async {
    final runner = CLIRunner(FirestoreConfig.development());
    // Test import command execution
    // Verify vegetables_test collection used
  });

  test('run() with prod config uses vegetables collection', () async {
    final runner = CLIRunner(FirestoreConfig.production());
    // Test import command execution
    // Verify vegetables collection used
  });

  test('getCredentials() returns dummy for dev mode', () async {
    final runner = CLIRunner(FirestoreConfig.development());
    final credentials = await runner.getCredentials(null);

    final parsed = jsonDecode(credentials) as Map<String, dynamic>;
    expect(parsed['client_email'], contains('emulator'));
  });

  test('getCredentials() prompts for prod mode', () async {
    final runner = CLIRunner(FirestoreConfig.production());
    // Mock stdin
    // Verify prompting behavior
  });

  test('import command integrates with VegetableRepository', () async {
    final runner = CLIRunner(FirestoreConfig.development());
    // Test full import flow with repository
  });
});
```

**Implementation** (GREEN): Create `lib/cli/cli_runner.dart`

**Refactor**: Extract command building, improve modularity

---

### Phase 6: Dual CLI Entry Points

**Objective**: Create vegetables_dev and vegetables_prod CLIs

#### Task 6.1: Create vegetables_dev.dart

**Given**: Developer needs easy development environment CLI
**When**: vegetables_dev is run
**Then**: Auto-validates emulator, uses dummy credentials, targets vegetables_test

**Test File**: `test/cli/vegetables_dev_test.dart`

**Tests to Write** (RED):
```dart
group('vegetables_dev CLI', () {
  test('validates emulator is running on startup', () async {
    // Mock emulator not running
    // Verify error message
  });

  test('auto-uses dummy credentials without prompting', () async {
    // Verify no stdin prompts for credentials
  });

  test('uses vegetables_test collection', () async {
    // Verify collection name configuration
  });

  test('shows platform-specific error if emulator not running', () {
    // Verify error message includes correct commands for platform
  });

  test('version includes -dev suffix', () {
    // Verify version string
  });

  test('help text explains development mode', () {
    // Verify help output
  });
});
```

**Implementation** (GREEN): Create `bin/vegetables_dev.dart`

---

#### Task 6.2: Create vegetables_prod.dart

**Given**: Developer needs production-safe CLI
**When**: vegetables_prod is run
**Then**: Validates emulator NOT running, requires real credentials, targets vegetables

**Test File**: `test/cli/vegetables_prod_test.dart`

**Tests to Write** (RED):
```dart
group('vegetables_prod CLI', () {
  test('validates emulator is NOT running', () {
    // Mock emulator running
    // Verify error thrown
  });

  test('requires real credentials', () {
    // Verify prompting for credentials
  });

  test('uses vegetables collection', () {
    // Verify collection name configuration
  });

  test('shows platform-specific error if emulator detected', () {
    // Verify error includes commands to unset env var
  });

  test('requires firebase-project-id', () {
    // Verify project ID is required
  });

  test('shows safety warning before production operations', () {
    // Verify warning message
  });
});
```

**Implementation** (GREEN): Create `bin/vegetables_prod.dart`

---

#### Task 6.3: Refactor original CLI

**Given**: Existing vegetables_firestore.dart CLI
**When**: Refactored to use CLIRunner
**Then**: Auto-detects environment, maintains backward compatibility

**Test File**: Extend existing CLI tests

**Implementation** (GREEN): Refactor `bin/vegetables_firestore.dart`

---

### Phase 7: Batch Operations Enhancement

**Objective**: Implement true Firestore batch writes

#### Task 7.1: Native batch operations

**Given**: Repository uses sequential creates (inefficient)
**When**: createBatch() is called
**Then**: Uses Firestore WriteBatch API for performance

**Test File**: `test/services/vegetable_repository_test.dart` (extend)

**Tests to Write** (RED):
```dart
test('createBatch() uses Firestore WriteBatch API', () async {
  final vegetables = [
    VegetableTestHelper.createTestVegetable('Tomaat'),
    VegetableTestHelper.createTestVegetable('Komkommer'),
    VegetableTestHelper.createTestVegetable('Paprika'),
  ];

  final docIds = await repository.createBatch(vegetables);

  expect(docIds.length, equals(3));
  // Verify all created in single batch operation
});

test('createBatch() respects Firestore 500 operation limit', () async {
  final vegetables = List.generate(
    600,
    (i) => VegetableTestHelper.createTestVegetable('Vegetable $i'),
  );

  final docIds = await repository.createBatch(vegetables);

  expect(docIds.length, equals(600));
  // Should split into multiple batches
});
```

**Implementation** (GREEN): Modify `lib/services/vegetable_repository.dart`

---

### Phase 8: Test Organization

**Objective**: Separate integration tests from unit tests

#### Task 8.1: Reorganize tests

**Actions**:
1. Create `test/integration/` directory
2. Move Firestore-dependent tests to integration folder
3. Add test tags for selective execution
4. Update test documentation

---

### Phase 9: Documentation & Configuration

**Objective**: Complete project documentation

#### Task 9.1: Update pubspec.yaml

**Actions**:
```yaml
executables:
  vegetables_dev: vegetables_dev
  vegetables_prod: vegetables_prod
  vegetables_firestore: vegetables_firestore
```

#### Task 9.2: Create .env.example

**Actions**: Create environment variable template

#### Task 9.3: Update CLAUDE.md

**Actions**: Add dual CLI architecture documentation

#### Task 9.4: Optional helper scripts

**Actions**: Create dev.sh, prod.sh, dev.bat, prod.bat

---

## File Changes Summary

### New Files (~8)

- `lib/config/firestore_config.dart` - Environment configuration
- `lib/config/environment_validator.dart` - Platform-aware validation
- `lib/config/credential_provider.dart` - Credential management
- `lib/cli/cli_runner.dart` - Shared CLI logic
- `bin/vegetables_dev.dart` - Development CLI entry point
- `bin/vegetables_prod.dart` - Production CLI entry point
- `.env.example` - Environment variable template
- Helper scripts (optional)

### Modified Files (~5)

- `lib/services/vegetable_repository.dart` - Configurable collection name
- `lib/services/firestore_service.dart` - Configuration parameter
- `bin/vegetables_firestore.dart` - Use CLIRunner
- `pubspec.yaml` - Add executables
- `CLAUDE.md` - Dual CLI documentation

### New Test Files (~6)

- `test/config/firestore_config_test.dart`
- `test/config/environment_validator_test.dart`
- `test/config/credential_provider_test.dart`
- `test/cli/cli_runner_test.dart`
- `test/cli/vegetables_dev_test.dart`
- `test/cli/vegetables_prod_test.dart`

---

## Success Criteria

✅ Collection name configurable (fixes critical bug)
✅ Dev CLI auto-uses dummy credentials + validates emulator active
✅ Prod CLI requires real credentials + validates emulator NOT active
✅ Dummy credentials work with dart_firebase_admin in emulator mode
✅ Same dart_firebase_admin initialization for both environments
✅ Tests verify actual Admin SDK operations
✅ Platform-specific error messages (Linux & Windows)
✅ All existing tests pass (~144)
✅ New tests added (~26)
✅ Documentation complete

**Estimated Total: ~170 tests**

---

## Implementation Notes

### dart_firebase_admin Behavior

- SDK automatically detects `FIRESTORE_EMULATOR_HOST` environment variable
- No code differences needed between emulator and production modes
- Dummy credentials accepted in emulator mode (no validation)
- Credentials validated only when connecting to production Firestore

### TDD Workflow

For each task:
1. **RED**: Write failing tests first
2. **GREEN**: Implement minimal code to pass tests
3. **REFACTOR**: Improve code quality while keeping tests green
4. Run: `dart test`, `dart analyze`, `dart run build_runner build`

### Platform Support

Ensure all features work correctly on:
- Linux (Ubuntu) with Bash
- Windows with CMD
- Windows with PowerShell

### Security

- Never commit service account files
- Credentials never saved to disk
- Validate environment before production operations
- Use emulator for all development

---

## Next Steps

1. Complete environment setup (see `DUAL_CLI_SETUP.md`)
2. Verify emulator is running: `firebase emulators:start`
3. Set environment variable: `export FIRESTORE_EMULATOR_HOST=localhost:8080`
4. Start with Phase 1, Task 1.1
5. Follow RED-GREEN-REFACTOR cycle for each task
