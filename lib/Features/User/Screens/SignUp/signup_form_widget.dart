import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_emergency_app/Utils/phone_validator.dart';

import '../../../../Common Widgets/constants.dart';
import '../../Controllers/signup_controller.dart';

enum UserRole { user, police, fireFighter, ambulance }

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final controller = Get.put(SignUpController());
  final formKey = GlobalKey<FormState>();

  UserRole selectedRole = UserRole.user;
  bool isTermsAgreed = false;
  bool isObscure = true;

  String get roleString {
    switch (selectedRole) {
      case UserRole.police:
        return "Police";
      case UserRole.fireFighter:
        return "FireFighter";
      case UserRole.ambulance:
        return "Ambulance";
      case UserRole.user:
        return "User";
    }
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = selectedRole == role;
    return InkWell(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : AppColors.textMuted,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog() {
    bool localChecked = isTermsAgreed;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyRedLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: AppColors.emergencyRed, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Terms & Conditions",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to Emergency Services. Our app connects citizens in distress directly with responders (police, ambulance, and firefighters).",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "• Your live GPS location and emergency message are shared with authorized dispatchers when you trigger SOS.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "• Emergency contacts receive automated SMS with your coordinates for rapid assistance.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          value: localChecked,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              localChecked = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "I agree to the Terms of Service & Privacy Policy",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (!localChecked) {
                      Get.snackbar(
                        "Agreement Required",
                        "Please check the box to agree with terms before proceeding.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.emergencyRed,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
                    } else {
                      setState(() {
                        isTermsAgreed = true;
                      });
                      Navigator.of(context).pop();

                      if (formKey.currentState!.validate()) {
                        SignUpController.instance.signUp(
                          controller.fullName.text.trim(),
                          controller.email.text.trim(),
                          controller.password.text.trim(),
                          controller.phoneNo.text.trim(),
                          roleString,
                        );
                      }
                    }
                  },
                  child: Text(
                    "Agree & Register",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Role Header
          Text(
            "Select Your Role",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          // 2x2 Grid of Roles
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  role: UserRole.user,
                  title: "Citizen",
                  icon: Icons.person_outline_rounded,
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRoleCard(
                  role: UserRole.police,
                  title: "Police",
                  icon: Icons.local_police_outlined,
                  activeColor: const Color(0xff1D4ED8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  role: UserRole.fireFighter,
                  title: "Fire Fighter",
                  icon: Icons.local_fire_department_outlined,
                  activeColor: const Color(0xffEA580C),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRoleCard(
                  role: UserRole.ambulance,
                  title: "Ambulance",
                  icon: Icons.medical_services_outlined,
                  activeColor: const Color(0xff059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Full Name
          TextFormField(
            controller: controller.fullName,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name.';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters.';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
              labelText: "Full Name",
              labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
              hintText: "John Doe",
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
          const SizedBox(height: 14),

          // Email
          TextFormField(
            controller: controller.email,
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
                return 'Please enter a valid email address.';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
              labelText: "Email Address",
              labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
              hintText: "user@example.com",
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
          const SizedBox(height: 14),

          // Phone Number
          TextFormField(
            controller: controller.phoneNo,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
            validator: (value) => PhoneValidator.validate(value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
              labelText: "Phone Number",
              labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
              hintText: "0412 345 678 or +61...",
              helperText: "Supports Australian, Pakistani & International numbers",
              helperStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
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
          const SizedBox(height: 14),

          // Password
          TextFormField(
            controller: controller.password,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
            obscureText: isObscure,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required.';
              }
              if (value.trim().length < 6) {
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
              ),
              labelText: "Password",
              labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
              hintText: "••••••••",
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

          // Sign Up Button
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
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _showTermsDialog();
                }
              },
              child: Text(
                "CREATE ACCOUNT",
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