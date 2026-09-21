import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import '../Response Screen/emergencies_screen.dart';

class SelectResponder extends StatefulWidget {
  final String userID;
  final double userLat;
  final double userLong;
  final String userAddress;
  final dynamic userPhone;

  const SelectResponder({
    Key? key,
    required this.userID,
    required this.userLat,
    required this.userLong,
    required this.userAddress,
    this.userPhone,
  }) : super(key: key);

  @override
  State<SelectResponder> createState() => _SelectResponderState();
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

class _SelectResponderState extends State<SelectResponder> {
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _respondersFuture;

  @override
  void initState() {
    super.initState();
    _refreshResponders();
  }

  void _refreshResponders() {
    setState(() {
      _respondersFuture = dbHelper.getActiveResponders();
    });
  }

  Color _getRoleColor(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('police')) return const Color(0xff2563eb);
    if (lower.contains('fire')) return const Color(0xffea580c);
    if (lower.contains('ambulance') || lower.contains('medic')) return AppColors.emergencyRed;
    return AppColors.primary;
  }

  IconData _getRoleIcon(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('police')) return Icons.local_police_rounded;
    if (lower.contains('fire')) return Icons.local_fire_department_rounded;
    if (lower.contains('ambulance') || lower.contains('medic')) return Icons.medical_services_rounded;
    return Icons.shield_rounded;
  }

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
          "Dispatch Responder",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh Responders",
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshResponders,
          ),
          const SizedBox(width: 4),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: Column(
        children: [
          // Emergency Incident Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.softShadow,
              border: Border.all(
                color: AppColors.emergencyRed.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.emergencyRed,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DISPATCH TARGET",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emergencyRed,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.userAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.radar_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Nearby Active Responders",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),

          // Responder List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _respondersFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_search_rounded,
                              color: Colors.grey.shade400,
                              size: 52,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Active Responders Available",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "First responders must set their duty switch to ON to receive incoming dispatches.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: _refreshResponders,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              "Check Again",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final responder = list[index];
                    final responderType =
                        responder['responderType']?.toString() ?? 'Responder';
                    final responderName =
                        responder['name']?.toString() ?? responderType;
                    final lat =
                        double.tryParse(responder['lat']?.toString() ?? '') ?? 0.0;
                    final long =
                        double.tryParse(responder['long']?.toString() ?? '') ?? 0.0;

                    double dist = calculateDistance(
                        widget.userLat, widget.userLong, lat, long);

                    final roleColor = _getRoleColor(responderType);
                    final roleIcon = _getRoleIcon(responderType);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppColors.softShadow,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              roleIcon,
                              color: roleColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  responderName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: roleColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        responderType,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: roleColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.near_me_rounded,
                                      size: 13,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "${dist.toStringAsFixed(2)} km",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.snackbar(
                                "Assigned Successfully",
                                "Emergency dispatched to $responderName ($responderType)",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xff059669),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 14,
                                duration: const Duration(seconds: 2),
                              );
                              Get.off(() => const EmergenciesScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Assign",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
