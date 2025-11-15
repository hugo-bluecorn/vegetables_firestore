# TDD Task: Vegetable Name Validator

**Status:** Not Started
**Created:** 2025-11-15
**Last Updated:** 2025-11-15

---

## Feature Description

Create a validator function that checks if a given string is a valid vegetable name. The validator should verify that the name is not empty, contains only letters and spaces, and has a reasonable length.

---

## Test Specifications

### Test 1: Valid vegetable names should pass validation
**Description:** The validator should return true for common vegetable names

**Given:**
- Valid vegetable names like "Carrot", "Sweet Potato", "Bell Pepper"

**When:**
- The validator function is called with a valid vegetable name

**Then:**
- The function should return true
- No exceptions should be thrown

**Test Code Location:** `test/vegetable_validator_test.dart`

---

### Test 2: Empty or null names should fail validation
**Description:** The validator should reject empty strings and null values

**Given:**
- Empty string ""
- Null value

**When:**
- The validator function is called with empty or null input

**Then:**
- The function should return false
- Should handle null gracefully without throwing exceptions

**Test Code Location:** `test/vegetable_validator_test.dart`

---

### Test 3: Names with invalid characters should fail validation
**Description:** The validator should reject names containing numbers or special characters

**Given:**
- Names with numbers like "Carrot123", "2Tomatoes"
- Names with special characters like "Carrot!", "Bell@Pepper", "Kale#"

**When:**
- The validator function is called with invalid names

**Then:**
- The function should return false

**Test Code Location:** `test/vegetable_validator_test.dart`

---

### Test 4: Names exceeding length limits should fail validation
**Description:** The validator should reject names that are too long

**Given:**
- A string longer than 50 characters

**When:**
- The validator function is called with an overly long name

**Then:**
- The function should return false

**Test Code Location:** `test/vegetable_validator_test.dart`

---

### Test 5: Names with only spaces should fail validation
**Description:** The validator should reject strings containing only whitespace

**Given:**
- Strings like "   ", "  \t  "

**When:**
- The validator function is called with whitespace-only input

**Then:**
- The function should return false

**Test Code Location:** `test/vegetable_validator_test.dart`

---

## Implementation Requirements

### File Location
- **Source:** `lib/vegetable_validator.dart`
- **Tests:** `test/vegetable_validator_test.dart`

### Function Signatures
```dart
/// Validates a vegetable name
///
/// Returns true if the name is valid, false otherwise.
/// A valid vegetable name:
/// - Is not null or empty
/// - Contains only letters and spaces
/// - Is between 1 and 50 characters
/// - Is not just whitespace
bool isValidVegetableName(String? name);
```

### Dependencies
- [x] Dart test package (already in pubspec.yaml)

### Edge Cases to Handle
- [x] Null input
- [x] Empty string
- [x] Whitespace-only strings
- [x] Numbers in name
- [x] Special characters
- [x] Names exceeding max length
- [x] Leading/trailing spaces (should trim first)

---

## Acceptance Criteria

- [ ] All tests pass
- [ ] Code follows Dart style guidelines (analysis_options.yaml)
- [ ] No linting errors
- [ ] Edge cases are handled
- [ ] Documentation is complete
- [ ] Function has proper null safety

---

## Implementation Notes

This is an example TDD task to demonstrate the workflow. Use `/tdd-implement .claude/tdd-tasks/example-vegetable-validator.md` to implement this feature following TDD principles.

The implementation should:
1. Create the test file first with all test cases
2. Run tests (they should fail - RED)
3. Implement the validator function
4. Run tests (they should pass - GREEN)
5. Refactor if needed while keeping tests green

---

## Test Results

### Iteration 1
- **Date:** [Not yet run]
- **Tests Passed:** 0/5
- **Notes:** [Awaiting implementation]
