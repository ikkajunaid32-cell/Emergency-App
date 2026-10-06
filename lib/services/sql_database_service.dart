import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/submission_model.dart';
import '../models/reward_model.dart';
import 'mock_data_seed.dart';

class SqlDatabaseService {
  static final SqlDatabaseService instance = SqlDatabaseService._internal();
  SqlDatabaseService._internal();

  Database? _db;
  bool _isInitialized = false;

  Future<Database?> get database async {
    if (_db != null) return _db;
    if (kIsWeb) return null; // Web uses local reactive cache / REST sync
    try {
      _db = await _initDatabase();
      return _db;
    } catch (e) {
      debugPrint("SQLite initialization notice (fallback to reactive cache): $e");
      return null;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    if (!kIsWeb) {
      try {
        await database;
      } catch (e) {
        debugPrint("SQLite background init: $e");
      }
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'daily_tasks_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // 1. Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        role TEXT NOT NULL DEFAULT 'user',
        points INTEGER NOT NULL DEFAULT 0,
        avatar_url TEXT,
        created_at TEXT
      )
    ''');

    // 2. Tasks table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        detailed_instructions TEXT NOT NULL,
        banner_url TEXT,
        category TEXT NOT NULL,
        points_reward INTEGER NOT NULL DEFAULT 100,
        deadline TEXT NOT NULL DEFAULT '24 Hours',
        required_submissions TEXT NOT NULL DEFAULT '["text"]',
        status TEXT NOT NULL DEFAULT 'active',
        created_by TEXT,
        created_at TEXT
      )
    ''');

    // 3. Submissions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS submissions (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        task_title TEXT NOT NULL,
        points_reward INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_email TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        text_response TEXT,
        photo_urls TEXT DEFAULT '[]',
        video_url TEXT,
        file_urls TEXT DEFAULT '[]',
        location_address TEXT,
        location_lat REAL,
        location_lng REAL,
        rejection_reason TEXT,
        reviewed_by TEXT,
        reviewed_at TEXT,
        submitted_at TEXT
      )
    ''');

    // 4. Rewards table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rewards (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        points_cost INTEGER NOT NULL,
        image_url TEXT,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL DEFAULT 50,
        is_available INTEGER NOT NULL DEFAULT 1,
        created_at TEXT
      )
    ''');

    // 5. Redemptions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS redemptions (
        id TEXT PRIMARY KEY,
        reward_id TEXT NOT NULL,
        reward_title TEXT NOT NULL,
        reward_image_url TEXT,
        points_cost INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'fulfilled',
        redeemed_at TEXT
      )
    ''');

    // 6. Point Transactions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS point_transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        reference_id TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed initial tasks
    for (final task in MockDataSeed.initialTasks) {
      await db.insert('tasks', {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'detailed_instructions': task.detailedInstructions,
        'banner_url': task.bannerUrl,
        'category': task.category,
        'points_reward': task.pointsReward,
        'deadline': task.deadline,
        'required_submissions': jsonEncode(
            task.requiredSubmissions.map((s) => s.name).toList()),
        'status': task.status,
        'created_by': task.createdBy,
        'created_at': task.createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Seed initial rewards
    for (final reward in MockDataSeed.initialRewards) {
      await db.insert('rewards', {
        'id': reward.id,
        'title': reward.title,
        'description': reward.description,
        'points_cost': reward.pointsCost,
        'image_url': reward.imageUrl,
        'category': reward.category,
        'stock': reward.stock,
        'is_available': reward.isAvailable ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ==========================================
  // TASKS CRUD
  // ==========================================
  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    if (db == null) return MockDataSeed.initialTasks;

    final List<Map<String, dynamic>> maps =
        await db.query('tasks', where: 'status = ?', whereArgs: ['active'], orderBy: 'created_at DESC');

    if (maps.isEmpty) return MockDataSeed.initialTasks;

    return maps.map((map) {
      List<SubmissionType> reqSubs = [];
      try {
        final List<dynamic> list = jsonDecode(map['required_submissions'] as String);
        reqSubs = list.map((item) {
          return SubmissionType.values.firstWhere(
            (e) => e.name == item.toString(),
            orElse: () => SubmissionType.text,
          );
        }).toList();
      } catch (_) {
        reqSubs = [SubmissionType.text];
      }

      return TaskModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        detailedInstructions: map['detailed_instructions'] as String,
        bannerUrl: map['banner_url'] as String? ?? '',
        category: map['category'] as String,
        pointsReward: (map['points_reward'] as num).toInt(),
        deadline: DateTime.tryParse(map['deadline'] as String? ?? '') ??
            DateTime.now().add(const Duration(hours: 24)),
        startDate: DateTime.tryParse(map['created_at'] as String? ?? '') ??
            DateTime.now(),
        requiredSubmissions: reqSubs,
        status: map['status'] as String? ?? 'active',
        createdBy: map['created_by'] as String? ?? 'admin',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> insertTask(TaskModel task) async {
    final db = await database;
    if (db == null) return;

    await db.insert('tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'detailed_instructions': task.detailedInstructions,
      'banner_url': task.bannerUrl,
      'category': task.category,
      'points_reward': task.pointsReward,
      'deadline': task.deadline,
      'required_submissions':
          jsonEncode(task.requiredSubmissions.map((s) => s.name).toList()),
      'status': task.status,
      'created_by': task.createdBy,
      'created_at': task.createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTask(String taskId) async {
    final db = await database;
    if (db == null) return;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  // ==========================================
  // SUBMISSIONS CRUD
  // ==========================================
  Future<List<SubmissionModel>> getSubmissions({String? userId}) async {
    final db = await database;
    if (db == null) return MockDataSeed.initialSubmissions;

    final List<Map<String, dynamic>> maps = userId != null
        ? await db.query('submissions', where: 'user_id = ?', whereArgs: [userId], orderBy: 'submitted_at DESC')
        : await db.query('submissions', orderBy: 'submitted_at DESC');

    if (maps.isEmpty && userId == null) return MockDataSeed.initialSubmissions;

    return maps.map((map) {
      List<String> photos = [];
      List<String> files = [];
      try {
        photos = List<String>.from(jsonDecode(map['photo_urls'] as String? ?? '[]'));
      } catch (_) {}
      try {
        files = List<String>.from(jsonDecode(map['file_urls'] as String? ?? '[]'));
      } catch (_) {}

      return SubmissionModel(
        id: map['id'] as String,
        taskId: map['task_id'] as String,
        taskTitle: map['task_title'] as String,
        pointsReward: (map['points_reward'] as num).toInt(),
        userId: map['user_id'] as String,
        userName: map['user_name'] as String,
        userEmail: map['user_email'] as String,
        submittedAt: DateTime.tryParse(map['submitted_at'] as String? ?? '') ?? DateTime.now(),
        status: map['status'] as String? ?? 'pending',
        textResponse: map['text_response'] as String?,
        photoUrls: photos,
        videoUrl: map['video_url'] as String?,
        fileUrls: files,
        locationAddress: map['location_address'] as String?,
        locationLat: (map['location_lat'] as num?)?.toDouble(),
        locationLng: (map['location_lng'] as num?)?.toDouble(),
        rejectionReason: map['rejection_reason'] as String?,
        reviewedBy: map['reviewed_by'] as String?,
        reviewedAt: DateTime.tryParse(map['reviewed_at'] as String? ?? ''),
      );
    }).toList();
  }

  Future<void> insertSubmission(SubmissionModel sub) async {
    final db = await database;
    if (db == null) return;

    await db.insert('submissions', {
      'id': sub.id,
      'task_id': sub.taskId,
      'task_title': sub.taskTitle,
      'points_reward': sub.pointsReward,
      'user_id': sub.userId,
      'user_name': sub.userName,
      'user_email': sub.userEmail,
      'status': sub.status,
      'text_response': sub.textResponse,
      'photo_urls': jsonEncode(sub.photoUrls),
      'video_url': sub.videoUrl,
      'file_urls': jsonEncode(sub.fileUrls),
      'location_address': sub.locationAddress,
      'location_lat': sub.locationLat,
      'location_lng': sub.locationLng,
      'rejection_reason': sub.rejectionReason,
      'reviewed_by': sub.reviewedBy,
      'reviewed_at': sub.reviewedAt?.toIso8601String(),
      'submitted_at': sub.submittedAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> reviewSubmissionInSql({
    required String submissionId,
    required bool approve,
    String? rejectionReason,
    String? reviewedBy,
  }) async {
    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      final List<Map<String, dynamic>> subs = await txn.query(
        'submissions',
        where: 'id = ?',
        whereArgs: [submissionId],
      );
      if (subs.isEmpty) return;

      final sub = subs.first;
      final newStatus = approve ? 'approved' : 'rejected';

      await txn.update(
        'submissions',
        {
          'status': newStatus,
          'rejection_reason': approve ? null : rejectionReason,
          'reviewed_by': reviewedBy ?? 'Admin',
          'reviewed_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [submissionId],
      );

      if (approve) {
        final userId = sub['user_id'] as String;
        final reward = (sub['points_reward'] as num).toInt();
        await txn.rawUpdate(
          'UPDATE users SET points = points + ? WHERE id = ?',
          [reward, userId],
        );
        await txn.insert('point_transactions', {
          'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
          'user_id': userId,
          'amount': reward,
          'type': 'earned',
          'title': sub['task_title'] as String,
          'description': 'Task approved by Administrator',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  // ==========================================
  // REWARDS & REDEMPTIONS CRUD
  // ==========================================
  Future<List<RewardModel>> getRewards() async {
    final db = await database;
    if (db == null) return MockDataSeed.initialRewards;

    final List<Map<String, dynamic>> maps =
        await db.query('rewards', where: 'is_available = 1', orderBy: 'points_cost ASC');

    if (maps.isEmpty) return MockDataSeed.initialRewards;

    return maps.map((map) {
      return RewardModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        pointsCost: (map['points_cost'] as num).toInt(),
        imageUrl: map['image_url'] as String? ?? '',
        category: map['category'] as String,
        stock: (map['stock'] as num?)?.toInt() ?? 50,
        isAvailable: (map['is_available'] as int?) == 1,
      );
    }).toList();
  }

  Future<void> redeemRewardInSql(RedemptionModel red) async {
    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE users SET points = points - ? WHERE id = ?',
        [red.pointsCost, red.userId],
      );
      await txn.insert('redemptions', {
        'id': red.id,
        'reward_id': red.rewardId,
        'reward_title': red.rewardTitle,
        'reward_image_url': red.rewardImageUrl,
        'points_cost': red.pointsCost,
        'user_id': red.userId,
        'user_name': red.userName,
        'status': red.status,
        'redeemed_at': red.redeemedAt.toIso8601String(),
      });
      await txn.insert('point_transactions', {
        'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': red.userId,
        'amount': red.pointsCost,
        'type': 'spent',
        'title': red.rewardTitle,
        'description': 'Redeemed in Rewards Store',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  // ==========================================
  // USERS & TRANSACTIONS
  // ==========================================
  Future<UserModel?> getUser(String email) async {
    final db = await database;
    if (db == null) return null;

    final maps = await db.query('users', where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (maps.isEmpty) return null;

    final map = maps.first;
    return UserModel(
      uid: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      points: (map['points'] as num?)?.toInt() ?? 0,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Future<void> upsertUser(UserModel user) async {
    final db = await database;
    if (db == null) return;

    await db.insert('users', {
      'id': user.uid,
      'name': user.name,
      'email': user.email.toLowerCase(),
      'phone': user.phone,
      'role': user.role,
      'points': user.points,
      'avatar_url': user.avatarUrl,
      'created_at': user.createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
