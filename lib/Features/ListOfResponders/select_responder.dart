import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    _respondersFuture = dbHelper.getActiveResponders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Row(
              children: [
                const SizedBox(width: 30),
                Center(
                  child: SizedBox.fromSize(
                    size: const Size(36, 36),
                    child: ClipOval(
                      child: Material(
                        color: Color(color),
                        child: InkWell(
                          splashColor: Colors.white,
                          onTap: () {
                            Get.back();
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.arrow_back,
                                  color: Colors.white, size: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        image: const AssetImage(
                            "assets/logos/emergencyAppLogo.png"),
                        height: Get.height * 0.08),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Responders",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _respondersFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 55),
                  SizedBox(height: 16),
                  Text(
                    "No Active Responders Available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Responders must turn their status ON to appear here.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
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

              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: ListTile(
                  tileColor: Color(color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(
                    "$responderName ($responderType)",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  subtitle: Text(
                    "Distance from user: ${dist.toStringAsFixed(2)} km",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.assignment_turned_in_outlined,
                        color: Colors.greenAccent, size: 30),
                    onPressed: () {
                      Get.snackbar("Assigned",
                          'This Emergency has been assigned to $responderName');
                      Get.off(() => const EmergenciesScreen());
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
