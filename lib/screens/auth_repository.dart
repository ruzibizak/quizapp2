import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AuthRepository with ChangeNotifier {
  static Database? _database;
  static final _tableName = 'user';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'user.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT)',
        );
      },
    );
  }

  Future<int> insertUser(String email, String password) async {
    final db = await database;
    return await db.insert(
      _tableName,
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> register(String email, String password) async {
    try {
      await insertUser(email, password);
      return true;
    } catch (e) {
      print('Error registering user: $e');
      throw 'Registration failed: $e'; // Throw an exception with the error message
    }
  }

  Future<bool> login(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      _tableName,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return users.isNotEmpty;
  }
}