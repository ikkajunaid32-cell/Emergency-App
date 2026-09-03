import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyMaps extends StatefulWidget {
  final double latitude;
  final double longitude;

  const EmergencyMaps({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<EmergencyMaps> createState() => _EmergencyMapsState();
}

class _EmergencyMapsState extends State<EmergencyMaps> {
  late Marker userMarker;
  final Completer<GoogleMapController> _controller = Completer();
  late CameraPosition initialCameraPosition;

  @override
  void initState() {
    super.initState();
    userMarker = Marker(
      markerId: const MarkerId("User"),
      position: LatLng(widget.latitude, widget.longitude),
      onTap: () {
        Get.snackbar("User", "User is here");
      },
    );
    initialCameraPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 14.4746,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      compassEnabled: true,
      markers: {userMarker},
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
    );
  }
}
