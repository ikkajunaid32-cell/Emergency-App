import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import 'package:public_emergency_app/Features/Responder/responder_dashboard.dart';
import 'package:public_emergency_app/Features/User/Controllers/session_controller.dart';
import 'package:public_emergency_app/Features/User/Screens/bottom_nav.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  // TextField Controllers to get data from TextFields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final dbHelper = DatabaseHelper();

  void loginUser(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter Email & Password");
      return;
    }

    try {
      final user = await dbHelper.authenticateUser(email, password);

      if (user != null) {
        final userId = user['id']?.toString() ?? '';
        final userEmail = user['email']?.toString() ?? '';
        final userName = user['userName']?.toString() ?? '';
        final userType = user['userType']?.toString() ?? 'User';
        final phone = user['phone']?.toString() ?? '';

        await SessionController().saveSession(
          id: userId,
          userEmail: userEmail,
          name: userName,
          type: userType,
          phoneNumber: phone,
        );

        Get.snackbar("Success", "Login Successfully :)");

        if (userType == "Police" ||
            userType == "FireFighter" ||
            userType == "Ambulance") {
          Get.offAll(() => const ResponderDashboard());
        } else {
          Get.offAll(() => const NavBar());
        }
      } else {
        final existingUser = await dbHelper.getUserByEmail(email);
        if (existingUser == null) {
          Get.snackbar("Error", "User Not Found with this Email");
        } else {
          Get.snackbar("Error", "Wrong Password");
        }
      }
    } catch (error) {
      Get.snackbar("Error", error.toString());
      debugPrint("Login Error: $error");
    }
  }
}
