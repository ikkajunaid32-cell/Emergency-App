import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneCaller {
  /// Launches the system phone dialer with [number] prepopulated.
  /// Uses ACTION_DIAL which does not require dangerous runtime phone state permissions,
  /// ensuring emergency calls are never blocked by permission denials.
  static Future<void> call(String number) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanNumber.isEmpty) {
      Get.snackbar("Error", "No valid phone number specified");
      return;
    }

    final Uri uri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      // 1. First attempt: Launch dialer directly using external application mode.
      // ACTION_DIAL is universally supported and does not require runtime CALL_PHONE permission.
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      // 2. Fallback attempt without external application mode
      final launched = await launchUrl(uri);
      if (launched) return;
    } catch (e) {
      debugPrint("PhoneCaller: Direct launch exception: $e");
    }

    // 3. Graceful fallback: If direct dial failed, check/request Permission.phone
    // to handle devices that strictly enforce direct call permissions.
    try {
      final status = await Permission.phone.status;
      if (!status.isGranted) {
        await Permission.phone.request();
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (e) {
      debugPrint("PhoneCaller: Permission request exception: $e");
    }

    // 4. If all automated attempts fail, inform user with a clean notification
    Get.snackbar(
      "Dialing Error",
      "Could not open phone dialer for $number. Please dial manually.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }
}
