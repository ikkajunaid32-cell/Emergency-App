import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'services/app_data_service.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/main_nav_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize unified SQL data service (Local SQLite + Central SQL Backend)
  Get.put(AppDataService());

  runApp(const DailyTasksApp());
}

class DailyTasksApp extends StatelessWidget {
  const DailyTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Tasks',
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const MainNavView()),
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/register', page: () => const RegisterView()),
      ],
    );
  }
}
