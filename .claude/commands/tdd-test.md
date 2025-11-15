---
description: Run tests for a specific TDD task
---

You are running tests for a TDD (Test-Driven Development) task in a Dart project.

## Instructions

1. **Get the test file path** from the user (or read from TDD markdown file if provided)
2. **Run the tests** using Dart test framework:
   - Execute: `dart test [test_file_path]`
   - If no path provided, run all tests: `dart test`
3. **Display test results** clearly:
   - Number of tests passed
   - Number of tests failed
   - Any error messages or stack traces
4. **Run analysis** to check for linting issues:
   - Execute: `dart analyze [file_path]`
5. **Provide summary** with:
   - Test status (all passing, some failing, etc.)
   - Linting status
   - Next steps if tests are failing

## Usage Examples

**Example 1:** Test a specific file
```
/tdd-test test/vegetable_validator_test.dart
```

**Example 2:** Test from TDD markdown file
```
/tdd-test .claude/tdd-tasks/add-vegetable-validator.md
```
(Will read the test file path from the TDD markdown)

**Example 3:** Run all tests
```
/tdd-test
```

## Output Format

Provide clear, formatted output:
- ✅ Tests passing
- ❌ Tests failing (with details)
- 🔍 Linting issues (if any)
- 📝 Recommendations for next steps

## Important Notes

- Always show the full test output for debugging
- Highlight any failures clearly
- Suggest fixes for common test failures
- Check both test results AND linting
