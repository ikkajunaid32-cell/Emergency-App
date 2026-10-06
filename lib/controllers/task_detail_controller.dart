import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/task_model.dart';
import '../services/app_data_service.dart';

class TaskDetailController extends GetxController {
  final TaskModel task;
  TaskDetailController({required this.task});

  final appData = AppDataService.instance;
  final picker = ImagePicker();

  // Form Fields
  final textResponseController = TextEditingController();
  final RxList<String> selectedPhotos = <String>[].obs;
  final Rx<String?> selectedVideo = Rx<String?>(null);
  final RxList<String> selectedFiles = <String>[].obs;
  
  // GPS Location Fields
  final RxBool isFetchingLocation = false.obs;
  final Rx<double?> currentLat = Rx<double?>(null);
  final Rx<double?> currentLng = Rx<double?>(null);
  final RxString currentAddress = ''.obs;

  final RxBool isSubmitting = false.obs;

  bool get isTaskStarted => appData.isTaskStarted(task.id);

  void startTask() {
    appData.startTask(task.id);
    update();
    Get.snackbar(
      "Task Started!",
      "Complete the required activities below and submit your evidence.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // --- Photo Pickers ---
  Future<void> pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (image != null) {
        selectedPhotos.add(image.path);
      }
    } catch (e) {
      Get.snackbar("Photo Picker Error", "Could not capture or pick image: $e");
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
    }
  }

  // --- Video Picker ---
  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 2),
      );
      if (video != null) {
        selectedVideo.value = video.path;
      }
    } catch (e) {
      Get.snackbar("Video Picker Error", "Could not capture or pick video: $e");
    }
  }

  void removeVideo() {
    selectedVideo.value = null;
  }

  // --- File Picker ---
  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'zip'],
      );
      if (result != null) {
        selectedFiles.addAll(result.paths.whereType<String>());
      }
    } catch (e) {
      Get.snackbar("File Picker Error", "Could not pick files: $e");
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
    }
  }

  // --- GPS Location Capture ---
  Future<void> captureLocation() async {
    isFetchingLocation.value = true;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permission Denied", "Location permission is required for this task.");
          isFetchingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("Location Blocked", "Please enable location permission in app settings.");
        openAppSettings();
        isFetchingLocation.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLat.value = position.latitude;
      currentLng.value = position.longitude;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          currentAddress.value = "${p.street ?? ''}, ${p.subLocality ?? p.locality ?? ''}, ${p.postalCode ?? ''}";
        } else {
          currentAddress.value = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
        }
      } catch (_) {
        currentAddress.value = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
      }

      Get.snackbar(
        "Location Verified!",
        "GPS coordinates captured successfully: ${currentAddress.value}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Location Error", "Could not acquire GPS: $e");
    } finally {
      isFetchingLocation.value = false;
    }
  }

  // --- Validation & Submit ---
  Future<bool> submitTask() async {
    // 1. Validate requirements
    if (task.requiresText && textResponseController.text.trim().isEmpty) {
      Get.snackbar(
        "Text Required",
        "Please provide a written response or summary for this task.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    if (task.requiresPhoto && selectedPhotos.isEmpty) {
      Get.snackbar(
        "Photo Required",
        "Please capture or upload at least one photo as evidence.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    if (task.requiresVideo && selectedVideo.value == null) {
      Get.snackbar(
        "Video Required",
        "Please record or upload a video clip as required by this task.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    if (task.requiresFile && selectedFiles.isEmpty) {
      Get.snackbar(
        "File Required",
        "Please attach the required document or file.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    if (task.requiresLocation && currentLat.value == null) {
      Get.snackbar(
        "Location Verification Required",
        "Please tap 'Verify GPS Location' to capture your coordinates.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    isSubmitting.value = true;

    // Use default sample banner if photo is not accessible online
    List<String> finalPhotos = selectedPhotos.isNotEmpty
        ? selectedPhotos.toList()
        : [task.bannerUrl];

    final success = await appData.submitTask(
      task: task,
      textResponse: textResponseController.text.trim(),
      photoUrls: finalPhotos,
      videoUrl: selectedVideo.value,
      fileUrls: selectedFiles.toList(),
      latitude: currentLat.value,
      longitude: currentLng.value,
      address: currentAddress.value.isNotEmpty ? currentAddress.value : null,
    );

    isSubmitting.value = false;

    if (success) {
      Get.back(); // Close detail view
      Get.snackbar(
        "Submission Received!",
        "Your submission is now Pending Review by an administrator. Points will be awarded upon approval!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return true;
    } else {
      Get.snackbar("Error", "Could not submit task. Please try again.");
      return false;
    }
  }
}
