import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(color),
        foregroundColor: Colors.white,
        shape: const StadiumBorder(
            side: BorderSide(color: Colors.white24, width: 4)),
        onPressed: () {
          Get.to(() => const ProfileScreen());
        },
        child: const Icon(Icons.person),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
          preferredSize: Size.fromHeight(Get.height * 0.16),
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
                        height: Get.height * 0.07),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Responder Dashboard",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlidingSwitch(
                        value: _switchValue,
                        width: 110.0,
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
                        height: 40.0,
                        textOff: 'OFF',
                        textOn: 'ON',
                        colorOn: Colors.green,
                        colorOff: Colors.red,
                        onSwipe: () {},
                        onTap: () {},
                        onDoubleTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
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
              return Center(
                child: ListView(
                  shrinkWrap: true,
                  children: const [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 55),
                    SizedBox(height: 16),
                    Text(
                      "No Emergency Requests Yet",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Pull down to refresh",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final latestEmergency = emergencies.first;
            final userAddress = latestEmergency['address']?.toString() ??
                'No Emergency Location';
            final userLatStr = latestEmergency['lat']?.toString() ?? '';
            final userLongStr = latestEmergency['long']?.toString() ?? '';
            final videoId = latestEmergency['videoId']?.toString() ?? '';

            double? uLat = double.tryParse(userLatStr);
            double? uLong = double.tryParse(userLongStr);

            String distanceText = '';
            if (currentPosition != null && uLat != null && uLong != null) {
              double dist = calculateDistance(
                  uLat, uLong, currentPosition!.latitude, currentPosition!.longitude);
              distanceText = 'Distance: ${dist.toStringAsFixed(2)} km';
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
              child: ListTile(
                onTap: () async {
                  if (uLat == null || uLong == null) {
                    Get.snackbar('Error', 'No Emergency Location Found');
                    return;
                  }
                  String url = '';
                  String urlAppleMaps = '';
                  if (Platform.isAndroid) {
                    url =
                        'https://www.google.com/maps/search/?api=1&query=$uLat,$uLong';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  } else {
                    urlAppleMaps = 'https://maps.apple.com/?q=$uLat,$uLong';
                    if (await canLaunchUrl(Uri.parse(urlAppleMaps))) {
                      await launchUrl(Uri.parse(urlAppleMaps));
                    }
                  }
                },
                tileColor: Color(color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text(
                  userAddress,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                subtitle: distanceText.isNotEmpty
                    ? Text(
                        distanceText,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.video_call,
                      color: Colors.red, size: 30),
                  onPressed: () {
                    if (videoId.isEmpty) {
                      Get.snackbar('Error', 'No Live Stream Available');
                      return;
                    }
                    Get.to(
                      () => LiveStreamingPage(
                        liveId: videoId,
                        isHost: false,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
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
