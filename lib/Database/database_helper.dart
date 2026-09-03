import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'emergency_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        userName TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        password TEXT,
        userType TEXT
      )
    ''');

    // Emergencies / SOS table
    await db.execute('''
      CREATE TABLE emergencies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        videoId TEXT,
        address TEXT,
        email TEXT,
        lat TEXT,
        long TEXT,
        time TEXT,
        status TEXT
      )
    ''');

    // Active Responders table
    await db.execute('''
      CREATE TABLE active_responders (
        id TEXT PRIMARY KEY,
        name TEXT,
        phone TEXT,
        lat TEXT,
        long TEXT,
        responderType TEXT,
        status TEXT
      )
    ''');
  }

  // --- User Operations ---
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> authenticateUser(
      String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateUser(String id, Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }

  // --- Emergency / SOS Operations ---
  Future<int> insertEmergency(Map<String, dynamic> emergency) async {
    Database db = await database;
    return await db.insert('emergencies', emergency);
  }

  Future<List<Map<String, dynamic>>> getEmergencies() async {
    Database db = await database;
    return await db.query('emergencies', orderBy: 'id DESC');
  }

  Future<int> deleteEmergency(int id) async {
    Database db = await database;
    return await db.delete('emergencies', where: 'id = ?', whereArgs: [id]);
  }

  // --- Active Responders Operations ---
  Future<int> upsertResponder(Map<String, dynamic> responder) async {
    Database db = await database;
    return await db.insert('active_responders', responder,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getActiveResponders() async {
    Database db = await database;
    return await db.query('active_responders');
  }

  Future<int> removeResponder(String id) async {
    Database db = await database;
    return await db.delete('active_responders', where: 'id = ?', whereArgs: [id]);
  }
}
