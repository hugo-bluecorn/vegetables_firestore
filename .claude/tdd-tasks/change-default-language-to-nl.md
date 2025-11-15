# TDD Task: Change Default Language to NL

**Status:** Completed
**Created:** 2025-01-15
**Last Updated:** 2025-01-15

---

## Feature Description

Change the default language from EN (English) to NL (Dutch) throughout the codebase. This involves:
1. Updating the schema to reflect NL as the primary/default language for the `name` field
2. Modifying the Vegetable model's fallback behavior in helper methods to default to NL instead of EN
3. Updating all documentation, comments, and descriptions to reflect NL as the default language
4. Updating test data and examples to use Dutch names as defaults
5. Ensuring schema validation and model behavior consistently treat NL as the primary language

This change reflects the fact that the application is primarily targeting Dutch-speaking users, with other languages (EN, FR, DE) as translations.

---

## Test Specifications

### Test 1: Schema Validation - NL as Default Language
**Description:** Validates that the schema documentation reflects NL (Dutch) as the default language

**Given:**
- The vegetable JSON schema at `schemas/vegetable.schema.json`

**When:**
- The schema documentation is reviewed

**Then:**
- The `name` field description states "The default/primary name of the vegetable (typically Dutch)"
- The `harvestState` field description states "The default harvest state of the vegetable (typically Dutch)"
- All schema descriptions reference NL as the primary language

**Test Code Location:** `test/schemas/vegetable_schema_test.dart`

---

### Test 2: Model Comments - NL as Default Language
**Description:** Validates that model class documentation reflects NL as default

**Given:**
- The Vegetable model at `lib/models/vegetable.dart`

**When:**
- Class and field documentation is reviewed

**Then:**
- The `name` field documentation states "The default/primary name of the vegetable (typically Dutch)"
- The class documentation mentions NL as the primary language
- All doc comments reference Dutch as the default

**Test Code Location:** Manual code review / `test/models/vegetable_test.dart`

---

### Test 3: getLocalizedName() Fallback to NL
**Description:** Validates that getLocalizedName() returns Dutch name for unsupported language codes

**Given:**
- A Vegetable instance with translations
- The primary `name` field is set to Dutch name "Tomaat"
- An unsupported language code "es" (Spanish)

**When:**
- `getLocalizedName('es')` is called

**Then:**
- Returns "Tomaat" (the primary Dutch name)
- Does not return the English translation
- Fallback behavior defaults to NL

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 4: getLocalizedHarvestState() Fallback to NL
**Description:** Validates that getLocalizedHarvestState() returns Dutch translation for unsupported language codes

**Given:**
- A Vegetable instance with harvestState = HarvestState.enough
- Dutch translation for "enough" is "Genoeg"
- An unsupported language code "es" (Spanish)

**When:**
- `getLocalizedHarvestState('es')` is called

**Then:**
- Returns "Genoeg" (the Dutch translation)
- Does not return the English translation "Enough"
- Fallback behavior defaults to NL translations

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 5: Test Data Uses Dutch Defaults
**Description:** Validates that test helper functions create Dutch names as defaults

**Given:**
- Helper functions in test files

**When:**
- `createValidVegetable()` or similar helpers are called

**Then:**
- The primary `name` field contains a Dutch name (e.g., "Tomaat" not "Tomato")
- Test data reflects Dutch as the default language
- Examples and fixtures use Dutch naming

**Test Code Location:** `test/schemas/vegetable_schema_test.dart` and `test/models/vegetable_test.dart`

---

### Test 6: Round-Trip with Dutch Default
**Description:** Validates that serialization/deserialization preserves Dutch as default

**Given:**
- A Vegetable instance with Dutch name "Tomaat" as primary name
- Complete translations for all languages

**When:**
- Convert to JSON with toJson()
- Convert back to Vegetable with fromJson()

**Then:**
- The primary `name` field is "Tomaat" (Dutch)
- All translations are preserved
- Default language remains NL

**Test Code Location:** `test/models/vegetable_test.dart`

---

### Test 7: Schema Example Uses Dutch
**Description:** Validates that schema examples and descriptions use Dutch as default

**Given:**
- Example JSON in TDD documentation
- Example data files

**When:**
- Examples are reviewed

**Then:**
- Primary `name` field shows Dutch vegetable name (e.g., "Tomaat")
- Primary `harvestState` enum values remain English (scarce/enough/plenty) for technical consistency
- Documentation examples reflect Dutch as default language

**Test Code Location:** Manual review of documentation and `data/` files

---

## Implementation Requirements

### Files to Modify
- **Schema:** `schemas/vegetable.schema.json`
  - Update `name` field description to reference Dutch as default
  - Update `harvestState` field description to reference Dutch as default

- **Model:** `lib/models/vegetable.dart`
  - Update class and field documentation comments
  - Modify `getLocalizedName()` to fall back to `name` (which should be Dutch)
  - Modify `getLocalizedHarvestState()` and `_getTranslation()` to fall back to NL instead of EN
  - Update all doc comments to reference Dutch as default

- **Tests:** `test/schemas/vegetable_schema_test.dart`
  - Update helper function `createValidVegetable()` to use Dutch name as default
  - Update test data examples to use Dutch names

- **Tests:** `test/models/vegetable_test.dart`
  - Update helper functions to use Dutch names as defaults
  - Update test cases to verify NL fallback behavior
  - Update all test data to use Dutch as primary language

- **Documentation:** `.claude/tdd-tasks/add-internationalization-support.md`
  - Update example JSON to show Dutch as primary name
  - Update implementation notes to clarify NL as default

- **Data Files:** `data/vegetables_complete.json` (if exists)
  - Update primary `name` fields to use Dutch names
  - Ensure consistency with NL as default language

### Code Changes Required

**Current implementation in `lib/models/vegetable.dart`:**
```dart
String getLocalizedName(String languageCode) {
  switch (languageCode) {
    case 'en': return translations.en.name;
    case 'nl': return translations.nl.name;
    case 'fr': return translations.fr.name;
    case 'de': return translations.de.name;
    default: return name;  // Currently falls back to primary name (should be Dutch)
  }
}

Translation _getTranslation(String languageCode) {
  switch (languageCode) {
    case 'en': return translations.en;
    case 'nl': return translations.nl;
    case 'fr': return translations.fr;
    case 'de': return translations.de;
    default: return translations.en;  // NEEDS CHANGE: Should fall back to NL
  }
}
```

**Required change:**
```dart
Translation _getTranslation(String languageCode) {
  switch (languageCode) {
    case 'en': return translations.en;
    case 'nl': return translations.nl;
    case 'fr': return translations.fr;
    case 'de': return translations.de;
    default: return translations.nl;  // Changed from EN to NL
  }
}
```

### Dependencies
- [x] No new dependencies required
- [x] Existing dart_mappable implementation remains unchanged
- [x] Schema validation logic remains unchanged

### Edge Cases to Handle
- [x] Unsupported language codes fall back to NL translations
- [x] Primary `name` field should contain Dutch name by convention
- [x] English remains a supported language via translations.en
- [x] All four languages remain fully supported
- [x] Backward compatibility: existing data with English names will still work

---

## Acceptance Criteria

- [x] Schema descriptions updated to reference NL as default language
- [x] Model documentation updated to reference NL as default
- [x] `_getTranslation()` method falls back to `translations.nl` instead of `translations.en`
- [x] `getLocalizedName()` continues to fall back to `name` field (which should be Dutch)
- [x] All test helper functions use Dutch names as defaults
- [x] Test cases verify NL fallback behavior for unknown language codes
- [x] Example JSON in documentation uses Dutch as primary name
- [x] Data files (if any) use Dutch names as primary names
- [x] All tests structured with Dutch as default language
- [ ] Tests executed (requires local Dart environment)
- [ ] No linting errors (requires local Dart environment)
- [x] Code follows Dart style guidelines

---

## Implementation Notes

### Design Decisions

1. **Primary `name` field remains**: The schema doesn't change structurally - we still have a `name` field. The change is in convention and documentation - this field should contain the Dutch name by default.

2. **Fallback behavior**: When an unsupported language code is provided:
   - `getLocalizedName()` falls back to the `name` field (which should be Dutch)
   - `getLocalizedHarvestState()` falls back to Dutch translations via `_getTranslation()`

3. **Schema technical consistency**: The `harvestState` enum values remain English (`scarce`, `enough`, `plenty`) because these are technical identifiers used in code and APIs. Only the translations change.

4. **Backward compatibility**: Existing data with English in the `name` field will continue to work. This change is primarily about convention, documentation, and fallback behavior.

5. **Test-driven approach**:
   - First, update tests to expect Dutch as default
   - Update schema documentation
   - Update model documentation and fallback logic
   - Verify all tests pass

### Migration Considerations

For existing data:
- If `name` fields currently contain English names, they should be updated to Dutch names
- This is a data migration concern, not a code breaking change
- The code will work with either language in the `name` field
- Recommend updating data files to use Dutch as primary

---

## Test Results

### Implementation Summary
- **Date:** 2025-01-15
- **Status:** Completed
- **Tests Created:** 0 new tests (updated existing tests)
- **Tests Updated:** 2 test cases in Test 13 group

### Changes Implemented

**Schema Updates:**
- Updated `name` field description from "typically English" to "typically Dutch"
- Updated `harvestState` field description to clarify it's a technical identifier

**Model Updates (lib/models/vegetable.dart):**
- Updated class documentation to reference Dutch as primary language
- Updated `name` field documentation to "typically Dutch"
- Updated `getLocalizedName()` documentation
- Updated `getLocalizedHarvestState()` documentation
- **Critical change:** Modified `_getTranslation()` to fall back to `translations.nl` instead of `translations.en`

**Test Data Updates:**
- Updated all test data in `test/schemas/vegetable_schema_test.dart`:
  - "Carrot" → "Wortel"
  - "Tomato" → "Tomaat"
  - "Sweet Potato" → "Zoete aardappel"
  - "Test Vegetable" → "Test Groente"
- Updated all test data in `test/models/vegetable_test.dart`:
  - "Carrot" → "Wortel"
  - "Tomato" → "Tomaat"
  - "Sweet Potato" → "Zoete aardappel"
  - "Bell Pepper" → "Paprika"
  - "Kale" → "Boerenkool"
  - "Test Vegetable" → "Test Groente"

**Fallback Test Updates:**
- Test 13 group updated to verify NL fallback:
  - `getLocalizedName()` test now expects "Tomaat" (Dutch) for unknown languages
  - `getLocalizedHarvestState()` test now expects "Genoeg" (Dutch) for unknown languages

**Documentation Updates:**
- Updated example JSON in `add-internationalization-support.md` to use "Tomaat" as primary name
- Updated translation structure design notes to reference Dutch as default

### Test Verification

Tests cannot be executed in the sandbox environment due to missing Dart SDK. However, all test structures have been updated to reflect NL as the default language.

**Expected test behavior when run locally:**
1. All existing tests should pass with Dutch names as defaults
2. Fallback tests should verify Dutch translations are returned for unknown language codes
3. Schema validation should accept Dutch names as primary names
4. Round-trip serialization should preserve Dutch as primary language

### Next Steps for Local Environment

1. Pull changes from git
2. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate mapper files
3. Run `dart test` to verify all tests pass
4. Run `dart analyze` to ensure no linting errors
5. Verify that the fallback behavior works correctly with Dutch as default
