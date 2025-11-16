# Vegetable Import Feature - TDD Implementation Plan

## Overview

Build a CLI tool to import Dutch vegetable names from a text file, translate them to NL/EN/FR/DE using DeepL API (Free tier), create Vegetable domain objects with `harvestState: notAvailable`, and export to JSON.

**Key Requirements:**
- Input: Text file (.txt) with one Dutch vegetable name per line
- Translation: DeepL API Free tier
- Output: JSON file with Vegetable objects
- Security: API key prompted during tests, never saved, discarded after completion

## Phase 1: Setup & Dependencies

### 1.1 Add Dependencies to pubspec.yaml
```yaml
dependencies:
  http: ^1.2.0  # For DeepL API calls
```

### 1.2 Install Dependencies
```bash
dart pub get
```

### 1.3 Create TDD Task Specification
```bash
/tdd-new vegetable-import
```

## Phase 2: TDD Implementation (6 Red-Green-Refactor Iterations)

### Iteration 1: File Reading

**Objective:** Read vegetable names from text file

**RED - Write Failing Test:**
- **File:** `test/services/vegetable_file_reader_test.dart`
- **Test:** `VegetableFileReader.readNames(filePath)` should:
  - Read a .txt file with one vegetable name per line
  - Return `List<String>` of vegetable names
  - Handle file not found errors
  - Skip empty lines
  - Trim whitespace

**GREEN - Implement Minimal Code:**
- **File:** `lib/services/vegetable_file_reader.dart`
- Create `VegetableFileReader` class
- Implement `static Future<List<String>> readNames(String filePath)`
- Use `dart:io` File API

**REFACTOR:**
- Add input validation
- Improve error messages
- Add documentation

**Run:**
```bash
/tdd-test test/services/vegetable_file_reader_test.dart
```

---

### Iteration 2: DeepL API Client

**Objective:** Integrate with DeepL API for translation

**RED - Write Failing Test:**
- **File:** `test/services/deepl_client_test.dart`
- **Test:** `DeeplClient.translate(text, targetLang, apiKey)` should:
  - Translate Dutch text to English
  - Translate Dutch text to French
  - Translate Dutch text to German
  - Handle API errors gracefully
  - Validate API key format
  - **API Key Management:** Test prompts for API key via stdin
    ```dart
    // Test helper to get API key
    String getTestApiKey() {
      stdout.write('Enter DeepL API key for tests: ');
      return stdin.readLineSync() ?? '';
    }
    ```

**GREEN - Implement Minimal Code:**
- **File:** `lib/services/deepl_client.dart`
- Create `DeeplClient` class
- Implement `static Future<String> translate(String text, String targetLang, String apiKey)`
- DeepL Free tier endpoint: `https://api-free.deepl.com/v2/translate`
- HTTP headers:
  ```dart
  {
    'Authorization': 'DeepL-Auth-Key $apiKey',
    'Content-Type': 'application/json',
  }
  ```
- Request body:
  ```json
  {
    "text": ["text to translate"],
    "target_lang": "EN",
    "source_lang": "NL"
  }
  ```

**REFACTOR:**
- Add timeout handling (10 seconds)
- Add retry logic for transient failures
- Validate API response structure
- Add comprehensive error handling

**Run:**
```bash
/tdd-test test/services/deepl_client_test.dart
```

**Security Note:** API key is passed as parameter, never stored in files or environment variables.

---

### Iteration 3: Harvest State Translations

**Objective:** Translate harvest state labels to all languages

**RED - Write Failing Test:**
- **File:** `test/services/harvest_state_translation_service_test.dart`
- **Test:** `HarvestStateTranslationService.getTranslations(languageCode, apiKey)` should:
  - Return `HarvestStateTranslation` object for EN with all 4 values
  - Return `HarvestStateTranslation` object for FR with all 4 values
  - Return `HarvestStateTranslation` object for DE with all 4 values
  - Return Dutch values for NL (no translation needed)
  - Cache translations to minimize API calls

**GREEN - Implement Minimal Code:**
- **File:** `lib/services/harvest_state_translation_service.dart`
- Create `HarvestStateTranslationService` class
- Dutch source values:
  - `scarce` = "Schaars"
  - `enough` = "Voldoende"
  - `plenty` = "Overvloed"
  - `notAvailable` = "Niet beschikbaar"
- Implement `static Future<HarvestStateTranslation> getTranslations(String languageCode, String apiKey)`
- For NL: return Dutch values directly
- For EN/FR/DE: use `DeeplClient.translate()` for each value

**REFACTOR:**
- Cache translations in-memory (Map<String, HarvestStateTranslation>)
- Implement batch translation to reduce API calls
- Add validation for language codes

**Run:**
```bash
/tdd-test test/services/harvest_state_translation_service_test.dart
```

---

### Iteration 4: Vegetable Factory

**Objective:** Create complete Vegetable objects from Dutch names

**RED - Write Failing Test:**
- **File:** `test/services/vegetable_factory_test.dart`
- **Test:** `VegetableFactory.fromDutchName(name, apiKey)` should:
  - Create `Vegetable` object with translated name in all languages
  - Set `harvestState` to `HarvestState.notAvailable`
  - Include harvest state translations for all languages
  - Set `createdAt` to current timestamp
  - Set `updatedAt` to current timestamp
  - Validate against JSON schema
  - Serialize/deserialize correctly

**GREEN - Implement Minimal Code:**
- **File:** `lib/services/vegetable_factory.dart`
- Create `VegetableFactory` class
- Implement `static Future<Vegetable> fromDutchName(String name, String apiKey)`
- Logic:
  1. Translate `name` to EN, FR, DE (NL = original `name`)
  2. Get harvest state translations for all languages
  3. Build `VegetableTranslations` object
  4. Create `Vegetable` with:
     - `name`: Dutch name (original input)
     - `harvestState`: `HarvestState.notAvailable`
     - `createdAt`: `DateTime.now()`
     - `updatedAt`: `DateTime.now()`
     - `translations`: Complete translations object

**REFACTOR:**
- Optimize API calls by batching translations
- Add input validation (vegetable name format)
- Add error recovery for translation failures
- Consider fallback strategies

**Run:**
```bash
/tdd-test test/services/vegetable_factory_test.dart
```

---

### Iteration 5: Batch Importer

**Objective:** Import multiple vegetables from file

**RED - Write Failing Test:**
- **File:** `test/services/vegetable_importer_test.dart`
- **Test:** `VegetableImporter.importFromFile(inputPath, apiKey)` should:
  - Read all vegetable names from file
  - Create `Vegetable` object for each name
  - Return `List<Vegetable>`
  - Handle individual failures gracefully
  - Provide progress reporting
  - Respect rate limits

**GREEN - Implement Minimal Code:**
- **File:** `lib/services/vegetable_importer.dart`
- Create `VegetableImporter` class
- Implement `static Future<List<Vegetable>> importFromFile(String inputPath, String apiKey)`
- Logic:
  1. Use `VegetableFileReader.readNames(inputPath)`
  2. For each name, use `VegetableFactory.fromDutchName(name, apiKey)`
  3. Collect results into `List<Vegetable>`

**REFACTOR:**
- Add progress callback for UI/CLI feedback
- Implement error recovery (skip failed vegetables, log errors)
- Add rate limiting for DeepL Free tier
- Consider parallel processing with concurrency limits
- Add statistics (total processed, succeeded, failed)

**Run:**
```bash
/tdd-test test/services/vegetable_importer_test.dart
```

---

### Iteration 6: JSON Exporter

**Objective:** Export Vegetable objects to JSON file

**RED - Write Failing Test:**
- **File:** `test/services/vegetable_exporter_test.dart`
- **Test:** `VegetableExporter.toJsonFile(vegetables, outputPath)` should:
  - Write `List<Vegetable>` to JSON file
  - Use pretty-printing (indentation)
  - Validate output against `vegetable.schema.json`
  - Handle file write errors
  - Support both single and array of vegetables

**GREEN - Implement Minimal Code:**
- **File:** `lib/services/vegetable_exporter.dart`
- Create `VegetableExporter` class
- Implement `static Future<void> toJsonFile(List<Vegetable> vegetables, String outputPath)`
- Use `dart_mappable` serialization:
  ```dart
  final jsonList = vegetables.map((v) => v.toMap()).toList();
  final jsonString = JsonEncoder.withIndent('  ').convert(jsonList);
  await File(outputPath).writeAsString(jsonString);
  ```

**REFACTOR:**
- Add file overwrite confirmation
- Add backup option for existing files
- Validate all objects before writing
- Add metadata (export timestamp, count)

**Run:**
```bash
/tdd-test test/services/vegetable_exporter_test.dart
```

---

## Phase 3: CLI Integration

**Objective:** Add import command to CLI application

### 3.1 Update bin/vegetables_firestore.dart

Add import subcommand:
```bash
dart run bin/vegetables_firestore.dart import \
  --input vegetables.txt \
  --output imported_vegetables.json \
  --api-key YOUR_DEEPL_API_KEY
```

**Implementation:**
- Use `args` package to add new flags:
  - `--input` / `-i` (required): Path to input .txt file
  - `--output` / `-o` (required): Path to output JSON file
  - `--api-key` / `-k` (optional): DeepL API key
- If `--api-key` not provided, prompt interactively:
  ```dart
  stdout.write('Enter DeepL API key: ');
  final apiKey = stdin.readLineSync() ?? '';
  ```
- Call `VegetableImporter.importFromFile(inputPath, apiKey)`
- Call `VegetableExporter.toJsonFile(vegetables, outputPath)`
- Display progress and results

**Security:**
- API key only lives in process memory during execution
- Never write API key to files, environment variables, or logs
- Clear API key from memory after use (if possible)

---

## Phase 4: Integration Testing

**Objective:** End-to-end test of complete import workflow

### 4.1 Create Integration Test

**File:** `test/integration/vegetable_import_integration_test.dart`

**Setup:**
```dart
late String apiKey;

setUpAll(() {
  stdout.write('Enter DeepL API key for integration tests: ');
  apiKey = stdin.readLineSync() ?? '';

  if (apiKey.isEmpty) {
    fail('DeepL API key is required for integration tests');
  }
});

tearDownAll(() {
  // API key automatically discarded when test process exits
  apiKey = ''; // Clear from memory
});
```

**Tests:**

1. **Complete Import Workflow**
   - Given: A text file with 5 test vegetables
   - When: Import process runs
   - Then:
     - All 5 vegetables are created
     - JSON file is written
     - JSON validates against schema

2. **Verify Vegetable Properties**
   - Given: Imported vegetables
   - When: Inspecting each vegetable
   - Then:
     - `harvestState == HarvestState.notAvailable` for all
     - Complete translations exist (nl, en, fr, de)
     - Each translation has `name` field
     - Each translation has complete `harvestState` object (all 4 values)
     - Timestamps are valid (createdAt, updatedAt)

3. **Round-trip Serialization**
   - Given: Imported vegetables
   - When: Serialize to JSON → Deserialize back to objects
   - Then: Objects are identical to originals

4. **Schema Validation**
   - Given: Output JSON file
   - When: Validate against `schemas/vegetable.schema.json`
   - Then: All vegetables pass schema validation

**Run:**
```bash
/tdd-test test/integration/vegetable_import_integration_test.dart
```

---

## Phase 5: Test Helper Utilities

### 5.1 API Key Provider

**File:** `test/test_helpers/api_key_provider.dart`

```dart
import 'dart:io';

/// Provides DeepL API key for tests
/// Prompts user once per test session, caches in-memory
class ApiKeyProvider {
  static String? _cachedApiKey;

  /// Get API key (prompts if not already provided)
  static String getTestApiKey() {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      return _cachedApiKey!;
    }

    stdout.write('Enter DeepL API key for tests: ');
    _cachedApiKey = stdin.readLineSync();

    if (_cachedApiKey == null || _cachedApiKey!.isEmpty) {
      throw Exception('DeepL API key is required for tests');
    }

    return _cachedApiKey!;
  }

  /// Clear cached API key (called in tearDownAll)
  static void clearApiKey() {
    _cachedApiKey = null;
  }
}
```

**Usage in tests:**
```dart
import 'package:test_helpers/api_key_provider.dart';

void main() {
  late String apiKey;

  setUpAll(() {
    apiKey = ApiKeyProvider.getTestApiKey();
  });

  tearDownAll(() {
    ApiKeyProvider.clearApiKey();
  });

  test('translate vegetable name', () async {
    final result = await DeeplClient.translate('Tomaat', 'EN', apiKey);
    expect(result, 'Tomato');
  });
}
```

---

## Architecture Overview

### Directory Structure

```
lib/
├── models/
│   └── vegetable.dart (existing - no changes)
├── services/
│   ├── deepl_client.dart (NEW)
│   ├── harvest_state_translation_service.dart (NEW)
│   ├── vegetable_factory.dart (NEW)
│   ├── vegetable_file_reader.dart (NEW)
│   ├── vegetable_importer.dart (NEW)
│   └── vegetable_exporter.dart (NEW)

bin/
└── vegetables_firestore.dart (UPDATE - add import command)

test/
├── services/
│   ├── deepl_client_test.dart (NEW)
│   ├── harvest_state_translation_service_test.dart (NEW)
│   ├── vegetable_factory_test.dart (NEW)
│   ├── vegetable_file_reader_test.dart (NEW)
│   ├── vegetable_importer_test.dart (NEW)
│   └── vegetable_exporter_test.dart (NEW)
├── integration/
│   └── vegetable_import_integration_test.dart (NEW)
└── test_helpers/
    └── api_key_provider.dart (NEW)

.claude/tdd-tasks/
├── vegetable-import.md (TDD task spec - created via /tdd-new)
└── vegetable-import-plan.md (THIS FILE)
```

### Component Relationships

```
CLI (bin/vegetables_firestore.dart)
    ↓
VegetableImporter
    ↓
    ├─→ VegetableFileReader (reads input)
    ├─→ VegetableFactory (creates objects)
    │       ↓
    │       ├─→ DeeplClient (translates names)
    │       └─→ HarvestStateTranslationService (translates harvest states)
    │               ↓
    │               └─→ DeeplClient
    └─→ VegetableExporter (writes JSON)
```

---

## DeepL API Reference

### Free Tier Limits
- **Endpoint:** `https://api-free.deepl.com/v2/translate`
- **Authentication:** `Authorization: DeepL-Auth-Key YOUR_KEY`
- **Rate Limit:** 500,000 characters per month
- **Character Count:** Input text + target language code

### Character Usage Calculation

**Per vegetable:**
- Vegetable name: ~20 chars average
- Harvest states: 4 × ~20 chars = 80 chars
- **Total per vegetable:** ~100 chars × 3 target languages = 300 chars

**Examples:**
- 10 vegetables: ~3,000 chars
- 50 vegetables: ~15,000 chars
- 100 vegetables: ~30,000 chars

All well within the 500K monthly limit.

### Request/Response Format

**Request:**
```json
POST https://api-free.deepl.com/v2/translate
Headers:
  Authorization: DeepL-Auth-Key YOUR_KEY
  Content-Type: application/json

Body:
{
  "text": ["Tomaat", "Komkommer"],
  "source_lang": "NL",
  "target_lang": "EN"
}
```

**Response:**
```json
{
  "translations": [
    {
      "detected_source_language": "NL",
      "text": "Tomato"
    },
    {
      "detected_source_language": "NL",
      "text": "Cucumber"
    }
  ]
}
```

### Error Handling

**Common errors:**
- `403 Forbidden`: Invalid API key
- `429 Too Many Requests`: Rate limit exceeded
- `456 Quota Exceeded`: Monthly character limit reached
- `500 Internal Server Error`: DeepL service issue

**Retry strategy:**
- Transient errors (500, 503): Retry with exponential backoff
- Rate limiting (429): Wait and retry
- Permanent errors (403, 456): Fail fast with clear message

---

## API Key Security Strategy

### Principles
1. **Never persist:** No files, environment variables, or version control
2. **Prompt on demand:** Request from user when needed
3. **Memory only:** Store only in process memory during execution
4. **Immediate disposal:** Clear from memory after use

### Implementation

**In Tests:**
```dart
// Prompt once per test session
setUpAll(() {
  apiKey = stdin.readLineSync();
});

// Clear after tests complete
tearDownAll(() {
  apiKey = '';
});
```

**In CLI:**
```dart
void main(List<String> arguments) {
  String? apiKey = argResults['api-key'];

  // If not provided via flag, prompt interactively
  if (apiKey == null || apiKey.isEmpty) {
    stdout.write('Enter DeepL API key: ');
    apiKey = stdin.readLineSync();
  }

  // Use API key for import
  await VegetableImporter.importFromFile(inputPath, apiKey);

  // Clear from memory (optional, process will exit anyway)
  apiKey = '';
}
```

**What NOT to do:**
- ❌ Store in `.env` file
- ❌ Add to `pubspec.yaml`
- ❌ Save in configuration files
- ❌ Commit to version control
- ❌ Write to logs
- ❌ Cache on filesystem

---

## Testing Strategy

### Test Levels

1. **Unit Tests** (test/services/)
   - Test each service in isolation
   - Mock dependencies where appropriate
   - Fast execution
   - No external API calls (except DeepL tests with user-provided key)

2. **Integration Tests** (test/integration/)
   - Test complete workflow end-to-end
   - Real API calls to DeepL (requires API key)
   - Verify all components work together
   - Test file I/O, serialization, validation

### Test Data

**Sample input file** (test/fixtures/sample_vegetables.txt):
```
Tomaat
Komkommer
Wortel
Sla
Paprika
```

**Expected output structure:**
```json
[
  {
    "name": "Tomaat",
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z",
    "harvestState": "notAvailable",
    "translations": {
      "nl": {
        "name": "Tomaat",
        "harvestState": {
          "scarce": "Schaars",
          "enough": "Voldoende",
          "plenty": "Overvloed",
          "notAvailable": "Niet beschikbaar"
        }
      },
      "en": {
        "name": "Tomato",
        "harvestState": {
          "scarce": "Scarce",
          "enough": "Enough",
          "plenty": "Plenty",
          "notAvailable": "Not Available"
        }
      },
      "fr": { ... },
      "de": { ... }
    }
  },
  ...
]
```

---

## TDD Workflow Commands

### Create TDD Task
```bash
/tdd-new vegetable-import
```

### Implement Feature (Red-Green-Refactor)
```bash
/tdd-implement .claude/tdd-tasks/vegetable-import.md
```

### Run Specific Tests
```bash
/tdd-test test/services/deepl_client_test.dart
```

### Run All Tests
```bash
dart test
```

### Code Generation (after model changes)
```bash
dart run build_runner build
```

### Analyze Code
```bash
dart analyze
```

---

## Success Criteria

### Functional Requirements
- ✅ Read vegetable names from text file (one per line)
- ✅ Translate names to NL, EN, FR, DE using DeepL API
- ✅ Translate harvest state labels to all languages
- ✅ Create Vegetable objects with `harvestState: notAvailable`
- ✅ Set valid timestamps (createdAt, updatedAt)
- ✅ Export to JSON file with proper formatting
- ✅ JSON validates against existing schema

### Quality Requirements
- ✅ 100% test coverage for new code
- ✅ All tests pass (unit + integration)
- ✅ No linting errors (`dart analyze`)
- ✅ Follows existing code patterns
- ✅ Comprehensive error handling
- ✅ Clear CLI error messages

### Security Requirements
- ✅ API key never persisted to disk
- ✅ API key prompted from user when needed
- ✅ API key discarded after use
- ✅ No API key in version control
- ✅ No API key in logs or output

### Performance Requirements
- ✅ Efficient API usage (batch translations)
- ✅ Rate limiting respected
- ✅ Progress reporting for large imports
- ✅ Graceful handling of individual failures

---

## Next Steps

1. **Start TDD Implementation:** Run `/tdd-new vegetable-import` to create task specification
2. **Follow Red-Green-Refactor:** Implement each iteration sequentially
3. **Test Frequently:** Run `/tdd-test` after each code change
4. **Regenerate Mappers:** Run `dart run build_runner build` after any model changes
5. **Validate:** Run `dart analyze` to ensure code quality

---

## Notes

- This plan follows the project's TDD methodology as documented in CLAUDE.md
- All new code will use existing patterns (dart_mappable, lints, test helpers)
- The plan is designed for implementation in Claude Code Web
- API key security is prioritized throughout the implementation
- DeepL Free tier limits are well-suited for this use case

---

**Document Version:** 1.0
**Created:** 2025-11-16
**Status:** Ready for Implementation
