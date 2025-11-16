# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dart application (`vegetables_firestore`) using Dart SDK ^3.10.0 that provides a multilingual vegetable data model with internationalization support and Cloud Firestore integration. The project includes:

- **Vegetable data model** with harvest states and timestamps
- **Multilingual support** for Dutch (NL), English (EN), French (FR), and German (DE)
- **JSON Schema validation**
- **Type-safe serialization** using `dart_mappable`
- **Comprehensive test suite** with TDD approach (144 tests)
- **CLI interface** with import command for DeepL translation
- **Import service** for translating Dutch vegetable names to multiple languages
- **Cloud Firestore integration** for persistent storage using Firebase Admin SDK
- **Batch operations** with duplicate detection for efficient data management

Default language: **Dutch (NL)**

## Commands

### Run the application
```bash
dart run bin/vegetables_firestore.dart [arguments]
```

### Import vegetables from text file
```bash
# Import Dutch vegetable names and translate to NL, EN, FR, DE
dart run bin/vegetables_firestore.dart import \
  --input vegetables.txt \
  --output vegetables.json \
  --api-key YOUR_DEEPL_API_KEY

# Will prompt for API key if not provided
dart run bin/vegetables_firestore.dart import -i vegetables.txt -o vegetables.json

# Import and upload to Firestore (only adds new vegetables)
dart run bin/vegetables_firestore.dart import \
  --input vegetables.txt \
  --output vegetables.json \
  --api-key YOUR_DEEPL_API_KEY \
  --upload-to-firestore \
  --firebase-project-id YOUR_PROJECT_ID

# Will prompt for service account credentials if not provided
```

### Install dependencies
```bash
dart pub get
```

### Run tests
```bash
dart test
```

### Generate code (for dart_mappable)
```bash
dart run build_runner build
```

### Watch mode for code generation
```bash
dart run build_runner watch
```

### Analyze code
```bash
dart analyze
```

### Format code
```bash
dart format .
```

### TDD Workflow Commands
```bash
# Create new TDD task specification
/tdd-new [feature-name]

# Implement TDD task (follows Red-Green-Refactor cycle)
/tdd-implement .claude/tdd-tasks/[task-name].md

# Run tests for TDD task
/tdd-test [test-file-path]
```

## Architecture

### Directory Structure

- **`bin/vegetables_firestore.dart`**: CLI entry point with argument parsing (args package)
  - Supports `--help` / `-h`, `--verbose` / `-v`, and `--version` flags
  - Supports `import` command for translating vegetables via DeepL API

- **`lib/models/`**: Data models
  - `vegetable.dart`: Vegetable model with i18n support
  - `vegetable.mapper.dart`: Auto-generated mappable code

- **`lib/services/`**: Business logic services
  - `vegetable_file_reader.dart`: Reads vegetable names from text files
  - `deepl_client.dart`: DeepL API client with retry logic and rate limiting
  - `harvest_state_translation_service.dart`: Translates harvest state labels
  - `vegetable_factory.dart`: Creates multilingual Vegetable objects
  - `vegetable_importer.dart`: Batch import with progress reporting
  - `vegetable_exporter.dart`: Exports vegetables to JSON
  - `firestore_service.dart`: Cloud Firestore integration with Admin SDK
  - `vegetable_repository.dart`: Repository pattern for Firestore CRUD operations

- **`lib/vegetable_validator.dart`**: Validation utilities
  - `isValidVegetableName()`: Validates vegetable names (letters/spaces, 1-50 chars)

- **`test/`**: Comprehensive test suite (144 tests)
  - `models/vegetable_test.dart`: Model serialization/deserialization tests
  - `vegetable_validator_test.dart`: Validator logic tests
  - `schemas/vegetable_schema_test.dart`: JSON Schema validation tests
  - `services/`: Service layer tests (53 tests across 6 services)

- **`data/`**: Vegetable data files
  - `vegetables_complete.json`: Complete vegetable data with translations
  - `vegetable_translations.json`: Translation data structure
  - `vegetable_translations.csv`: CSV format translations

- **`.claude/tdd-tasks/`**: TDD task specifications
  - Task files follow Given-When-Then format
  - Track implementation status and test results
  - Use with `/tdd-implement` slash command

### Key Models

#### Vegetable
- `name`: Primary name (Dutch)
- `createdAt`: ISO 8601 timestamp
- `updatedAt`: ISO 8601 timestamp
- `harvestState`: Enum (scarce, enough, plenty, notAvailable)
- `translations`: Multi-language support (NL, EN, FR, DE)

Methods:
- `getLocalizedName(languageCode)`: Returns name in specified language
- `getLocalizedHarvestState(languageCode)`: Returns harvest state in specified language

#### HarvestState Enum
- `scarce`: Limited availability
- `enough`: Adequate availability
- `plenty`: Abundant availability
- `notAvailable`: Currently not available

## Dependencies

- **args**: Command-line argument parsing
- **dart_mappable**: Type-safe JSON serialization/deserialization
- **http**: HTTP client for DeepL API integration
- **dart_firebase_admin**: Firebase Admin SDK for Firestore integration
- **build_runner**: Code generation
- **json_schema**: JSON Schema validation
- **test**: Testing framework
- **lints**: Static analysis

## Development Workflow

### Standard Workflow
1. Make model changes in `lib/models/vegetable.dart`
2. Run code generation: `dart run build_runner build`
3. Write tests in `test/`
4. Run tests: `dart test`
5. Validate code: `dart analyze`

### TDD Workflow (Recommended)
This project follows Test-Driven Development with a structured approach:

1. **Create TDD Task:** `/tdd-new [feature-name]`
   - Generates task specification in `.claude/tdd-tasks/`
   - Define test specifications using Given-When-Then format

2. **Implement Feature:** `/tdd-implement .claude/tdd-tasks/[task-name].md`
   - Follows Red-Green-Refactor cycle:
     - **RED:** Write tests first (they will fail)
     - **GREEN:** Implement minimal code to pass tests
     - **REFACTOR:** Improve code while keeping tests green
   - Automatically runs `dart test`, `dart analyze`, and `dart run build_runner build`
   - Updates task status and results

3. **Verify Tests:** `/tdd-test [test-file-path]`
   - Run specific test file or all tests
   - Check linting and code quality

**TDD Best Practices:**
- Write tests before implementation
- Keep iterations small and focused
- Run tests frequently after each change
- Always regenerate mapper code after model changes
- Document decisions in TDD task files

## Firestore Integration

### Overview
The project uses **dart_firebase_admin** (Firebase Admin SDK) for Cloud Firestore integration, providing:
- Advanced query capabilities (filtering by harvestState, etc.)
- Batch operations with transaction support
- Duplicate detection to prevent redundant data
- Admin-level access (bypasses security rules during development)

### Testing Approaches

#### Option A: Direct Firestore Testing (Claude Code Web Compatible)
For development and testing in Claude Code Web:
- Use a **separate test collection** (`vegetables_test`) or test Firebase project
- Service account credentials prompted during test runs (never saved)
- Cleanup strategy: Delete test documents after each test
- Pros: Can test immediately without local setup
- Cons: Uses real Firestore database, requires active internet connection

**Setup:**
1. Create a separate Firebase test project or use test collection
2. Generate service account JSON from Firebase Console
3. Run tests with service account credentials prompted

#### Option B: Local Emulator Testing (Recommended for Production)
For comprehensive local testing:
- Use Firebase Local Emulator Suite
- No internet connection required
- Free, unlimited operations
- Realistic testing environment

**Setup Instructions (User Performs Locally):**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project directory
cd /path/to/vegetables_firestore
firebase init emulators
# Select: Firestore, Authentication
# Use default ports: Firestore (8080), Auth (9099)

# Start emulators
firebase emulators:start

# In another terminal, run tests with emulator environment variables
export FIRESTORE_EMULATOR_HOST="localhost:8080"
export FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"
dart test
```

**Emulator Benefits:**
- Free unlimited operations
- Fast local testing
- Isolated from production data
- Can reset state easily

### Firestore Architecture

**Collection Structure:**
- **Collection:** `vegetables`
- **Document ID:** Auto-generated or vegetable name (lowercase)
- **Document Fields:** Complete Vegetable model (name, createdAt, updatedAt, harvestState, translations)

**Service Layer Pattern:**
```
CLI → VegetableImporter → VegetableFactory → DeepL Translation
                             ↓
                     VegetableRepository → FirestoreService → Cloud Firestore
```

**Key Features:**
- **Duplicate Detection:** Query by name before inserting
- **Batch Upload:** Efficient bulk operations using Firestore batch writes
- **Query Support:** Filter vegetables by harvestState, language, etc.
- **Type Safety:** dart_mappable serialization works seamlessly with Firestore

### Security Considerations

**Service Account Credentials:**
- **Prompted during execution** (CLI flag or interactive prompt)
- **Never saved to disk** (same pattern as DeepL API key)
- **Not committed to version control** (service-account.json in .gitignore)
- **Environment variables** supported for CI/CD pipelines

**Firestore Security Rules (when using client SDK):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /vegetables/{vegetableId} {
      allow read: if true; // Public read access
      allow create, update: if request.auth != null; // Authenticated write
      allow delete: if false; // Prevent accidental deletion
    }
  }
}
```

**Note:** Admin SDK bypasses security rules, so implement validation in application code.

## Linting

Uses `package:lints/recommended.yaml` for static analysis via `analysis_options.yaml`.
- Always run 'dart pub upgrade --major-versions' when updating pubspec.yaml