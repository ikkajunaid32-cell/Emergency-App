import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import 'package:public_emergency_app/Features/Responder/responder_dashboard.dart';
import 'package:public_emergency_app/Features/User/Controllers/session_controller.dart';
import 'package:public_emergency_app/Features/User/Screens/bottom_nav.dart';

// SignUpController stores user data in local SQLite database and establishes session
class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  // TextField Controllers to get data from TextFields
  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final phoneNo = TextEditingController();

  final dbHelper = DatabaseHelper();

  void signUp(String username, String userEmail, String userPassword, String phone,
      String userType) async {
    try {
      if (userEmail.isEmpty || userPassword.isEmpty || username.isEmpty) {
        Get.snackbar("Error", "Please fill in all fields");
        return;
      }

      if (userPassword.length < 6) {
        Get.snackbar("Error", "Password Should Be At Least 6 Characters");
        return;
      }

      final existingUser = await dbHelper.getUserByEmail(userEmail);
      if (existingUser != null) {
        Get.snackbar("Error", "Email Already In Use");
        return;
      }

      final String newUserId = DateTime.now().millisecondsSinceEpoch.toString();

      await dbHelper.insertUser({
        'id': newUserId,
        'userName': username,
        'email': userEmail.trim().toLowerCase(),
        'phone': phone,
        'password': userPassword,
        'userType': userType,
      });

      await SessionController().saveSession(
        id: newUserId,
        userEmail: userEmail.trim().toLowerCase(),
        name: username,
        type: userType,
        phoneNumber: phone,
      );

      Get.snackbar("Success", "Sign Up Successfully");

      if (userType == "Police" || userType == "FireFighter" || userType == "Ambulance") {
        Get.offAll(() => const ResponderDashboard());
      } else {
        Get.offAll(() => const NavBar());
      }
    } catch (error) {
      Get.snackbar("Error", error.toString());
      debugPrint("SignUp Error: $error");
    }
  }
}
