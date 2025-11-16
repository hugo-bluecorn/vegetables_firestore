# Vegetables Firestore

A Dart application providing a multilingual vegetable data model with comprehensive internationalization (i18n) support. Built with type-safe JSON serialization and a test-driven development (TDD) approach.

## Features

- **Multilingual Support**: Dutch (NL), English (EN), French (FR), and German (DE) translations
- **Vegetable Data Model**: Complete model with harvest states, timestamps, and localization
- **Type-Safe Serialization**: Using `dart_mappable` for JSON serialization/deserialization
- **JSON Schema Validation**: Ensures data integrity and structure
- **Comprehensive Testing**: Full test coverage with TDD methodology (144 tests)
- **CLI Import Tool**: Translate Dutch vegetable names to multiple languages via DeepL API
- **Batch Import**: Import and translate vegetables from text files with progress reporting
- **JSON Export**: Export multilingual vegetable data to formatted JSON

**Default Language**: Dutch (NL)

## Installation

### Prerequisites

- Dart SDK ^3.10.0

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd vegetables_firestore

# Install dependencies
dart pub get

# Generate mappable code
dart run build_runner build
```

## Usage

### Command Line Interface

```bash
# Show help
dart run bin/vegetables_firestore.dart --help

# Show version
dart run bin/vegetables_firestore.dart --version
```

### Import Vegetables with DeepL Translation

Import Dutch vegetable names from a text file and automatically translate them to NL, EN, FR, and DE:

```bash
# Import with API key provided
dart run bin/vegetables_firestore.dart import \
  --input vegetables.txt \
  --output vegetables.json \
  --api-key YOUR_DEEPL_API_KEY

# Import with interactive API key prompt (more secure - key not stored in shell history)
dart run bin/vegetables_firestore.dart import \
  --input vegetables.txt \
  --output vegetables.json

# Using short flags
dart run bin/vegetables_firestore.dart import -i input.txt -o output.json -k API_KEY
```

**Input File Format** (`vegetables.txt`):
```
Tomaat
Komkommer
Wortel
Paprika
```

**Output** (`vegetables.json`):
```json
[
  {
    "name": "Tomaat",
    "createdAt": "2025-11-16T10:30:00.000Z",
    "updatedAt": "2025-11-16T10:30:00.000Z",
    "harvestState": "notAvailable",
    "translations": {
      "nl": {
        "name": "Tomaat",
        "harvestState": {
          "scarce": "Schaars",
          "enough": "Genoeg",
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
  }
]
```

**Features:**
- Translates vegetable names using DeepL API
- Includes harvest state translations for all 4 languages
- Sets `harvestState: notAvailable` by default
- Progress reporting during import
- Handles errors gracefully with detailed reporting
- Rate limiting and retry logic for API requests
- Secure API key handling (prompts if not provided)

### Using the Vegetable Model

```dart
import 'package:vegetables_firestore/models/vegetable.dart';

// Create a vegetable from JSON
final vegetable = Vegetable.fromJson(jsonString);

// Get localized name
print(vegetable.getLocalizedName('en')); // English name
print(vegetable.getLocalizedName('nl')); // Dutch name
print(vegetable.getLocalizedName('fr')); // French name
print(vegetable.getLocalizedName('de')); // German name

// Get localized harvest state
print(vegetable.getLocalizedHarvestState('en')); // "Scarce", "Enough", "Plenty", or "Not Available"

// Convert to JSON
final json = vegetable.toJson();
```

### Validating Vegetable Names

```dart
import 'package:vegetables_firestore/vegetable_validator.dart';

bool isValid = isValidVegetableName('Tomato'); // true
bool isInvalid = isValidVegetableName('123'); // false
```

## Data Model

### Vegetable

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Primary name (Dutch) |
| `createdAt` | `DateTime` | ISO 8601 timestamp |
| `updatedAt` | `DateTime` | ISO 8601 timestamp |
| `harvestState` | `HarvestState` | Current harvest availability |
| `translations` | `VegetableTranslations` | Multi-language translations |

### HarvestState Enum

- `scarce`: Limited availability
- `enough`: Adequate availability
- `plenty`: Abundant availability
- `notAvailable`: Currently not available

### Supported Languages

- **NL** (Dutch) - Default/Primary
- **EN** (English)
- **FR** (French)
- **DE** (German)

## Development

### Test-Driven Development Workflow

This project follows Test-Driven Development (TDD) with structured slash commands:

```bash
# Create new TDD task specification
/tdd-new [feature-name]

# Implement TDD task (follows Red-Green-Refactor cycle)
/tdd-implement .claude/tdd-tasks/[task-name].md

# Run tests for TDD task
/tdd-test [test-file-path]
```

**TDD Process:**
1. Create task specification with `/tdd-new`
2. Define test specifications using Given-When-Then format
3. Implement with `/tdd-implement` following:
   - **RED**: Write tests first (they will fail)
   - **GREEN**: Implement minimal code to pass tests
   - **REFACTOR**: Improve code while keeping tests green
4. Verify with `/tdd-test`

### Running Tests

```bash
# Run all tests
dart test

# Run specific test file
dart test test/models/vegetable_test.dart
```

### Code Generation

When making changes to models with `@MappableClass()` annotations:

```bash
# One-time build
dart run build_runner build

# Watch mode (auto-rebuild)
dart run build_runner watch

# Clean and rebuild
dart run build_runner build --delete-conflicting-outputs
```

### Code Quality

```bash
# Analyze code
dart analyze

# Format code
dart format .

# Fix formatting issues
dart format . --fix
```

## Project Structure

```
vegetables_firestore/
├── bin/
│   └── vegetables_firestore.dart    # CLI entry point with import command
├── lib/
│   ├── models/
│   │   ├── vegetable.dart           # Vegetable data model
│   │   └── vegetable.mapper.dart    # Generated mappable code
│   ├── services/
│   │   ├── vegetable_file_reader.dart     # Text file reader
│   │   ├── deepl_client.dart              # DeepL API client
│   │   ├── harvest_state_translation_service.dart  # Harvest state translations
│   │   ├── vegetable_factory.dart         # Vegetable object factory
│   │   ├── vegetable_importer.dart        # Batch import service
│   │   └── vegetable_exporter.dart        # JSON export service
│   └── vegetable_validator.dart     # Validation utilities
├── test/
│   ├── models/
│   │   └── vegetable_test.dart      # Model tests
│   ├── services/                    # Service layer tests (53 tests)
│   │   ├── vegetable_file_reader_test.dart
│   │   ├── deepl_client_test.dart
│   │   ├── harvest_state_translation_service_test.dart
│   │   ├── vegetable_factory_test.dart
│   │   ├── vegetable_importer_test.dart
│   │   └── vegetable_exporter_test.dart
│   ├── schemas/
│   │   └── vegetable_schema_test.dart # Schema validation tests
│   └── vegetable_validator_test.dart # Validator tests
├── data/
│   ├── vegetables_complete.json     # Complete vegetable data
│   ├── vegetable_translations.json  # Translation data
│   └── vegetable_translations.csv   # CSV translations
├── .claude/
│   ├── tdd-tasks/                   # TDD task specifications
│   └── commands/                    # TDD workflow commands
└── pubspec.yaml                     # Dependencies
```

## Dependencies

### Production
- `args` ^2.7.0 - Command-line argument parsing
- `dart_mappable` ^4.2.2 - Type-safe JSON serialization
- `http` ^1.2.0 - HTTP client for DeepL API integration

### Development
- `test` ^1.25.6 - Testing framework
- `lints` ^6.0.0 - Static analysis
- `dart_mappable_builder` ^4.2.3 - Code generation
- `build_runner` ^2.4.13 - Build system
- `json_schema` ^5.1.3 - JSON Schema validation

### API Requirements

To use the import feature, you need a **DeepL API key**:
1. Sign up for a free DeepL API account at https://www.deepl.com/pro-api
2. Get your API key from the account dashboard
3. Free tier includes 500,000 characters/month
4. API key format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:fx`

## Validation Rules

### Vegetable Name Validation

The `isValidVegetableName()` function validates names with these rules:

- Not null or empty
- Only letters (a-z, A-Z) and spaces
- Between 1 and 50 characters (after trimming)
- Not just whitespace

**Examples:**
- Valid: `"Tomato"`, `"Sweet Potato"`, `"Bell Pepper"`
- Invalid: `"Tomato123"`, `"Tom@to"`, `""`, `"   "`

## Contributing

This project follows a Test-Driven Development (TDD) approach with structured workflows:

### Quick Start for Contributors

1. **Create a new feature task**: `/tdd-new [feature-name]`
2. **Define test specifications** in the generated `.claude/tdd-tasks/[feature-name].md`
3. **Implement the feature**: `/tdd-implement .claude/tdd-tasks/[feature-name].md`
4. **Verify tests pass**: `/tdd-test [test-file-path]`

### TDD Best Practices

- Write tests before implementation (Red-Green-Refactor)
- Keep iterations small and focused
- Run tests frequently after each change
- Always regenerate mapper code after model changes (`dart run build_runner build`)
- Document decisions in TDD task files
- Ensure code analysis passes (`dart analyze`)

See `CLAUDE.md` for complete development guidelines.

## License

[Specify your license here]

## Version

Current version: 0.0.1
