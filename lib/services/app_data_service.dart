import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/submission_model.dart';
import '../models/reward_model.dart';
import '../models/point_transaction_model.dart';
import 'mock_data_seed.dart';
import 'sql_database_service.dart';

class AppDataService extends GetxService {
  static AppDataService get instance => Get.find<AppDataService>();

  final _uuid = const Uuid();
  final SqlDatabaseService _sqlDb = SqlDatabaseService.instance;

  // Base API URL for SQL REST server (Default: localhost for web/desktop, 10.0.2.2 for Android emulator)
  String get apiBaseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://localhost:5000/api';
  }

  // Reactive State
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<TaskModel> allTasks = <TaskModel>[].obs;
  final RxList<SubmissionModel> allSubmissions = <SubmissionModel>[].obs;
  final RxList<RewardModel> allRewards = <RewardModel>[].obs;
  final RxList<RedemptionModel> allRedemptions = <RedemptionModel>[].obs;
  final RxList<PointTransactionModel> pointTransactions = <PointTransactionModel>[].obs;
  final RxSet<String> activeStartedTaskIds = <String>{}.obs;
  final RxBool isSqlBackendConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initStorageAndSql();
  }

  Future<void> _initStorageAndSql() async {
    // 1. Initialize local SQLite database
    await _sqlDb.initialize();

    // 2. Load from local SQLite or Seed Data
    try {
      final tasks = await _sqlDb.getTasks();
      allTasks.assignAll(tasks);
    } catch (_) {
      allTasks.assignAll(MockDataSeed.initialTasks);
    }

    try {
      final rewards = await _sqlDb.getRewards();
      allRewards.assignAll(rewards);
    } catch (_) {
      allRewards.assignAll(MockDataSeed.initialRewards);
    }

    try {
      final subs = await _sqlDb.getSubmissions();
      allSubmissions.assignAll(subs);
    } catch (_) {
      allSubmissions.assignAll(MockDataSeed.initialSubmissions);
    }

    // 3. Load or create default active demo user from preferences
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email') ?? 'citizen@eatclubtasks.com';
    final savedRole = prefs.getString('user_role') ?? 'user';
    final savedName = prefs.getString('user_name') ?? 'Jordan Lee';
    final savedPhone = prefs.getString('user_phone') ?? '0412 345 678';
    final savedPoints = prefs.getInt('user_points') ?? 420;

    currentUser.value = UserModel(
      uid: 'usr_user_1',
      name: savedName,
      email: savedEmail,
      phone: savedPhone,
      role: savedRole,
      points: savedPoints,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );

    // Initial point ledger transactions
    pointTransactions.assignAll([
      PointTransactionModel(
        id: 'tx_1',
        userId: currentUser.value!.uid,
        amount: 250,
        type: 'earned',
        title: 'Morning Park & Trail Cleanup',
        description: 'Task approved by Administrator',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PointTransactionModel(
        id: 'tx_2',
        userId: currentUser.value!.uid,
        amount: 170,
        type: 'earned',
        title: 'Local Community Survey',
        description: 'Task approved by Administrator',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);

    // 4. Probe Central SQL Backend Server in background
    _syncWithSqlBackend();
  }

  Future<void> _syncWithSqlBackend() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      final uri = Uri.parse('$apiBaseUrl/health');
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        isSqlBackendConnected.value = true;
        debugPrint('[AppDataService] Central SQL REST Server connected successfully!');
        _fetchRemoteTasks(client);
        _fetchRemoteSubmissions(client);
        _fetchRemoteRewards(client);
      } else {
        isSqlBackendConnected.value = false;
        debugPrint('[AppDataService] Central SQL REST Server offline. Operating in pure local SQLite mode.');
      }
    } catch (e) {
      isSqlBackendConnected.value = false;
      debugPrint('[AppDataService] Local SQLite active (Central SQL REST Server not reachable): $e');
    }
  }

  Future<void> _fetchRemoteTasks(HttpClient client) async {
    try {
      final request = await client.getUrl(Uri.parse('$apiBaseUrl/tasks'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        if (data['tasks'] != null) {
          final List list = data['tasks'];
          final tasks = list.map((item) {
            List<SubmissionType> reqSubs = [];
            final subsRaw = item['required_submissions'];
            if (subsRaw is List) {
              reqSubs = subsRaw.map((s) => SubmissionType.values.firstWhere(
                (v) => v.name == s.toString(),
                orElse: () => SubmissionType.text,
              )).toList();
            }
            return TaskModel(
              id: item['id'],
              title: item['title'] ?? '',
              description: item['description'] ?? '',
              detailedInstructions: item['detailed_instructions'] ?? '',
              bannerUrl: item['banner_url'] ?? '',
              category: item['category'] ?? 'Community',
              pointsReward: item['points_reward'] ?? 100,
              deadline: DateTime.tryParse(item['deadline']?.toString() ?? '') ??
                  DateTime.now().add(const Duration(hours: 24)),
              startDate: DateTime.tryParse(item['created_at']?.toString() ?? '') ??
                  DateTime.now(),
              requiredSubmissions: reqSubs,
              status: item['status'] ?? 'active',
              createdBy: item['created_by'] ?? 'admin',
              createdAt: DateTime.tryParse(item['created_at']?.toString() ?? '') ??
                  DateTime.now(),
            );
          }).toList();

          if (tasks.isNotEmpty) {
            allTasks.assignAll(tasks);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchRemoteSubmissions(HttpClient client) async {
    try {
      final request = await client.getUrl(Uri.parse('$apiBaseUrl/submissions'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        if (data['submissions'] != null) {
          final List list = data['submissions'];
          final subs = list.map((item) {
            return SubmissionModel(
              id: item['id'],
              taskId: item['task_id'],
              taskTitle: item['task_title'] ?? '',
              pointsReward: item['points_reward'] ?? 0,
              userId: item['user_id'] ?? '',
              userName: item['user_name'] ?? 'User',
              userEmail: item['user_email'] ?? '',
              submittedAt: DateTime.tryParse(item['submitted_at'] ?? '') ?? DateTime.now(),
              status: item['status'] ?? 'pending',
              textResponse: item['text_response'],
              photoUrls: List<String>.from(item['photo_urls'] ?? []),
              videoUrl: item['video_url'],
              fileUrls: List<String>.from(item['file_urls'] ?? []),
              locationAddress: item['location_address'],
              locationLat: (item['location_lat'] as num?)?.toDouble(),
              locationLng: (item['location_lng'] as num?)?.toDouble(),
              rejectionReason: item['rejection_reason'],
              reviewedBy: item['reviewed_by'],
              reviewedAt: DateTime.tryParse(item['reviewed_at'] ?? ''),
            );
          }).toList();

          if (subs.isNotEmpty) {
            allSubmissions.assignAll(subs);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchRemoteRewards(HttpClient client) async {
    try {
      final request = await client.getUrl(Uri.parse('$apiBaseUrl/rewards'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        if (data['rewards'] != null) {
          final List list = data['rewards'];
          final rewards = list.map((item) {
            return RewardModel(
              id: item['id'],
              title: item['title'] ?? '',
              description: item['description'] ?? '',
              pointsCost: item['points_cost'] ?? 100,
              imageUrl: item['image_url'] ?? '',
              category: item['category'] ?? 'General',
              stock: item['stock'] ?? 50,
              isAvailable: item['is_available'] == 1,
            );
          }).toList();

          if (rewards.isNotEmpty) {
            allRewards.assignAll(rewards);
          }
        }
      }
    } catch (_) {}
  }

  // ==========================================
  // AUTHENTICATION & PROFILE METHODS
  // ==========================================
  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'user',
  }) async {
    try {
      final uid = 'usr_${_uuid.v4().substring(0, 8)}';
      final newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        role: role,
        points: role == 'admin' ? 9999 : 0,
        createdAt: DateTime.now(),
      );

      // Save to local SQLite
      await _sqlDb.upsertUser(newUser);

      currentUser.value = newUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      await prefs.setString('user_phone', phone);
      await prefs.setString('user_role', role);
      await prefs.setInt('user_points', newUser.points);

      // Optional sync with SQL backend
      _postJson('$apiBaseUrl/auth/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      });

      return true;
    } catch (e) {
      debugPrint("Registration error: $e");
      return false;
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final isDemoAdmin = email.toLowerCase().contains('admin');
      final role = isDemoAdmin ? 'admin' : 'user';
      final name = isDemoAdmin ? 'System Administrator' : 'Jordan Lee';
      final points = isDemoAdmin ? 9999 : 420;

      // Check local SQLite first
      final existingUser = await _sqlDb.getUser(email);
      if (existingUser != null) {
        currentUser.value = existingUser;
      } else {
        currentUser.value = UserModel(
          uid: 'usr_${_uuid.v4().substring(0, 8)}',
          name: name,
          email: email.trim().toLowerCase(),
          phone: '0412 345 678',
          role: role,
          points: points,
          createdAt: DateTime.now(),
        );
        await _sqlDb.upsertUser(currentUser.value!);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', currentUser.value!.email);
      await prefs.setString('user_role', currentUser.value!.role);
      await prefs.setString('user_name', currentUser.value!.name);
      await prefs.setInt('user_points', currentUser.value!.points);

      // Post login to SQL backend in background
      _postJson('$apiBaseUrl/auth/login', {
        'email': email,
        'password': password,
      });

      return true;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  void switchDemoRole(String role) {
    if (currentUser.value != null) {
      final isAdm = role == 'admin';
      currentUser.value = currentUser.value!.copyWith(
        role: role,
        name: isAdm ? 'System Administrator' : 'Jordan Lee',
        points: isAdm ? 9999 : 420,
      );
    }
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    if (currentUser.value == null) return;
    currentUser.value = currentUser.value!.copyWith(name: name, phone: phone);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_phone', phone);

    await _sqlDb.upsertUser(currentUser.value!);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  // ==========================================
  // TASK DISCOVERY & CREATION METHODS
  // ==========================================
  void startTask(String taskId) {
    activeStartedTaskIds.add(taskId);
  }

  bool isTaskStarted(String taskId) {
    return activeStartedTaskIds.contains(taskId);
  }

  Future<bool> createOrScheduleTask(TaskModel task) async {
    allTasks.insert(0, task);
    await _sqlDb.insertTask(task);

    // Sync with SQL backend server
    _postJson('$apiBaseUrl/tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'detailed_instructions': task.detailedInstructions,
      'banner_url': task.bannerUrl,
      'category': task.category,
      'points_reward': task.pointsReward,
      'deadline': task.deadline,
      'required_submissions': task.requiredSubmissions.map((s) => s.name).toList(),
      'status': task.status,
      'created_by': task.createdBy,
    });

    return true;
  }

  Future<void> deleteTask(String taskId) async {
    allTasks.removeWhere((t) => t.id == taskId);
    await _sqlDb.deleteTask(taskId);

    try {
      final client = HttpClient();
      final req = await client.deleteUrl(Uri.parse('$apiBaseUrl/tasks/$taskId'));
      await req.close();
    } catch (_) {}
  }

  // ==========================================
  // SUBMISSION & REVIEW METHODS
  // ==========================================
  Future<bool> submitTask({
    required TaskModel task,
    String? textResponse,
    List<String> photoUrls = const [],
    String? videoUrl,
    List<String> fileUrls = const [],
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final user = currentUser.value;
    if (user == null) return false;

    final submission = SubmissionModel(
      id: 'sub_${_uuid.v4().substring(0, 8)}',
      taskId: task.id,
      taskTitle: task.title,
      pointsReward: task.pointsReward,
      userId: user.uid,
      userName: user.name,
      userEmail: user.email,
      submittedAt: DateTime.now(),
      status: 'pending',
      textResponse: textResponse,
      photoUrls: photoUrls,
      videoUrl: videoUrl,
      fileUrls: fileUrls,
      locationLat: latitude,
      locationLng: longitude,
      locationAddress: address,
    );

    allSubmissions.insert(0, submission);
    activeStartedTaskIds.remove(task.id);

    // Save to local SQLite
    await _sqlDb.insertSubmission(submission);

    // Sync with SQL backend server
    _postJson('$apiBaseUrl/submissions', {
      'id': submission.id,
      'task_id': submission.taskId,
      'task_title': submission.taskTitle,
      'points_reward': submission.pointsReward,
      'user_id': submission.userId,
      'user_name': submission.userName,
      'user_email': submission.userEmail,
      'text_response': submission.textResponse,
      'photo_urls': submission.photoUrls,
      'video_url': submission.videoUrl,
      'file_urls': submission.fileUrls,
      'location_address': submission.locationAddress,
      'location_lat': submission.locationLat,
      'location_lng': submission.locationLng,
    });

    return true;
  }

  Future<bool> reviewSubmission({
    required String submissionId,
    required bool approve,
    String? rejectionReason,
  }) async {
    final index = allSubmissions.indexWhere((s) => s.id == submissionId);
    if (index == -1) return false;

    final currentSub = allSubmissions[index];
    final newStatus = approve ? 'approved' : 'rejected';
    final reviewer = currentUser.value?.name ?? 'Admin';

    final updatedSub = currentSub.copyWith(
      status: newStatus,
      rejectionReason: approve ? null : rejectionReason ?? 'Did not meet requirements',
      reviewedBy: reviewer,
      reviewedAt: DateTime.now(),
    );

    allSubmissions[index] = updatedSub;

    // Apply atomic transaction in local SQLite
    await _sqlDb.reviewSubmissionInSql(
      submissionId: submissionId,
      approve: approve,
      rejectionReason: rejectionReason,
      reviewedBy: reviewer,
    );

    // If approved, update live user points
    if (approve) {
      final reward = currentSub.pointsReward;
      if (currentUser.value != null && currentUser.value!.uid == currentSub.userId) {
        final newPoints = currentUser.value!.points + reward;
        currentUser.value = currentUser.value!.copyWith(points: newPoints);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_points', newPoints);

        pointTransactions.insert(
          0,
          PointTransactionModel(
            id: 'tx_${_uuid.v4().substring(0, 8)}',
            userId: currentSub.userId,
            amount: reward,
            type: 'earned',
            title: currentSub.taskTitle,
            description: 'Task approved by Administrator',
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // Sync review action with SQL backend server
    _postJson('$apiBaseUrl/submissions/$submissionId/review', {
      'approve': approve,
      'rejection_reason': rejectionReason,
      'reviewed_by': reviewer,
    });

    return true;
  }

  // ==========================================
  // REWARDS & POINT REDEMPTION METHODS
  // ==========================================
  Future<bool> redeemReward(RewardModel reward) async {
    final user = currentUser.value;
    if (user == null) return false;
    if (user.points < reward.pointsCost) return false;

    // Deduct points
    final newPoints = user.points - reward.pointsCost;
    currentUser.value = user.copyWith(points: newPoints);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_points', newPoints);

    final redemption = RedemptionModel(
      id: 'red_${_uuid.v4().substring(0, 8)}',
      rewardId: reward.id,
      rewardTitle: reward.title,
      rewardImageUrl: reward.imageUrl,
      pointsCost: reward.pointsCost,
      userId: user.uid,
      userName: user.name,
      redeemedAt: DateTime.now(),
      status: 'fulfilled',
    );
    allRedemptions.insert(0, redemption);

    pointTransactions.insert(
      0,
      PointTransactionModel(
        id: 'tx_${_uuid.v4().substring(0, 8)}',
        userId: user.uid,
        amount: reward.pointsCost,
        type: 'spent',
        title: reward.title,
        description: 'Redeemed in Rewards Store',
        timestamp: DateTime.now(),
      ),
    );

    // Save to local SQLite
    await _sqlDb.redeemRewardInSql(redemption);

    // Sync with SQL backend server
    _postJson('$apiBaseUrl/rewards/redeem', {
      'user_id': user.uid,
      'reward_id': reward.id,
    });

    return true;
  }

  // Helper method for asynchronous HTTP POST
  void _postJson(String url, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final req = await client.postUrl(Uri.parse(url));
      req.headers.set('Content-Type', 'application/json; charset=UTF-8');
      req.write(jsonEncode(data));
      await req.close();
    } catch (_) {}
  }

  // ==========================================
  // FILTERED LIST GETTERS
  // ==========================================
  List<SubmissionModel> get mySubmissions {
    final uid = currentUser.value?.uid;
    if (uid == null) return [];
    return allSubmissions.where((s) => s.userId == uid).toList();
  }

  List<SubmissionModel> get myPendingSubmissions =>
      mySubmissions.where((s) => s.isPending).toList();

  List<SubmissionModel> get myCompletedSubmissions =>
      mySubmissions.where((s) => s.isApproved).toList();

  List<SubmissionModel> get myRejectedSubmissions =>
      mySubmissions.where((s) => s.isRejected).toList();

  List<SubmissionModel> get allPendingSubmissionsForAdmin =>
      allSubmissions.where((s) => s.isPending).toList();

  int get totalCompletedCount =>
      allSubmissions.where((s) => s.isApproved).length;

  int get totalPointsAwarded =>
      allSubmissions
          .where((s) => s.isApproved)
          .fold(0, (total, s) => total + s.pointsReward);
}
