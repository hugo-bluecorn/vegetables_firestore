import 'package:dart_firebase_admin/firestore.dart';
import 'package:vegetables_firestore/models/vegetable.dart';

/// Repository for Vegetable CRUD operations with Firestore
class VegetableRepository {
  final Firestore _firestore;
  static const String collectionName = 'vegetables_test';

  VegetableRepository(this._firestore);

  /// Create a new vegetable in Firestore
  Future<String> create(Vegetable vegetable, {String? documentId}) async {
    try {
      final collection = _firestore.collection(collectionName);

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
  /// Note: Firestore Admin SDK doesn't support batch operations in the same way as client SDK,
  /// so we create them individually in a loop
  Future<List<String>> createBatch(List<Vegetable> vegetables) async {
    try {
      final docIds = <String>[];

      for (final vegetable in vegetables) {
        final docId = await create(vegetable);
        docIds.add(docId);
      }

      return docIds;
    } catch (e) {
      throw RepositoryException('Failed to batch create vegetables: $e');
    }
  }

  /// Get a vegetable by document ID
  Future<Vegetable?> getById(String documentId) async {
    try {
      final doc =
          await _firestore.collection(collectionName).doc(documentId).get();

      if (!doc.exists || doc.data == null) {
        return null;
      }

      return VegetableMapper.fromMap(doc.data as Map<String, dynamic>);
    } catch (e) {
      throw RepositoryException('Failed to get vegetable: $e');
    }
  }

  /// Get vegetable by name (case-sensitive)
  Future<Vegetable?> getByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('name', WhereFilter.equal, name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return VegetableMapper.fromMap(doc.data as Map<String, dynamic>);
    } catch (e) {
      throw RepositoryException('Failed to get vegetable by name: $e');
    }
  }

  /// Get all vegetables (with optional limit)
  Future<List<Vegetable>> getAll({int? limit}) async {
    try {
      var query = _firestore.collection(collectionName) as Query;

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => VegetableMapper.fromMap(doc.data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to get all vegetables: $e');
    }
  }

  /// Update a vegetable
  Future<void> update(String documentId, Vegetable vegetable) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(documentId)
          .update(vegetable.toMap());
    } catch (e) {
      throw RepositoryException('Failed to update vegetable: $e');
    }
  }

  /// Delete a vegetable
  Future<void> delete(String documentId) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
    } catch (e) {
      throw RepositoryException('Failed to delete vegetable: $e');
    }
  }

  /// Query vegetables by harvest state
  Future<List<Vegetable>> getByHarvestState(HarvestState state) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('harvestState', WhereFilter.equal, state.name)
          .get();

      return snapshot.docs
          .map((doc) => VegetableMapper.fromMap(doc.data as Map<String, dynamic>))
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
