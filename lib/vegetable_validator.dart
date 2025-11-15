/// Validates a vegetable name
///
/// Returns true if the name is valid, false otherwise.
/// A valid vegetable name:
/// - Is not null or empty
/// - Contains only letters and spaces
/// - Is between 1 and 50 characters (after trimming)
/// - Is not just whitespace
bool isValidVegetableName(String? name) {
  // Handle null input
  if (name == null) {
    return false;
  }

  // Trim whitespace and check if empty
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) {
    return false;
  }

  // Check length (must be between 1 and 50 characters after trimming)
  if (trimmedName.length > 50) {
    return false;
  }

  // Check if contains only letters and spaces
  // Regular expression: ^[a-zA-Z ]+$
  // ^ - start of string
  // [a-zA-Z ] - letters (uppercase or lowercase) and spaces
  // + - one or more characters
  // $ - end of string
  final validNamePattern = RegExp(r'^[a-zA-Z ]+$');

  return validNamePattern.hasMatch(trimmedName);
}
