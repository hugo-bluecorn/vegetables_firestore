import 'package:vegetables_firestore/models/vegetable.dart';
import 'package:vegetables_firestore/services/vegetable_repository.dart';
import 'package:vegetables_firestore/services/duplicate_detector.dart';

typedef UploadProgressCallback = void Function(UploadProgress progress);

/// Service for uploading vegetables to Firestore with deduplication and batch optimization
class FirestoreUploadService {
  final VegetableRepository _repository;
  late final DuplicateDetector _duplicateDetector;

  static const int batchSize = 500; // Firestore batch limit
  static const int maxRetries = 3;

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

      final newVegetables =
          await _duplicateDetector.filterDuplicates(vegetables);

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
    if (vegetables.length <= batchSize) {
      return await _repository.createBatch(vegetables);
    }

    // For large lists, split into multiple batches
    final allIds = <String>[];
    for (var i = 0; i < vegetables.length; i += batchSize) {
      final end = (i + batchSize < vegetables.length)
          ? i + batchSize
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
