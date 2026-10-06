import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/app_data_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();
  final appData = AppDataService.instance;

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxString selectedRole = 'user'.obs; // 'user' or 'admin'

  @override
  void onInit() {
    super.onInit();
    // Pre-fill with demo credentials for instant testing
    emailController.text = "citizen@eatclubtasks.com";
    passwordController.text = "password123";
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      Get.snackbar(
        "Missing Credentials",
        "Please enter both your email and password.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final success = await appData.loginUser(email: email, password: pass);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed('/home');
      Get.snackbar(
        "Welcome Back!",
        "Logged in as ${appData.currentUser.value?.name ?? 'User'}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Login Failed",
        "Invalid email or password. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pass = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
      Get.snackbar(
        "Incomplete Form",
        "Please fill in all registration fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    if (pass.length < 6) {
      Get.snackbar(
        "Weak Password",
        "Password must be at least 6 characters.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final success = await appData.registerUser(
      name: name,
      email: email,
      phone: phone,
      password: pass,
      role: selectedRole.value,
    );
    isLoading.value = false;

    if (success) {
      Get.offAllNamed('/home');
      Get.snackbar(
        "Account Created!",
        "Welcome to Daily Tasks! Start exploring available tasks.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    }
  }

  void quickLoginAsCitizen() {
    emailController.text = "citizen@eatclubtasks.com";
    passwordController.text = "password123";
    selectedRole.value = 'user';
    login();
  }

  void quickLoginAsAdmin() {
    emailController.text = "admin@eatclubtasks.com";
    passwordController.text = "admin123";
    selectedRole.value = 'admin';
    login();
  }

  void logout() async {
    await appData.signOut();
    Get.offAllNamed('/login');
  }
}
