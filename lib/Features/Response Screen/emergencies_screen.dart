import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Color(color),
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(Get.height * 0.1),
          child: Container(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        image: const AssetImage(
                            "assets/logos/emergencyAppLogo.png"),
                        height: Get.height * 0.08),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Emergencies",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshEmergencies();
        },
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _emergenciesFuture,
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 55),
                        const SizedBox(height: 16),
                        const Text(
                          "Unable to load emergencies",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
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
                    children: const [
                      Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 55),
                      SizedBox(height: 16),
                      Text(
                        "No Active Emergencies",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "All clear! Stay safe.\nPull down to refresh.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];

                  final address =
                      item['address']?.toString() ?? 'Unknown Location';
                  final time = item['time']?.toString() ?? '';
                  final latStr = item['lat']?.toString() ?? '0.0';
                  final longStr = item['long']?.toString() ?? '0.0';
                  final videoId = item['videoId']?.toString() ?? '';

                  return Container(
                    margin: EdgeInsets.symmetric(
                        vertical: Get.height * 0.015,
                        horizontal: Get.width * 0.018),
                    child: ListTile(
                        onTap: () {
                          var lat = double.tryParse(latStr) ?? 0.0;
                          var long = double.tryParse(longStr) ?? 0.0;
                          Get.to(() => SelectResponder(
                              userLat: lat,
                              userLong: long,
                              userAddress: address,
                              userID: videoId));
                        },
                        tileColor: Color(color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Text(
                          address,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        subtitle: Text(
                          time,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.location_on,
                                  color: Colors.amberAccent, size: 25),
                              onPressed: () async {
                                String url = '';
                                String urlAppleMaps = '';
                                if (Platform.isAndroid) {
                                  url =
                                      'https://www.google.com/maps/search/?api=1&query=$latStr,$longStr';
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                } else {
                                  urlAppleMaps =
                                      'https://maps.apple.com/?q=$latStr,$longStr';
                                  url =
                                      'comgooglemaps://?saddr=&daddr=$latStr,$longStr&directionsmode=driving';
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else if (await canLaunchUrl(
                                      Uri.parse(urlAppleMaps))) {
                                    await launchUrl(Uri.parse(urlAppleMaps));
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.video_call,
                                  color: Colors.red, size: 25),
                              onPressed: () {
                                Get.to(
                                  () => LiveStreamingPage(
                                    liveId: videoId,
                                    isHost: false,
                                  ),
                                );
                              },
                            ),
                          ],
                        )),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
