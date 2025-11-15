# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Multilingual vegetable data model with i18n support
- Support for Dutch (NL), English (EN), French (FR), and German (DE) languages
- `Vegetable` model with harvest states and timestamps
- `HarvestState` enum (scarce, enough, plenty)
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
