import 'package:dart_mappable/dart_mappable.dart';

part 'vegetable.mapper.dart';

/// Harvest state of a vegetable
@MappableEnum()
enum HarvestState {
  /// Scarce availability
  scarce,

  /// Enough availability
  enough,

  /// Plenty availability
  plenty,
}

/// A vegetable with name, timestamps, and harvest state
///
/// This model is based on the JSON Schema at schemas/vegetable.schema.json
/// and provides serialization/deserialization using dart_mappable.
///
/// All fields are required:
/// - [name]: The name of the vegetable (1-100 characters)
/// - [createdAt]: ISO 8601 timestamp when the vegetable was created
/// - [updatedAt]: ISO 8601 timestamp when the vegetable was last updated
/// - [harvestState]: The harvest state (scarce, enough, or plenty)
@MappableClass()
class Vegetable with VegetableMappable {
  /// The name of the vegetable
  final String name;

  /// ISO 8601 timestamp when the vegetable was created
  final DateTime createdAt;

  /// ISO 8601 timestamp when the vegetable was last updated
  final DateTime updatedAt;

  /// The harvest state of the vegetable
  final HarvestState harvestState;

  const Vegetable({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.harvestState,
  });

  /// Creates a Vegetable from a Map
  static const fromMap = VegetableMapper.fromMap;

  /// Creates a Vegetable from a JSON string
  static const fromJson = VegetableMapper.fromJson;
}
