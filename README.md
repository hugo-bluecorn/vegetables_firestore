# Vegetables Firestore

A Dart application providing a multilingual vegetable data model with comprehensive internationalization (i18n) support. Built with type-safe JSON serialization and a test-driven development (TDD) approach.

## Features

- **Multilingual Support**: Dutch (NL), English (EN), French (FR), and German (DE) translations
- **Vegetable Data Model**: Complete model with harvest states, timestamps, and localization
- **Type-Safe Serialization**: Using `dart_mappable` for JSON serialization/deserialization
- **JSON Schema Validation**: Ensures data integrity and structure
- **Comprehensive Testing**: Full test coverage with TDD methodology
- **CLI Interface**: Command-line interface with argument parsing

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
# Run the application
dart run bin/vegetables_firestore.dart

# Show help
dart run bin/vegetables_firestore.dart --help

# Show version
dart run bin/vegetables_firestore.dart --version

# Verbose output
dart run bin/vegetables_firestore.dart --verbose
```

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
print(vegetable.getLocalizedHarvestState('en')); // "Scarce", "Enough", or "Plenty"

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

### Supported Languages

- **NL** (Dutch) - Default/Primary
- **EN** (English)
- **FR** (French)
- **DE** (German)

## Development

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
│   └── vegetables_firestore.dart    # CLI entry point
├── lib/
│   ├── models/
│   │   ├── vegetable.dart           # Vegetable data model
│   │   └── vegetable.mapper.dart    # Generated mappable code
│   └── vegetable_validator.dart     # Validation utilities
├── test/
│   ├── models/
│   │   └── vegetable_test.dart      # Model tests
│   ├── schemas/
│   │   └── vegetable_schema_test.dart # Schema validation tests
│   └── vegetable_validator_test.dart # Validator tests
├── data/
│   ├── vegetables_complete.json     # Complete vegetable data
│   ├── vegetable_translations.json  # Translation data
│   └── vegetable_translations.csv   # CSV translations
└── pubspec.yaml                     # Dependencies
```

## Dependencies

### Production
- `args` ^2.7.0 - Command-line argument parsing
- `dart_mappable` ^4.2.2 - Type-safe JSON serialization

### Development
- `test` ^1.25.6 - Testing framework
- `lints` ^6.0.0 - Static analysis
- `dart_mappable_builder` ^4.2.3 - Code generation
- `build_runner` ^2.4.13 - Build system
- `json_schema` ^5.1.3 - JSON Schema validation

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

This project follows a Test-Driven Development (TDD) approach:

1. Write tests first
2. Implement functionality
3. Refactor as needed
4. Run full test suite
5. Ensure code analysis passes

## License

[Specify your license here]

## Version

Current version: 0.0.1
