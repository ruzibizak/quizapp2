import 'dart:async';
import 'dart:convert';
import 'dart:io';

class LocalStorage {
  static const String _fileName = 'data.json';

  // Write data to local file
  
  static Future<void> writeData(Map<String, dynamic> data) async {
    final File file = File(_fileName);
    await file.writeAsString(jsonEncode(data));
  }

  // Read data from local file
  static Future<Map<String, dynamic>> readData() async {
    try {
      final File file = File(_fileName);
      final String contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      // If file does not exist or reading fails, return empty data
      return {};
    }
  }
}
