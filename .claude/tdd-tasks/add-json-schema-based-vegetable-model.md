# TDD Task: Add JSON Schema Based Vegetable Model

**Status:** Not Started
**Created:** 2025-11-15
**Last Updated:** 2025-11-15

---

## Feature Description

Create a Vegetable data model class using `dart_mappable` that provides JSON serialization/deserialization capabilities. The model should represent a vegetable with properties like name, category, color, and nutritional information, with full support for converting to/from JSON format.

---

## Test Specifications

### Test 1: Create vegetable instance with required fields
**Description:** Should be able to create a Vegetable instance with all required properties

**Given:**
- Valid vegetable data (name, category, color)

**When:**
- A Vegetable instance is created

**Then:**
- The instance should be created successfully
- All properties should be accessible
- Properties should match the input values

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 2: Serialize vegetable to JSON
**Description:** Should convert a Vegetable instance to a JSON map

**Given:**
- A Vegetable instance with known property values

**When:**
- `toJson()` method is called

**Then:**
- Should return a valid JSON Map<String, dynamic>
- All properties should be present in JSON
- Values should match the instance properties
- JSON keys should use snake_case or camelCase as appropriate

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 3: Deserialize vegetable from JSON
**Description:** Should create a Vegetable instance from a JSON map

**Given:**
- A valid JSON map representing a vegetable

**When:**
- `Vegetable.fromJson()` method is called

**Then:**
- Should create a valid Vegetable instance
- All properties should be correctly parsed
- Values should match the JSON input

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 4: Round-trip JSON conversion
**Description:** Should maintain data integrity through serialize/deserialize cycle

**Given:**
- An original Vegetable instance

**When:**
- Converted to JSON and back to Vegetable

**Then:**
- The resulting instance should equal the original
- No data should be lost
- All properties should match exactly

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 5: Handle optional fields correctly
**Description:** Should properly handle optional properties (like description, image URL)

**Given:**
- JSON with missing optional fields
- Vegetable instance created without optional fields

**When:**
- Deserialized from JSON or serialized to JSON

**Then:**
- Optional fields should be null when not provided
- Serialization should omit or include null values as configured
- No errors should occur with missing optional fields

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 6: Validate required fields
**Description:** Should validate that required fields are present

**Given:**
- JSON missing required fields (e.g., name)

**When:**
- Attempting to deserialize from JSON

**Then:**
- Should throw appropriate error or handle gracefully
- Error message should indicate which field is missing

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 7: Handle nested objects
**Description:** Should support nested objects (e.g., nutritional info)

**Given:**
- JSON with nested nutritional information object

**When:**
- Deserialized to Vegetable model

**Then:**
- Nested objects should be properly parsed
- Nested properties should be accessible
- Serialization should maintain nested structure

**Test Code Location:** `test/models/vegetable_test.dart`

---

## Implementation Requirements

### File Location
- **Source:** `lib/models/vegetable.dart`
- **Tests:** `test/models/vegetable_test.dart`

### Model Structure
```dart
import 'package:dart_mappable/dart_mappable.dart';

part 'vegetable.mapper.dart';

@MappableClass()
class Vegetable with VegetableMappable {
  final String id;
  final String name;
  final String category;
  final String? color;
  final String? description;
  final String? imageUrl;
  final NutritionalInfo? nutritionalInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Vegetable({
    required this.id,
    required this.name,
    required this.category,
    this.color,
    this.description,
    this.imageUrl,
    this.nutritionalInfo,
    this.createdAt,
    this.updatedAt,
  });
}

@MappableClass()
class NutritionalInfo with NutritionalInfoMappable {
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fiber;
  final List<String>? vitamins;

  const NutritionalInfo({
    this.calories,
    this.protein,
    this.carbs,
    this.fiber,
    this.vitamins,
  });
}
```

### Dependencies
- [ ] Add `dart_mappable` to pubspec.yaml dependencies
- [ ] Add `dart_mappable_builder` to pubspec.yaml dev_dependencies
- [ ] Add `build_runner` to pubspec.yaml dev_dependencies

### Build Commands
- Run code generation: `dart run build_runner build`
- Watch for changes: `dart run build_runner watch`

### Edge Cases to Handle
- [ ] Null/missing optional fields
- [ ] Missing required fields
- [ ] Invalid JSON format
- [ ] Empty strings vs null
- [ ] Date/time parsing and formatting
- [ ] List fields (empty lists vs null)
- [ ] Nested object validation
- [ ] Unicode characters in text fields

---

## Acceptance Criteria

- [ ] All tests pass
- [ ] Code follows Dart style guidelines (analysis_options.yaml)
- [ ] No linting errors
- [ ] Edge cases are handled
- [ ] Documentation is complete
- [ ] Mapper files are generated successfully
- [ ] JSON serialization works bidirectionally
- [ ] Optional fields handled correctly
- [ ] Nested objects supported

---

## Implementation Notes

**Using dart_mappable:**
1. Add `@MappableClass()` annotation to classes
2. Mix in generated mixin (e.g., `with VegetableMappable`)
3. Add `part` directive for generated mapper file
4. Run `dart run build_runner build` to generate mappers

**JSON Serialization:**
- `toJson()` method automatically generated
- `fromJson()` factory constructor automatically generated
- `copyWith()` method for immutable updates
- Equality and hashCode implementations included

**Testing Strategy:**
- Test basic instantiation
- Test JSON serialization (toJson)
- Test JSON deserialization (fromJson)
- Test round-trip conversion
- Test edge cases (null, missing fields)
- Test nested objects

---

## Test Results

### Iteration 1
- **Date:** [Not yet run]
- **Tests Passed:** 0/7
- **Notes:** [Awaiting implementation]
