import 'package:shared_preferences/shared_preferences.dart';

// This controller is used to save the current user ID and session info
class SessionController {
  static final SessionController _session = SessionController._internal();

  String? userid;
  String? email;
  String? userName;
  String? userType;
  String? phone;

  factory SessionController() {
    return _session;
  }

  SessionController._internal();

  Future<void> saveSession({
    required String id,
    required String userEmail,
    required String name,
    required String type,
    required String phoneNumber,
  }) async {
    userid = id;
    email = userEmail;
    userName = name;
    userType = type;
    phone = phoneNumber;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_userid', id);
    await prefs.setString('session_email', userEmail);
    await prefs.setString('session_username', name);
    await prefs.setString('session_usertype', type);
    await prefs.setString('session_phone', phoneNumber);
  }

  Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userid = prefs.getString('session_userid');
    email = prefs.getString('session_email');
    userName = prefs.getString('session_username');
    userType = prefs.getString('session_usertype');
    phone = prefs.getString('session_phone');

    return userid != null && userid!.isNotEmpty;
  }

  Future<void> clearSession() async {
    userid = null;
    email = null;
    userName = null;
    userType = null;
    phone = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_userid');
    await prefs.remove('session_email');
    await prefs.remove('session_username');
    await prefs.remove('session_usertype');
    await prefs.remove('session_phone');
  }
}
