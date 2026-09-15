import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Database/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ListOfResponders/select_responder.dart';
import '../User/Screens/LiveStreaming/live_stream.dart';

class EmergenciesScreen extends StatefulWidget {
  const EmergenciesScreen({Key? key}) : super(key: key);

  @override
  State<EmergenciesScreen> createState() => _EmergenciesScreenState();
}

class _EmergenciesScreenState extends State<EmergenciesScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _emergenciesFuture;

  @override
  void initState() {
    super.initState();
    _refreshEmergencies();
  }

  void _refreshEmergencies() {
    setState(() {
      _emergenciesFuture = dbHelper.getEmergencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        title: Text(
          "Active Emergencies",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshEmergencies,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshEmergencies();
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _emergenciesFuture,
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.emergencyRed, size: 55),
                      const SizedBox(height: 16),
                      Text(
                        "Unable to load emergencies",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xff059669), size: 64),
                    const SizedBox(height: 16),
                    Text(
                      "No Active Emergencies",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "All clear! Stay safe.\nPull down to refresh incidents.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final address = item['address']?.toString() ?? 'Unknown Location';
                final time = item['time']?.toString() ?? '';
                final latStr = item['lat']?.toString() ?? '0.0';
                final longStr = item['long']?.toString() ?? '0.0';
                final videoId = item['videoId']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.softShadow,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.emergencyRedLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
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
                                  "EMERGENCY ACTIVE",
                                  style: GoogleFonts.inter(
                                    color: AppColors.emergencyDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            time,
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.emergencyRed, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.map_rounded, size: 18),
                              label: const Text("Map"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                final url = Platform.isAndroid
                                    ? 'https://www.google.com/maps/search/?api=1&query=$latStr,$longStr'
                                    : 'https://maps.apple.com/?q=$latStr,$longStr';
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.video_call_rounded, size: 18),
                              label: const Text("Live"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emergencyRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Get.to(() => LiveStreamingPage(liveId: videoId, isHost: false));
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                              label: const Text("Dispatch"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                final lat = double.tryParse(latStr) ?? 0.0;
                                final long = double.tryParse(longStr) ?? 0.0;
                                Get.to(() => SelectResponder(
                                      userLat: lat,
                                      userLong: long,
                                      userAddress: address,
                                      userID: videoId,
                                    ));
                              },
                            ),
                          ),
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
    );
  }
}
