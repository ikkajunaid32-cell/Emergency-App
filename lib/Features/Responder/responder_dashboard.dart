import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import 'package:public_emergency_app/Features/User/Controllers/session_controller.dart';
import 'package:public_emergency_app/Features/User/Screens/Profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import '../User/Controllers/message_sending.dart';
import '../User/Screens/LiveStreaming/live_stream.dart';

class ResponderDashboard extends StatefulWidget {
  const ResponderDashboard({Key? key}) : super(key: key);
  @override
  State<ResponderDashboard> createState() => _ResponderDashboardState();
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

class _ResponderDashboardState extends State<ResponderDashboard> {
  final dbHelper = DatabaseHelper();
  final sessionController = SessionController();
  final locationController = Get.put(messageController());

  String status = 'Unavailable';
  bool _switchValue = false;
  Position? currentPosition;

  late Future<List<Map<String, dynamic>>> _emergenciesFuture;

  @override
  void initState() {
    super.initState();
    _loadSwitchValue();
    _refreshEmergencies();
  }

  void _refreshEmergencies() {
    setState(() {
      _emergenciesFuture = dbHelper.getEmergencies();
    });
  }

  Future<void> _loadSwitchValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _switchValue = prefs.getBool('switchValue') ?? false;
      status = _switchValue ? 'Available' : 'Unavailable';
    });
  }

  Future<void> _saveSwitchValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('switchValue', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Image.asset(
                "assets/logos/emergencyAppLogo.png",
                height: 32,
                width: 32,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Responder Console",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  sessionController.userType ?? "First Responder",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Refresh Dispatches",
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshEmergencies,
          ),
          IconButton(
            tooltip: "Profile",
            icon: const Icon(Icons.person_rounded, color: Colors.white),
            onPressed: () => Get.to(() => const ProfileScreen()),
          ),
          const SizedBox(width: 6),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Column(
        children: [
          // Duty Status Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.softShadow,
              border: Border.all(
                color: _switchValue
                    ? const Color(0xff10b981).withValues(alpha: 0.4)
                    : Colors.grey.shade200,
                width: _switchValue ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _switchValue
                        ? const Color(0xffd1fae5)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _switchValue
                        ? Icons.radio_button_checked_rounded
                        : Icons.power_settings_new_rounded,
                    color: _switchValue
                        ? const Color(0xff059669)
                        : Colors.grey.shade500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _switchValue ? "Active on Duty" : "Off-Duty (Offline)",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _switchValue
                              ? const Color(0xff065f46)
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _switchValue
                            ? "Receiving emergency dispatch calls"
                            : "Turn switch ON to receive alerts",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SlidingSwitch(
                  value: _switchValue,
                  width: 96.0,
                  height: 38.0,
                  textOff: 'OFF',
                  textOn: 'ON',
                  colorOn: const Color(0xff10b981),
                  colorOff: AppColors.emergencyRed,
                  contentSize: 13.0,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                      status = value ? 'Available' : 'Unavailable';
                    });
                    _saveSwitchValue(value);
                    if (value) {
                      setResponderData();
                    } else {
                      removeResponderData();
                    }
                  },
                  onSwipe: () {},
                  onTap: () {},
                  onDoubleTap: () {},
                ),
              ],
            ),
          ),

          // Header title for incidents
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  size: 20,
                  color: AppColors.emergencyRed,
                ),
                const SizedBox(width: 8),
                Text(
                  "Active Incidents",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  "Pull down to refresh",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Incident List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshEmergencies();
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _emergenciesFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final emergencies = snapshot.data ?? [];

                  if (emergencies.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(32),
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xffd1fae5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xff059669),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Active Emergency Requests",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "All clear! When citizens trigger an SOS in your area, dispatch alerts will appear here in real time.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: emergencies.length,
                    itemBuilder: (context, index) {
                      final emergency = emergencies[index];
                      final userAddress = emergency['address']?.toString() ??
                          'Emergency Location';
                      final userLatStr = emergency['lat']?.toString() ?? '';
                      final userLongStr = emergency['long']?.toString() ?? '';
                      final videoId = emergency['videoId']?.toString() ?? '';
                      final time = emergency['time']?.toString() ?? '';

                      double? uLat = double.tryParse(userLatStr);
                      double? uLong = double.tryParse(userLongStr);

                      String distanceText = '';
                      if (currentPosition != null &&
                          uLat != null &&
                          uLong != null) {
                        double dist = calculateDistance(
                            uLat,
                            uLong,
                            currentPosition!.latitude,
                            currentPosition!.longitude);
                        distanceText = '${dist.toStringAsFixed(2)} km away';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.softShadow,
                          border: Border.all(
                            color: AppColors.emergencyRed.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.emergencyRed
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.emergencyRed,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "DISTRESS ALERT",
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.emergencyRed,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (time.isNotEmpty)
                                  Text(
                                    time,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.emergencyRed,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    userAddress,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (distanceText.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me_rounded,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    distanceText,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      if (uLat == null || uLong == null) {
                                        Get.snackbar(
                                            'Error', 'No Emergency Location Coordinates Found');
                                        return;
                                      }
                                      String url = '';
                                      if (Platform.isAndroid) {
                                        url =
                                            'https://www.google.com/maps/search/?api=1&query=$uLat,$uLong';
                                      } else {
                                        url =
                                            'https://maps.apple.com/?q=$uLat,$uLong';
                                      }
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url));
                                      }
                                    },
                                    icon: const Icon(Icons.directions_rounded, size: 18),
                                    label: Text(
                                      "Navigate",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: BorderSide(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.5),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 11),
                                    ),
                                  ),
                                ),
                                if (videoId.isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Get.to(
                                          () => LiveStreamingPage(
                                            liveId: videoId,
                                            isHost: false,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.videocam_rounded,
                                          color: Colors.white,
                                          size: 18),
                                      label: Text(
                                        "Live Stream",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.emergencyRed,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 11),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setResponderData() async {
    try {
      await locationController.handleLocationPermission();
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = pos;

      String responderId = sessionController.userid ?? 'responder_1';
      String responderType = sessionController.userType ?? 'Police';
      String responderName = sessionController.userName ?? 'Responder';
      String responderPhone = sessionController.phone ?? '';

      await dbHelper.upsertResponder({
        "id": responderId,
        "name": responderName,
        "phone": responderPhone,
        "lat": pos.latitude.toString(),
        "long": pos.longitude.toString(),
        "responderType": responderType,
        "status": "Available",
      });
      debugPrint("Responder status saved to SQLite: Available");
    } catch (e) {
      debugPrint("Error updating responder status: $e");
    }
  }

  void removeResponderData() async {
    try {
      String responderId = sessionController.userid ?? 'responder_1';
      await dbHelper.removeResponder(responderId);
      debugPrint("Responder status removed from SQLite");
    } catch (e) {
      debugPrint("Error removing responder: $e");
    }
  }
}
