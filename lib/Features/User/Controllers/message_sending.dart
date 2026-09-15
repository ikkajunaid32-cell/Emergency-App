import 'dart:io';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:public_emergency_app/Utils/phone_validator.dart';
import '../../Emergency Contacts/emergency_contacts_controller.dart';

class messageController extends GetxController {
  static messageController get instance => Get.find();
  final emergencyContactsController = Get.put(EmergencyContactsController());

  String? _currentAddress;
  Position? _currentPosition;
  void _sendSMS(String message, List<String> recipents) async {
    final cleanRecipients = recipents
        .map((p) => PhoneValidator.normalize(p))
        .where((p) => p.isNotEmpty)
        .toList();

    if (cleanRecipients.isEmpty) {
      Get.snackbar("SMS", "No emergency contacts found to send SMS");
      return;
    }

    if (Platform.isAndroid) {
      try {
        for (var i = 0; i < cleanRecipients.length; i++) {
          await BackgroundSms.sendMessage(
            phoneNumber: cleanRecipients[i],
            message: message,
          );
        }
        Get.snackbar("SMS", "Distress SMS Sent Successfully");
      } catch (e) {
        debugPrint("Background SMS failed, falling back to SMS app: $e");
        _launchSmsFallback(message, cleanRecipients);
      }
    } else {
      // iOS or other platforms where silent background SMS is not allowed
      _launchSmsFallback(message, cleanRecipients);
    }
  }

  void _launchSmsFallback(String message, List<String> recipients) async {
    final String separator = Platform.isIOS ? '&' : '?';
    final String phoneNumbers = recipients.join(',');
    final Uri smsUri = Uri.parse(
      'sms:$phoneNumbers${separator}body=${Uri.encodeComponent(message)}',
    );
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        Get.snackbar("SMS", "Could not open SMS application.");
      }
    } catch (e) {
      debugPrint("Error launching SMS: $e");
      Get.snackbar("SMS", "Failed to launch SMS app: $e");
    }
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Disabled",
          'Location services are disabled. Please enable the services');
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Rejected", 'Location Permissions are denied.');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Rejected",
          'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    return true;
  }

  handleSmsPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.sms.request();
      if (status.isGranted) {
        debugPrint("SMS Permission Granted");
        return true;
      } else {
        debugPrint("SMS Permission Denied");
        return false;
      }
    }
    return true;
  }

  Future<Position> getCurrentPosition() async {
    // final hasSmsPermission = handleSmsPermission();

    final hasPermission = await handleLocationPermission();

    if (!hasPermission) {
      return Position(
          latitude: 0,
          longitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0);
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentPosition = position;
      await _getAddressFromLatLng(_currentPosition!);
      return _currentPosition!;
    } catch (e) {
      debugPrint(e.toString());
      return Position(
          latitude: 0,
          longitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      _currentAddress =
          '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> sendLocationViaSMS(String EmergencyType) async {
    await getCurrentPosition().then((_currentAddress) async {
      if (_currentAddress != null) {
        // Get.snackbar("Location", _currentAddress!);
        // final Uri smsLaunchUri = Uri(
        //   scheme: 'sms',
        //   path: '03177674726',
        //   queryParameters: <String, String>{
        //     'body': "HELP me! I am under the water \n http://www.google.com/maps/place/${_currentPosition!.latitude},${_currentPosition!.longitude}"
        //   },
        // );
        // launchUrl(smsLaunchUri);
        // Get.snackbar("Location",
        //     "$_currentPosition.latitude, $_currentPosition.longitude ");
        String message =
            "HELP me! There is an $EmergencyType \n http://www.google.com/maps/place/${_currentPosition!.latitude},${_currentPosition!.longitude}}";
        await emergencyContactsController
            .loadData()
            .then((emergencyContacts) => _sendSMS(message, emergencyContacts));
      } else {}
    });

    // Get.snackbar("Location", "Location not found");
  }
}
