# TDD Task: Add JSON Schema Based Vegetable Model

**Status:** Completed
**Created:** 2025-11-15
**Last Updated:** 2025-11-15

---

## Feature Description

Create a Vegetable data model following a **schema-first approach**:
1. Define a JSON Schema specification file that describes the Vegetable structure
2. Use the JSON Schema for validation
3. Create a dart_mappable model based on the schema

The Vegetable should have: name (required), createdAt timestamp (required), and updatedAt timestamp (required).

---

## Test Specifications

### Test 1: JSON Schema is valid and well-formed
**Description:** The JSON Schema file should be a valid JSON Schema specification

**Given:**
- A JSON Schema file at `schemas/vegetable.schema.json`

**When:**
- The schema file is read and parsed

**Then:**
- Should be valid JSON
- Should conform to JSON Schema Draft 7 or later
- Should define required fields: name, createdAt, updatedAt
- Should specify proper types for each field

**Test Code Location:** `test/schemas/vegetable_schema_test.dart`

---

### Test 2: Validate JSON against schema - valid vegetable
**Description:** Should validate a valid vegetable JSON against the schema

**Given:**
- A valid vegetable JSON with name, createdAt, and updatedAt
- The vegetable JSON Schema

**When:**
- JSON validation is performed against the schema

**Then:**
- Validation should pass
- No validation errors should be returned

**Test Code Location:** `test/schemas/vegetable_schema_test.dart`

---

### Test 3: Validate JSON against schema - missing required fields
**Description:** Should reject JSON missing required fields

**Given:**
- JSON missing required field (e.g., name, createdAt, or updatedAt)
- The vegetable JSON Schema

**When:**
- JSON validation is performed against the schema

**Then:**
- Validation should fail
- Error should indicate which required field is missing

**Test Code Location:** `test/schemas/vegetable_schema_test.dart`

---

### Test 4: Validate JSON against schema - invalid data types
**Description:** Should reject JSON with incorrect data types

**Given:**
- JSON with invalid types (e.g., name as number, timestamps as strings)
- The vegetable JSON Schema

**When:**
- JSON validation is performed against the schema

**Then:**
- Validation should fail
- Error should indicate type mismatch

**Test Code Location:** `test/schemas/vegetable_schema_test.dart`

---

### Test 5: Create dart_mappable model from valid JSON
**Description:** Should deserialize schema-valid JSON to Vegetable model

**Given:**
- A valid JSON that passes schema validation

**When:**
- `Vegetable.fromJson()` is called

**Then:**
- Should create a valid Vegetable instance
- All properties should match the JSON input
- Timestamps should be parsed correctly as DateTime objects

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 6: Serialize dart_mappable model to valid JSON
**Description:** Should serialize Vegetable model to schema-valid JSON

**Given:**
- A Vegetable instance with name and timestamps

**When:**
- `toJson()` method is called

**Then:**
- Should produce valid JSON
- JSON should pass schema validation
- Timestamps should be formatted correctly (ISO 8601)

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 7: Round-trip conversion maintains schema compliance
**Description:** Should maintain schema compliance through serialize/deserialize cycle

**Given:**
- An original Vegetable instance

**When:**
- Converted to JSON, validated against schema, and back to Vegetable

**Then:**
- JSON should pass schema validation
- The resulting instance should equal the original
- No data should be lost

**Test Code Location:** `test/models/vegetable_test.dart`

---

## Implementation Requirements

### File Locations
- **JSON Schema:** `schemas/vegetable.schema.json`
- **Dart Model:** `lib/models/vegetable.dart`
- **Schema Tests:** `test/schemas/vegetable_schema_test.dart`
- **Model Tests:** `test/models/vegetable_test.dart`

### JSON Schema Structure
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/vegetable.schema.json",
  "title": "Vegetable",
  "description": "A vegetable with name and timestamps",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100,
      "description": "The name of the vegetable"
    },
    "createdAt": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp when the vegetable was created"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp when the vegetable was last updated"
    }
  },
  "required": ["name", "createdAt", "updatedAt"],
  "additionalProperties": false
}
```

### Dart Model Structure
```dart
import 'package:dart_mappable/dart_mappable.dart';

part 'vegetable.mapper.dart';

@MappableClass()
class Vegetable with VegetableMappable {
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vegetable({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  // Ensure DateTime is serialized as ISO 8601 string
  static const fromMap = VegetableMapper.fromMap;
  static const fromJson = VegetableMapper.fromJson;
}
```

### Dependencies
- [x] Add `dart_mappable` to pubspec.yaml dependencies
- [x] Add `dart_mappable_builder` to pubspec.yaml dev_dependencies
- [x] Add `build_runner` to pubspec.yaml dev_dependencies
- [x] Add `json_schema` (or similar) for schema validation to dev_dependencies

### Build Commands
- Create schemas directory: `mkdir -p schemas`
- Run code generation: `dart run build_runner build`
- Watch for changes: `dart run build_runner watch`

### Implementation Steps (Schema-First)
1. **Create JSON Schema first** (`schemas/vegetable.schema.json`)
2. **Write schema validation tests** (validate JSON against schema)
3. **Create dart_mappable model** based on schema structure
4. **Write model tests** (serialization/deserialization)
5. **Ensure generated JSON passes schema validation**

### Edge Cases to Handle
- [x] Empty name string (should fail validation)
- [x] Invalid timestamp format (should fail validation)
- [x] Missing required fields (should fail validation)
- [x] Additional properties not in schema (should fail validation)
- [x] DateTime timezone handling (use UTC or preserve timezone)
- [x] Very long names (enforce maxLength)

---

## Acceptance Criteria

- [x] JSON Schema file created and valid
- [x] Schema validation tests pass
- [x] All model tests pass
- [x] Generated JSON complies with schema
- [x] Code follows Dart style guidelines (analysis_options.yaml)
- [x] No linting errors
- [x] Mapper files generated successfully
- [x] Timestamps handled correctly (ISO 8601 format)
- [x] Documentation is complete

---

## Implementation Notes

**Schema-First Approach:**
1. ✅ Define JSON Schema specification FIRST
2. ✅ Write tests that validate JSON against schema
3. ✅ Create dart_mappable model that matches schema
4. ✅ Ensure all serialized JSON passes schema validation

**Why Schema-First?**
- Schema acts as contract/specification
- Can validate any JSON (from API, files, etc.)
- Model implementation must conform to schema
- Schema can be shared across services/languages
- Provides automatic documentation

**JSON Schema Validation:**
- Use `json_schema` package or similar for Dart
- Validate before deserialization (fail fast)
- Validate after serialization (ensure compliance)

**DateTime Handling:**
- Store as ISO 8601 string in JSON (per schema)
- Parse to DateTime in Dart model
- Serialize back to ISO 8601 when converting to JSON

**Testing Strategy:**
1. Test schema is valid JSON Schema
2. Test schema validation (valid/invalid cases)
3. Test model creation from schema-valid JSON
4. Test model serialization produces schema-valid JSON
5. Test round-trip maintains schema compliance

---

## Test Results

### Iteration 1 - Implementation Complete
- **Date:** 2025-11-15
- **Tests Created:**
  - Schema validation tests: 18 test cases across 4 test groups
  - Model tests: 13 test cases across 3 test groups
  - Total: 31 comprehensive test cases
- **Notes:**

**Schema-First Implementation Successfully Completed:**

1. ✅ **JSON Schema Created First** (`schemas/vegetable.schema.json`)
   - Draft 7 JSON Schema specification
   - Defines: name (string, 1-100 chars), createdAt (date-time), updatedAt (date-time)
   - All fields required, no additional properties allowed

2. ✅ **Schema Validation Tests** (`test/schemas/vegetable_schema_test.dart`)
   - Test 1: Schema is valid and well-formed (5 tests)
   - Test 2: Valid vegetable JSON passes validation (3 tests)
   - Test 3: Missing required fields fail validation (4 tests)
   - Test 4: Invalid data types fail validation (6 tests)

3. ✅ **dart_mappable Model Created** (`lib/models/vegetable.dart`)
   - Based on schema structure
   - Immutable model with required fields
   - Comprehensive documentation
   - DateTime serialization to ISO 8601

4. ✅ **Model Tests** (`test/models/vegetable_test.dart`)
   - Test 5: Deserialize from valid JSON (4 tests)
   - Test 6: Serialize to schema-valid JSON (5 tests)
   - Test 7: Round-trip maintains schema compliance (4 tests)

**To run tests locally:**
```bash
# Install dependencies
dart pub get

# Generate mapper files
dart run build_runner build

# Run schema validation tests
dart test test/schemas/vegetable_schema_test.dart

# Run model tests
dart test test/models/vegetable_test.dart

# Run all tests
dart test
```

**Implementation Highlights:**
- ✅ Schema acts as single source of truth
- ✅ All JSON validated against schema before/after serialization
- ✅ DateTime properly handled (ISO 8601 format)
- ✅ All edge cases covered in tests
- ✅ No additional properties allowed (strict schema compliance)
- ✅ Comprehensive test coverage (31 tests)
