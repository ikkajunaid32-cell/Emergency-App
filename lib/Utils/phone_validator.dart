class PhoneValidator {
  /// Strips formatting characters (spaces, dashes, parentheses)
  static String normalize(String? phone) {
    if (phone == null) return '';
    return phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
  }

  /// Checks if a phone number is valid internationally
  /// Supports:
  /// - Australian numbers: 0412 345 678, +61 412 345 678, (02) 9123 4567
  /// - Pakistani numbers: 0300 1234567, +92 300 1234567
  /// - North American numbers: +1 555-123-4567, (555) 123-4567
  /// - UK numbers: +44 7123 456789, 07123 456789
  /// - Any international number with 7 to 15 digits
  static bool isValid(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final clean = normalize(phone);

    // Standard E.164 and local international regex:
    // Optional '+' at start, followed by 7 to 15 digits.
    // Also allows leading zeros for national prefixes (e.g. 04xx or 03xx or 02xx).
    final internationalRegex = RegExp(r'^\+?[0-9]{7,15}$');
    return internationalRegex.hasMatch(clean);
  }

  /// Form field validator for TextFormField
  static String? validate(String? value, {String? customError}) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!isValid(value)) {
      return customError ?? 'Please enter a valid phone number (e.g. 0412 345 678 or +61...)';
    }
    return null;
  }
}
