import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Features/User/Screens/AmbulanceOptions/AmbulanceOptions.dart';
import 'package:public_emergency_app/Features/User/Screens/FirefighterOptions/firefighter_options.dart';
import 'package:public_emergency_app/Features/User/Screens/HospitalOptions/hospital_options.dart';
import 'package:public_emergency_app/Features/User/Screens/PoliceOptions/police_options.dart';

class GridDashboard extends StatelessWidget {
  const GridDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ServiceCardItem> items = [
      ServiceCardItem(
        title: "Police",
        subtitle: "Emergency & Crime",
        actionText: "Call & Dispatch",
        iconPath: "assets/logos/policeman.png",
        gradient: AppColors.policeGradient,
        fallbackIcon: Icons.local_police,
        onTap: () => Get.to(() => const PoliceOptions()),
      ),
      ServiceCardItem(
        title: "Fire Brigade",
        subtitle: "Rescue & Hazards",
        actionText: "Fire Emergency",
        iconPath: "assets/logos/fire-truck.png",
        gradient: AppColors.fireGradient,
        fallbackIcon: Icons.fire_truck,
        onTap: () => Get.to(() => const FireFighterOptions()),
      ),
      ServiceCardItem(
        title: "Ambulance",
        subtitle: "Medical Distress",
        actionText: "Paramedics",
        iconPath: "assets/logos/ambulance.png",
        gradient: AppColors.ambulanceGradient,
        fallbackIcon: Icons.medical_services,
        onTap: () => Get.to(() => const AmbulanceOptions()),
      ),
      ServiceCardItem(
        title: "Hospitals",
        subtitle: "Emergency Care",
        actionText: "Find Nearest",
        iconPath: "assets/logos/hospital.png",
        gradient: AppColors.hospitalGradient,
        fallbackIcon: Icons.local_hospital,
        onTap: () => Get.to(() => const HospitalOptions()),
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.96,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              decoration: BoxDecoration(
                gradient: item.gradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: item.gradient.colors.last.withOpacity(0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            item.iconPath,
                            width: 34,
                            height: 34,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(item.fallbackIcon, color: Colors.white, size: 30),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.actionText,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ServiceCardItem {
  final String title;
  final String subtitle;
  final String actionText;
  final String iconPath;
  final LinearGradient gradient;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  ServiceCardItem({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.iconPath,
    required this.gradient,
    required this.fallbackIcon,
    required this.onTap,
  });
}
