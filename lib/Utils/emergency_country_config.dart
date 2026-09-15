import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyCountry {
  final String id;
  final String name;
  final String flag;
  final String dialCode;
  final String policeNumber;
  final String ambulanceNumber;
  final String fireNumber;
  final String hospitalNumber;
  final String phonePlaceholder;

  const EmergencyCountry({
    required this.id,
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.policeNumber,
    required this.ambulanceNumber,
    required this.fireNumber,
    required this.hospitalNumber,
    required this.phonePlaceholder,
  });

  String get placeholder => phonePlaceholder;
}

class EmergencyCountryConfig extends GetxController {
  static EmergencyCountryConfig get instance => Get.isRegistered<EmergencyCountryConfig>()
      ? Get.find<EmergencyCountryConfig>()
      : Get.put(EmergencyCountryConfig());

  static const List<EmergencyCountry> supportedCountries = [
    EmergencyCountry(
      id: 'AU',
      name: 'Australia',
      flag: '🇦🇺',
      dialCode: '+61',
      policeNumber: '000',
      ambulanceNumber: '000',
      fireNumber: '000',
      hospitalNumber: '000',
      phonePlaceholder: '0412 345 678 or +61 412 345 678',
    ),
    EmergencyCountry(
      id: 'PK',
      name: 'Pakistan',
      flag: '🇵🇰',
      dialCode: '+92',
      policeNumber: '15',
      ambulanceNumber: '1122',
      fireNumber: '16',
      hospitalNumber: '1122',
      phonePlaceholder: '0300 1234567 or +92 300 1234567',
    ),
    EmergencyCountry(
      id: 'US',
      name: 'United States & Canada',
      flag: '🇺🇸',
      dialCode: '+1',
      policeNumber: '911',
      ambulanceNumber: '911',
      fireNumber: '911',
      hospitalNumber: '911',
      phonePlaceholder: '555-123-4567 or +1 555-123-4567',
    ),
    EmergencyCountry(
      id: 'UK',
      name: 'United Kingdom',
      flag: '🇬🇧',
      dialCode: '+44',
      policeNumber: '999',
      ambulanceNumber: '999',
      fireNumber: '999',
      hospitalNumber: '999',
      phonePlaceholder: '07123 456789 or +44 7123 456789',
    ),
    EmergencyCountry(
      id: 'INT',
      name: 'Worldwide / Europe',
      flag: '🌐',
      dialCode: '',
      policeNumber: '112',
      ambulanceNumber: '112',
      fireNumber: '112',
      hospitalNumber: '112',
      phonePlaceholder: 'Enter international number',
    ),
  ];

  final Rx<EmergencyCountry> currentCountry = supportedCountries[0].obs; // Default to Australia

  @override
  void onInit() {
    super.onInit();
    loadCountryPreference();
  }

  Future<void> loadCountryPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('emergency_country_id') ?? 'AU';
      final match = supportedCountries.firstWhere(
        (c) => c.id == savedId,
        orElse: () => supportedCountries[0],
      );
      currentCountry.value = match;
    } catch (e) {
      debugPrint("Error loading emergency country: $e");
    }
  }

  Future<void> setCountry(EmergencyCountry country) async {
    currentCountry.value = country;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emergency_country_id', country.id);
    } catch (e) {
      debugPrint("Error saving emergency country: $e");
    }
  }

  String get policeNumber => currentCountry.value.policeNumber;
  String get ambulanceNumber => currentCountry.value.ambulanceNumber;
  String get fireNumber => currentCountry.value.fireNumber;
  String get hospitalNumber => currentCountry.value.hospitalNumber;
  String get dialCode => currentCountry.value.dialCode;
  String get countryName => currentCountry.value.name;
  String get countryFlag => currentCountry.value.flag;
  String get placeholder => currentCountry.value.phonePlaceholder;
}
