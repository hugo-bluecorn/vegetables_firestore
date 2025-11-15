---
description: Implement a TDD task from a markdown specification file
---

You are implementing a feature using Test-Driven Development (TDD) for a Dart project.

## Instructions

1. **Read the TDD specification file** provided by the user (path will be given as argument or ask for it)
2. **Analyze the test specifications** and understand all requirements
3. **Create the test file** first based on the specifications:
   - Create test file at the location specified in the TDD file
   - Implement all test cases following the Given-When-Then format
   - Ensure tests are comprehensive and cover all edge cases
   - Use Dart test framework (`package:test`)
4. **Run the tests** to confirm they fail (Red phase)
   - Execute: `dart test [test_file_path]`
   - Document which tests fail and why
5. **Implement the minimum code** to make tests pass:
   - Create source file at specified location
   - Implement functionality incrementally
   - Focus on making tests pass, not over-engineering
6. **Run tests again** to verify they pass (Green phase)
   - Execute: `dart test [test_file_path]`
   - All tests must pass
7. **Run linting** to ensure code quality:
   - Execute: `dart analyze`
   - Fix any linting errors
8. **Refactor if needed** (Refactor phase):
   - Improve code structure while keeping tests green
   - Run tests after each refactor
9. **Update the TDD markdown file**:
   - Update status to "Completed"
   - Add test results
   - Document any implementation decisions
10. **Report completion** with summary:
    - Number of tests created
    - Number of tests passing
    - Files created/modified
    - Any issues encountered

## TDD Workflow

Follow the Red-Green-Refactor cycle:
- **RED:** Write tests that fail
- **GREEN:** Write minimal code to pass tests
- **REFACTOR:** Improve code while keeping tests green

## Important Notes

- Always write tests BEFORE implementation
- Run tests frequently (after every small change)
- Keep iterations small and focused
- Document all decisions in the TDD markdown file
- Ensure all acceptance criteria are met
- Follow Dart best practices and style guidelines

## Usage Example

User: `/tdd-implement .claude/tdd-tasks/add-vegetable-validator.md`

You will then:
1. Read the TDD spec file
2. Create tests
3. Run tests (should fail)
4. Implement feature
5. Run tests (should pass)
6. Run linting
7. Update TDD markdown
8. Report results
