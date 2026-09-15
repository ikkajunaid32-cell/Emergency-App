import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data ?? {};
          if (!isInitialized && user.isNotEmpty) {
            nameController.text = user['userName']?.toString() ?? SessionController().userName ?? '';
            phoneController.text = user['phone']?.toString() ?? SessionController().phone ?? '';
            isInitialized = true;
          }

          final userEmail = user['email']?.toString() ?? SessionController().email ?? '';

          return Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Info",
                  style: TextStyle(
                    color: Color(color),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be valid';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    labelText: "Full Name",
                    hintText: "Full Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) => PhoneValidator.validate(value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    labelText: "Phone Number",
                    hintText: "e.g. 0412 345 678 or +61...",
                    helperText: "Supports Australian & International formats",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: userEmail,
                  enableInteractiveSelection: false,
                  focusNode: AlwaysDisabledFocusNode(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    labelText: "Email",
                    hintText: "Email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(color),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
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

                        Get.snackbar("Save", "Profile Updated",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2));
                      }
                    },
                    child: Text("Update".toUpperCase()),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(color),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: () {
                      Get.to(() => const add_contact(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(seconds: 1),
                          arguments: userEmail);
                    },
                    child: Text("Emergency Contacts".toUpperCase()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}