class Validators {
  static bool isValidEmail(String email) {
    // Basic email validation
    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // Password should be at least 6 characters long
    return password.length >= 6;
  }
}
