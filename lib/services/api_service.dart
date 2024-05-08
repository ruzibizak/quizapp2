import 'dart:async';

class ApiService {
  // Simulate API request with a delay
  static Future<bool> loginUser(String email, String password) async {
    // Simulate API request delay
    await Future.delayed(Duration(seconds: 2));
    // Simulate successful login
    return true;
  }

  // Simulate API request with a delay
  static Future<bool> registerUser(String email, String password) async {
    // Simulate API request delay
    await Future.delayed(Duration(seconds: 2));
    // Simulate successful registration
    return true;
  }
}
