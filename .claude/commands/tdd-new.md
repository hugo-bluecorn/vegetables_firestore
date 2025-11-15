---
description: Create a new TDD task file from the template
---

You are creating a new TDD (Test-Driven Development) task file for a Dart project.

## Instructions

1. **Ask the user for the feature name** if not provided as an argument
2. **Create the TDD tasks directory** if it doesn't exist:
   - Create `.claude/tdd-tasks/` directory
3. **Generate a filename** based on the feature name:
   - Convert to lowercase with hyphens (e.g., "Add Vegetable Validator" → "add-vegetable-validator.md")
4. **Copy the template** from `.claude/tdd-template.md`
5. **Populate the template** with:
   - Feature name
   - Current date for "Created" and "Last Updated"
   - Ask user for brief feature description and add it
   - Ask user about initial test specifications (or leave as template placeholders)
6. **Save the file** to `.claude/tdd-tasks/[feature-name].md`
7. **Report the file path** to the user
8. **Next steps guidance:**
   - Tell user they can edit the file to add more test specifications
   - Tell user to run `/tdd-implement .claude/tdd-tasks/[feature-name].md` when ready

## Usage Examples

**Example 1:** With feature name as argument
```
/tdd-new Add vegetable validator
```

**Example 2:** Without argument (will prompt)
```
/tdd-new
```

## Interactive Prompts

If user doesn't provide details, ask:
1. What is the feature name?
2. What should this feature do? (brief description)
3. Do you want to add test specifications now, or edit the file later?

## Output

After creating the file, provide:
- Full path to the created TDD file
- Quick summary of what's in the file
- Next steps to take
