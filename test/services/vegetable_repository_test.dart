import 'dart:io';
import 'package:test/test.dart';
import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import '../test_helpers/firestore_test_helper.dart';
import '../test_helpers/vegetable_test_helper.dart';

void main() {
  // Skip all tests if emulator is not running
  final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
  if (emulatorHost == null) {
    print('Skipping VegetableRepository tests: FIRESTORE_EMULATOR_HOST not set');
    print('To run these tests, start the Firebase emulator:');
    print('  export FIRESTORE_EMULATOR_HOST="localhost:8080"');
    print('  firebase emulators:start');
    return;
  }

  late VegetableRepository repository;

  setUpAll(() async {
    final firestore = await FirestoreTestHelper.initialize();
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
      final vegetable =
          VegetableTestHelper.createTestVegetable(name: 'Komkommer');
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
      final vegetable =
          VegetableTestHelper.createTestVegetable(name: 'Courgette');
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
      final plentyVegetables =
          await repository.getByHarvestState(HarvestState.plenty);

      // Then
      expect(plentyVegetables.length, greaterThanOrEqualTo(2));
      final names = plentyVegetables.map((v) => v.name).toList();
      expect(names, contains('Broccoli'));
      expect(names, contains('Spinazie'));
      expect(names, isNot(contains('Bloemkool')));
    });
  });

  group('VegetableRepository - Query by Name', () {
    test('should get vegetable by name', () async {
      // Given
      final vegetable = VegetableTestHelper.createTestVegetable(name: 'Radijs');
      final docId = await repository.create(vegetable);
      FirestoreTestHelper.trackDocument(docId);

      // When
      final retrieved = await repository.getByName('Radijs');

      // Then
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Radijs'));
    });

    test('should return null for non-existent name', () async {
      // When
      final retrieved = await repository.getByName('NonExistentVegetable');

      // Then
      expect(retrieved, isNull);
    });

    test('should check if vegetable exists by name', () async {
      // Given
      final vegetable = VegetableTestHelper.createTestVegetable(name: 'Kool');
      final docId = await repository.create(vegetable);
      FirestoreTestHelper.trackDocument(docId);

      // When
      final exists = await repository.existsByName('Kool');
      final notExists = await repository.existsByName('DoesNotExist');

      // Then
      expect(exists, isTrue);
      expect(notExists, isFalse);
    });
  });
}
