# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Vegetable import feature with DeepL translation** (2025-11-16)
  - Complete CLI import tool to translate Dutch vegetable names to NL, EN, FR, DE
  - 6 new service components with 53 comprehensive tests (144 total tests)
  - `VegetableFileReader`: Reads vegetable names from text files
  - `DeeplClient`: DeepL API integration with retry logic and rate limiting
  - `HarvestStateTranslationService`: Translates harvest state labels with caching
  - `VegetableFactory`: Creates multilingual Vegetable objects
  - `VegetableImporter`: Batch import with progress reporting and error handling
  - `VegetableExporter`: Exports vegetables to formatted JSON
  - CLI `import` command: `dart run bin/vegetables_firestore.dart import -i input.txt -o output.json`
  - Secure API key handling (prompts user, never persists to disk)
  - Progress reporting during import operations
  - Graceful error handling with detailed reporting
  - Rate limiting and exponential backoff for API requests
  - Added `http` ^1.2.0 dependency for API integration
- **TDD workflow documentation**: Comprehensive documentation added to CLAUDE.md and README.md (2025-11-15)
  - Documented `/tdd-new`, `/tdd-implement`, and `/tdd-test` slash commands
  - Added TDD best practices and workflow guidelines
  - Included Red-Green-Refactor cycle documentation
  - Updated project structure to include `.claude/tdd-tasks/` directory
- **`notAvailable` harvest state**: New harvest state to represent vegetables that are currently not available (2025-11-15)
  - Added to `HarvestState` enum with translations in all 4 languages
  - English: "Not Available", Dutch: "Niet beschikbaar", French: "Non disponible", German: "Nicht verfügbar"
  - Updated JSON schema to include `notAvailable` in enum values
  - Added comprehensive TDD test coverage (9 new tests)
  - Updated `getLocalizedHarvestState()` method to handle new state
- Multilingual vegetable data model with i18n support
- Support for Dutch (NL), English (EN), French (FR), and German (DE) languages
- `Vegetable` model with harvest states and timestamps
- `HarvestState` enum (scarce, enough, plenty, notAvailable)
- `VegetableTranslations` model for multi-language support
- `isValidVegetableName()` validation function
- Type-safe JSON serialization using `dart_mappable`
- Comprehensive test suite with TDD approach
- JSON Schema validation for vegetable data
- Vegetable translation data files (JSON and CSV formats)
- Helper methods: `getLocalizedName()` and `getLocalizedHarvestState()`
- TDD workflow with slash commands (`/tdd-new`, `/tdd-implement`, `/tdd-test`)

### Changed
- Default language changed from English to Dutch (NL)
- Primary `name` field now uses Dutch names
- Translation helper functions updated to use correct English names
- Test assertions updated to expect Dutch names as primary
- Vegetables data file updated to use Dutch as primary language

### Development
- Implemented using Test-Driven Development (TDD) methodology
- Added `build_runner` for code generation
- Added `json_schema` package for validation
- Set up comprehensive testing infrastructure

## [0.0.1] - Initial Release

### Added
- Basic CLI application structure
- Command-line argument parsing with `args` package
- Support for `--help`, `--verbose`, and `--version` flags
- Initial project scaffolding with Dart SDK ^3.10.0
- Linting configuration with `package:lints`
