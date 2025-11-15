# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dart application (`vegetables_firestore`) using Dart SDK ^3.10.0 that provides a multilingual vegetable data model with internationalization support. The project includes:

- **Vegetable data model** with harvest states and timestamps
- **Multilingual support** for Dutch (NL), English (EN), French (FR), and German (DE)
- **JSON Schema validation**
- **Type-safe serialization** using `dart_mappable`
- **Comprehensive test suite** with TDD approach
- **CLI interface** with basic argument parsing

Default language: **Dutch (NL)**

## Commands

### Run the application
```bash
dart run bin/vegetables_firestore.dart [arguments]
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

- **`lib/models/`**: Data models
  - `vegetable.dart`: Vegetable model with i18n support
  - `vegetable.mapper.dart`: Auto-generated mappable code

- **`lib/vegetable_validator.dart`**: Validation utilities
  - `isValidVegetableName()`: Validates vegetable names (letters/spaces, 1-50 chars)

- **`test/`**: Comprehensive test suite
  - `models/vegetable_test.dart`: Model serialization/deserialization tests
  - `vegetable_validator_test.dart`: Validator logic tests
  - `schemas/vegetable_schema_test.dart`: JSON Schema validation tests

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

## Linting

Uses `package:lints/recommended.yaml` for static analysis via `analysis_options.yaml`.
- Always run 'dart pub upgrade --major-versions' when updating pubspec.yaml