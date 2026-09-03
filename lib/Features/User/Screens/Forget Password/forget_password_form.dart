import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import 'package:public_emergency_app/Features/Login/login_screen.dart';

class ForgetFormWidget extends StatefulWidget {
  const ForgetFormWidget({Key? key}) : super(key: key);

  @override
  State<ForgetFormWidget> createState() => _ForgetFormWidgetState();
}

class _ForgetFormWidgetState extends State<ForgetFormWidget> {
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Form(
        key: _formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline_rounded),
                labelText: "Full Name",
                hintText: "Full Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                bool isEmailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value ?? '');
                if (!isEmailValid) {
                  return 'Invalid email.';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                labelText: "Email",
                hintText: "Email",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              controller: emailController,
            ),
            const SizedBox(height: 40),
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
                  if (_formkey.currentState!.validate()) {
                    final email = emailController.text.trim();
                    final user = await dbHelper.getUserByEmail(email);
                    if (user != null) {
                      Get.snackbar("Success",
                          "Account found! Please contact support or log in with your credentials.");
                      Get.off(() => const LoginScreen());
                    } else {
                      Get.snackbar("Error", "No user found with this email in database.");
                    }
                  }
                },
                child: Text("Recover".toUpperCase()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
