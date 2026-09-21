import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import 'package:public_emergency_app/Features/Login/login_screen.dart';

class ForgetFormWidget extends StatefulWidget {
  const ForgetFormWidget({Key? key}) : super(key: key);

  @override
  State<ForgetFormWidget> createState() => _ForgetFormWidgetState();
}

class _ForgetFormWidgetState extends State<ForgetFormWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Recovery",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Full Name
          TextFormField(
            controller: nameController,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
              labelText: "Full Name",
              labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
              hintText: "Enter your full name",
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: emailController,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address.';
              }
              bool isEmailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value.trim());
              if (!isEmailValid) {
                return 'Invalid email address.';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
              labelText: "Email Address",
              labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
              hintText: "Enter registered email",
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recover Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final email = emailController.text.trim();
                  final user = await dbHelper.getUserByEmail(email);
                  if (user != null) {
                    Get.snackbar(
                      "Account Verified",
                      "User account verified. Please sign in with your credentials.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xff059669),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 4),
                    );
                    Get.off(() => const LoginScreen());
                  } else {
                    Get.snackbar(
                      "User Not Found",
                      "No account exists for $email in our offline database.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.emergencyRed,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 4),
                    );
                  }
                }
              },
              child: Text(
                "VERIFY & RECOVER",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
