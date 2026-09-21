import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import 'package:public_emergency_app/Utils/phone_validator.dart';
import '../../../Emergency Contacts/add_contacts.dart';
import '../../Controllers/session_controller.dart';

class ProfileFormWidget extends StatefulWidget {
  const ProfileFormWidget({Key? key}) : super(key: key);

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  final dbHelper = DatabaseHelper();
  late Future<Map<String, dynamic>?> _userFuture;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    _loadUserData();
  }

  void _loadUserData() {
    final uid = SessionController().userid ?? '';
    _userFuture = dbHelper.getUserById(uid);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !isInitialized) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final user = snapshot.data ?? {};
        if (!isInitialized && user.isNotEmpty) {
          nameController.text =
              user['userName']?.toString() ?? SessionController().userName ?? '';
          phoneController.text =
              user['phone']?.toString() ?? SessionController().phone ?? '';
          isInitialized = true;
        }

        final userEmail =
            user['email']?.toString() ?? SessionController().email ?? '';

        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Personal Information",
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Full Name
              TextFormField(
                controller: nameController,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  labelText: "Full Name",
                  labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                  hintText: "Full Name",
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

              // Phone
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark),
                validator: (value) => PhoneValidator.validate(value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  labelText: "Phone Number",
                  labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                  hintText: "e.g. 0412 345 678 or +61...",
                  helperText: "Supports Australian & International formats",
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

              // Email (Read-only)
              TextFormField(
                initialValue: userEmail,
                readOnly: true,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMuted),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted),
                  labelText: "Registered Email",
                  labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save / Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
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
                      final newName = nameController.text.trim();
                      final newPhone = phoneController.text.trim();
                      final uid = SessionController().userid ?? '';

                      await dbHelper.updateUser(uid, {
                        'userName': newName,
                        'phone': newPhone,
                      });

                      SessionController().userName = newName;
                      SessionController().phone = newPhone;

                      Get.snackbar("Profile Saved", "Your profile details have been updated.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xff059669),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3));
                    }
                  },
                  child: Text(
                    "UPDATE PROFILE",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Manage Emergency Contacts Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.emergencyDark,
                    side: const BorderSide(color: AppColors.emergencyRed, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const add_contact(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                        arguments: userEmail);
                  },
                  icon: const Icon(Icons.contacts_rounded, size: 20),
                  label: Text(
                    "MANAGE EMERGENCY CONTACTS",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}