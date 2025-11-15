# TDD Task: Add Harvest State 'not_available'

**Status:** Implementation Complete (Awaiting Local Testing)
**Created:** 2025-11-15
**Last Updated:** 2025-11-15

---

## Feature Description

Add a new harvest state `notAvailable` to the `HarvestState` enum to represent vegetables that are currently not available. This requires updates to the enum, translation system, localization methods, and all associated tests.

---

## Test Specifications

### Test 1: HarvestState Enum Contains notAvailable
**Description:** Verify that the HarvestState enum includes the notAvailable value

**Given:**
- The HarvestState enum is defined in `lib/models/vegetable.dart`

**When:**
- The enum is accessed

**Then:**
- `HarvestState.notAvailable` should be a valid enum value
- The enum should have 4 total values: scarce, enough, plenty, notAvailable

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 2: Vegetable Serialization with notAvailable State
**Description:** Verify that a Vegetable with notAvailable state can be serialized to JSON

**Given:**
- A Vegetable instance with harvestState set to HarvestState.notAvailable
- Valid timestamps and translations

**When:**
- The vegetable is serialized using `toJson()`

**Then:**
- The JSON should contain `"harvestState": "notAvailable"`
- All other fields should serialize correctly

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 3: Vegetable Deserialization with notAvailable State
**Description:** Verify that JSON with notAvailable state can be deserialized to a Vegetable

**Given:**
- A JSON string with `"harvestState": "notAvailable"`

**When:**
- The JSON is deserialized using `Vegetable.fromJson()`

**Then:**
- The resulting Vegetable should have `harvestState == HarvestState.notAvailable`
- All other fields should deserialize correctly

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 4: HarvestStateTranslation Contains notAvailable Field
**Description:** Verify that HarvestStateTranslation class includes notAvailable field

**Given:**
- A HarvestStateTranslation instance

**When:**
- The instance is created with all required fields

**Then:**
- The instance should have a `notAvailable` field
- The field should be required in the constructor

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 5: Localized Harvest State for notAvailable (English)
**Description:** Verify that getLocalizedHarvestState returns correct English translation for notAvailable

**Given:**
- A Vegetable with harvestState = HarvestState.notAvailable
- English translation for notAvailable is "Not Available"

**When:**
- `vegetable.getLocalizedHarvestState('en')` is called

**Then:**
- The method should return "Not Available"

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 6: Localized Harvest State for notAvailable (Dutch)
**Description:** Verify that getLocalizedHarvestState returns correct Dutch translation for notAvailable

**Given:**
- A Vegetable with harvestState = HarvestState.notAvailable
- Dutch translation for notAvailable is "Niet beschikbaar"

**When:**
- `vegetable.getLocalizedHarvestState('nl')` is called

**Then:**
- The method should return "Niet beschikbaar"

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 7: Localized Harvest State for notAvailable (French)
**Description:** Verify that getLocalizedHarvestState returns correct French translation for notAvailable

**Given:**
- A Vegetable with harvestState = HarvestState.notAvailable
- French translation for notAvailable is "Non disponible"

**When:**
- `vegetable.getLocalizedHarvestState('fr')` is called

**Then:**
- The method should return "Non disponible"

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 8: Localized Harvest State for notAvailable (German)
**Description:** Verify that getLocalizedHarvestState returns correct German translation for notAvailable

**Given:**
- A Vegetable with harvestState = HarvestState.notAvailable
- German translation for notAvailable is "Nicht verfügbar"

**When:**
- `vegetable.getLocalizedHarvestState('de')` is called

**Then:**
- The method should return "Nicht verfügbar"

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 9: JSON Schema Validation with notAvailable
**Description:** Verify that JSON with notAvailable state passes schema validation

**Given:**
- A valid vegetable JSON with `"harvestState": "notAvailable"`
- The JSON schema at `schemas/vegetable.schema.json`

**When:**
- The JSON is validated against the schema

**Then:**
- The validation should pass without errors
- notAvailable should be recognized as a valid harvest state value

**Test Code Location:** `test/schemas/vegetable_schema_test.dart`

---

## Implementation Requirements

### File Location
- **Source:** `lib/models/vegetable.dart`
- **Tests:** `test/models/vegetable_test.dart`, `test/schemas/vegetable_schema_test.dart`
- **Data:** `data/vegetables_complete.json`
- **Schema:** `schemas/vegetable.schema.json`
- **Generated:** `lib/models/vegetable.mapper.dart` (auto-generated)

### Code Changes Required

#### 1. Update HarvestState Enum
```dart
enum HarvestState {
  scarce,
  enough,
  plenty,
  notAvailable,  // Add this
}
```

#### 2. Update HarvestStateTranslation Class
```dart
class HarvestStateTranslation {
  final String scarce;
  final String enough;
  final String plenty;
  final String notAvailable;  // Add this

  const HarvestStateTranslation({
    required this.scarce,
    required this.enough,
    required this.plenty,
    required this.notAvailable,  // Add this
  });
}
```

#### 3. Update getLocalizedHarvestState Method
```dart
String getLocalizedHarvestState(String languageCode) {
  final translation = _getTranslation(languageCode);
  switch (harvestState) {
    case HarvestState.scarce:
      return translation.harvestState.scarce;
    case HarvestState.enough:
      return translation.harvestState.enough;
    case HarvestState.plenty:
      return translation.harvestState.plenty;
    case HarvestState.notAvailable:  // Add this case
      return translation.harvestState.notAvailable;
  }
}
```

#### 4. Update Translation Data
Add to `data/vegetables_complete.json`:
```json
{
  "harvestStateTranslations": {
    "en": {
      "scarce": "Scarce",
      "enough": "Enough",
      "plenty": "Plenty",
      "notAvailable": "Not Available"
    },
    "nl": {
      "scarce": "Schaars",
      "enough": "Genoeg",
      "plenty": "Overvloed",
      "notAvailable": "Niet beschikbaar"
    },
    "fr": {
      "scarce": "Rare",
      "enough": "Suffisant",
      "plenty": "Abondant",
      "notAvailable": "Non disponible"
    },
    "de": {
      "scarce": "Knapp",
      "enough": "Ausreichend",
      "plenty": "Reichlich",
      "notAvailable": "Nicht verfügbar"
    }
  }
}
```

#### 5. Update JSON Schema
Update `schemas/vegetable.schema.json` to include "notAvailable" in the enum values for harvestState.

### Dependencies
- [x] dart_mappable (already in pubspec.yaml)
- [x] build_runner (already in pubspec.yaml)
- [ ] Run `dart run build_runner build` after model changes

### Edge Cases to Handle
- [ ] Ensure all existing tests still pass
- [ ] Verify backward compatibility (existing JSON without notAvailable should still work)
- [ ] Ensure fallback behavior for unsupported language codes works with notAvailable
- [ ] Verify mapper code generation includes notAvailable

---

## Acceptance Criteria

- [ ] All 9 test specifications pass
- [ ] HarvestState enum includes notAvailable
- [ ] All 4 language translations are provided (NL, EN, FR, DE)
- [ ] Serialization/deserialization works correctly
- [ ] JSON schema validation passes
- [ ] Code follows Dart style guidelines (analysis_options.yaml)
- [ ] No linting errors (`dart analyze` passes)
- [ ] Mapper code regenerated successfully (`dart run build_runner build`)
- [ ] All existing tests still pass
- [ ] Documentation is complete (enum value has doc comment)

---

## Implementation Notes

### Translation Choices
- **English:** "Not Available" - Standard English phrase
- **Dutch:** "Niet beschikbaar" - Common Dutch translation
- **French:** "Non disponible" - Standard French translation
- **German:** "Nicht verfügbar" - Standard German translation

### Implementation Order
1. Write all tests first (TDD approach)
2. Update HarvestState enum
3. Update HarvestStateTranslation class
4. Update getLocalizedHarvestState method
5. Update translation data files
6. Update JSON schema
7. Run `dart run build_runner build` to regenerate mapper code
8. Run tests and verify all pass
9. Run `dart analyze` to ensure no linting errors

### Important Considerations
- The mapper code (`vegetable.mapper.dart`) is auto-generated and should not be edited manually
- After any changes to the model, always run `dart run build_runner build`
- Ensure the switch statement in `getLocalizedHarvestState` is exhaustive to avoid compilation errors

---

## Test Results

### Iteration 1: Test Writing (RED Phase)
- **Date:** 2025-11-15
- **Tests Passed:** N/A (Tests written but not yet run)
- **Notes:** Created 9 comprehensive test specifications covering:
  - Enum validation (2 tests)
  - Serialization/deserialization (2 tests)
  - HarvestStateTranslation field validation (2 tests)
  - Localization for all 4 languages (4 tests)
  - JSON Schema validation (2 tests)

### Iteration 2: Implementation (GREEN Phase)
- **Date:** 2025-11-15
- **Tests Passed:** Cannot run (Dart not available in environment)
- **Notes:** Implementation completed:
  - ✅ Added `notAvailable` to HarvestState enum (lib/models/vegetable.dart:18)
  - ✅ Added `notAvailable` field to HarvestStateTranslation class (lib/models/vegetable.dart:34)
  - ✅ Updated `getLocalizedHarvestState` switch statement (lib/models/vegetable.dart:168-169)
  - ✅ Updated JSON schema enum values (schemas/vegetable.schema.json:26)
  - ✅ Updated JSON schema HarvestStateTranslation definition (schemas/vegetable.schema.json:72, 89-93)
  - ✅ Added translations in all 4 languages (data/vegetables_complete.json:7, 13, 19, 25)
  - ✅ Updated test helper functions with notAvailable translations
  - ✅ Updated documentation comments

**REQUIRED NEXT STEPS (Must be run locally):**
1. Run `dart pub get` to ensure dependencies are up to date
2. Run `dart run build_runner build` to regenerate mapper code
3. Run `dart test` to verify all tests pass
4. Run `dart analyze` to ensure no linting errors

**Expected Results:**
- All 9 new TDD tests should pass
- All existing tests should continue to pass
- No analyzer errors or warnings
- Mapper code should include notAvailable in serialization/deserialization
