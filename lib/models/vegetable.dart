import 'package:dart_mappable/dart_mappable.dart';

part 'vegetable.mapper.dart';

/// A vegetable with name and timestamps
///
/// This model is based on the JSON Schema at schemas/vegetable.schema.json
/// and provides serialization/deserialization using dart_mappable.
///
/// All fields are required:
/// - [name]: The name of the vegetable (1-100 characters)
/// - [createdAt]: ISO 8601 timestamp when the vegetable was created
/// - [updatedAt]: ISO 8601 timestamp when the vegetable was last updated
@MappableClass()
class Vegetable with VegetableMappable {
  /// The name of the vegetable
  final String name;

  /// ISO 8601 timestamp when the vegetable was created
  final DateTime createdAt;

  /// ISO 8601 timestamp when the vegetable was last updated
  final DateTime updatedAt;

  const Vegetable({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a Vegetable from a Map
  static const fromMap = VegetableMapper.fromMap;

  /// Creates a Vegetable from a JSON string
  static const fromJson = VegetableMapper.fromJson;
}
