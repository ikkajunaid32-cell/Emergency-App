import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Utils/emergency_country_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Controllers/message_sending.dart';

class PoliceOptions extends StatefulWidget {
  const PoliceOptions({Key? key}) : super(key: key);

  @override
  State<PoliceOptions> createState() => _PoliceOptionsState();
}

class _PoliceOptionsState extends State<PoliceOptions> {
  final smsController = Get.put(messageController());
  final countryConfig = EmergencyCountryConfig.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Police Emergency",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.policeGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppColors.glowShadow(const Color(0xff1D4ED8)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/logos/policeman.png",
                      width: 44,
                      height: 44,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.local_police, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Police Assistance",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              "Emergency helpline for ${countryConfig.countryFlag} ${countryConfig.countryName}: ${countryConfig.policeNumber}",
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Card 1: Call Police Helpline
            Obx(() {
              final number = countryConfig.policeNumber;
              return _buildActionCard(
                icon: Icons.phone_in_talk_rounded,
                iconColor: Colors.white,
                iconBg: const Color(0xff2563EB),
                title: "Call Police Helpline ($number)",
                subtitle: "Instantly dial official police emergency line",
                badgeText: "Priority 24/7",
                onTap: () async {
                  if (await Permission.phone.request().isGranted) {
                    final uri = Uri.parse("tel:$number");
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      Get.snackbar("Error", "Could not initiate call to $number");
                    }
                  } else {
                    Get.snackbar("Permission Denied", "Phone call permission is required");
                  }
                },
              );
            }),

            const SizedBox(height: 16),

            // Card 2: Find Nearest Police Station Map
            _buildActionCard(
              icon: Icons.map_rounded,
              iconColor: Colors.white,
              iconBg: const Color(0xff0284C7),
              title: "Nearby Police Stations",
              subtitle: "Locate closest police stations on Google / Apple Maps",
              badgeText: "GPS Search",
              onTap: () async {
                try {
                  Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                  final lat = position.latitude;
                  final long = position.longitude;
                  final url = Platform.isAndroid
                      ? "https://www.google.com/maps/search/police+station/@$lat,$long,12.5z"
                      : "https://maps.apple.com/?q=police+station&sll=$lat,$long";
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                } catch (e) {
                  Get.snackbar("Location Error", "Please ensure GPS location is enabled");
                }
              },
            ),

            const SizedBox(height: 16),

            // Card 3: Send Distress SMS with Location
            _buildActionCard(
              icon: Icons.sms_failed_rounded,
              iconColor: Colors.white,
              iconBg: AppColors.emergencyRed,
              title: "Send Police Distress SMS",
              subtitle: "Send instant alert with GPS link to emergency contacts",
              badgeText: "Emergency",
              onTap: () {
                smsController.sendLocationViaSMS("POLICE EMERGENCY! Please send police immediately");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.softShadow,
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: iconBg.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconBg.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.inter(
                              color: iconBg,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
