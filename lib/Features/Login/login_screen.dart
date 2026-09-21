

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Common Widgets/form_footer.dart';
import '../../Common Widgets/constants.dart';
import 'login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Modern Hero & Logo Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Image.asset(
                    "assets/logos/emergencyAppLogo.png",
                    height: 80,
                    width: 80,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "EMERGENCY RESPONSE",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Sign in to access emergency patrol services",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 28),

                // Main Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.softShadow,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoginForm(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Footer navigation
                const FooterWidget(
                  Texts: "Don't have an account? ",
                  Title: "Sign Up",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}