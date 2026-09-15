import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import 'package:public_emergency_app/Features/Responder/responder_dashboard.dart';
import 'package:public_emergency_app/Features/User/Controllers/session_controller.dart';
import 'package:public_emergency_app/Features/User/Screens/bottom_nav.dart';
import 'Common Widgets/Onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  await DatabaseHelper().database;

  // Load existing session if any
  bool isLoggedIn = await SessionController().loadSession();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    Widget initialScreen = const OnBoardingScreen();

    if (isLoggedIn) {
      final userType = SessionController().userType;
      if (userType == "Police" ||
          userType == "FireFighter" ||
          userType == "Ambulance") {
        initialScreen = const ResponderDashboard();
      } else {
        initialScreen = const NavBar();
      }
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emergency App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: initialScreen,
    );
  }
}
