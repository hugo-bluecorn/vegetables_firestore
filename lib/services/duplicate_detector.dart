import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';

typedef ProgressCallback = void Function(int current, int total);

/// Service for detecting duplicate vegetables with optimized batch queries
class DuplicateDetector {
  final VegetableRepository _repository;

  DuplicateDetector(this._repository);

  /// Check if a vegetable with the given name already exists (case-sensitive)
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
    final existingNames =
        existingVegetables.map((v) => v.name.toLowerCase()).toSet();

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
    final existingNames =
        existingVegetables.map((v) => v.name.toLowerCase()).toSet();

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
