import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_emergency_app/Common%20Widgets/constants.dart';
import 'package:public_emergency_app/Utils/emergency_country_config.dart';
import 'package:public_emergency_app/Utils/phone_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'emergency_contacts_controller.dart';

class add_contact extends StatefulWidget {
  const add_contact({Key? key}) : super(key: key);

  @override
  State<add_contact> createState() => _AddContactState();
}

class _AddContactState extends State<add_contact> {
  final contactController = Get.put(EmergencyContactsController());
  final countryConfig = EmergencyCountryConfig.instance;
  final _formKey = GlobalKey<FormState>();

  final contact1controller = TextEditingController();
  final contact2controller = TextEditingController();
  final contact3controller = TextEditingController();
  final contact4controller = TextEditingController();
  final contact5controller = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      contact1controller.text = prefs.getString('contact1') ?? '';
      contact2controller.text = prefs.getString('contact2') ?? '';
      contact3controller.text = prefs.getString('contact3') ?? '';
      contact4controller.text = prefs.getString('contact4') ?? '';
      contact5controller.text = prefs.getString('contact5') ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contact1', PhoneValidator.normalize(contact1controller.text.trim()));
    await prefs.setString('contact2', PhoneValidator.normalize(contact2controller.text.trim()));
    await prefs.setString('contact3', PhoneValidator.normalize(contact3controller.text.trim()));
    await prefs.setString('contact4', PhoneValidator.normalize(contact4controller.text.trim()));
    await prefs.setString('contact5', PhoneValidator.normalize(contact5controller.text.trim()));

    await contactController.loadData();

    Get.snackbar(
      "Saved Successfully",
      "Emergency contacts updated for instant distress alerts",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    contact1controller.dispose();
    contact2controller.dispose();
    contact3controller.dispose();
    contact4controller.dispose();
    contact5controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Emergency Contacts",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.blue.shade700, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Distress SMS Recipients",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "When you trigger SOS, an immediate SMS with your live GPS location link will be sent to these contacts.",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Country format hint
                    Obx(() {
                      final c = countryConfig.currentCountry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Text(c.flag, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Supported format: ${c.placeholder} or any international number",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    _buildContactCard(
                      index: 1,
                      label: "Primary Emergency Contact *",
                      controller: contact1controller,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 14),
                    _buildContactCard(
                      index: 2,
                      label: "Emergency Contact 2",
                      controller: contact2controller,
                    ),
                    const SizedBox(height: 14),
                    _buildContactCard(
                      index: 3,
                      label: "Emergency Contact 3",
                      controller: contact3controller,
                    ),
                    const SizedBox(height: 14),
                    _buildContactCard(
                      index: 4,
                      label: "Emergency Contact 4",
                      controller: contact4controller,
                    ),
                    const SizedBox(height: 14),
                    _buildContactCard(
                      index: 5,
                      label: "Emergency Contact 5",
                      controller: contact5controller,
                    ),

                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveContacts();
                          }
                        },
                        child: Text(
                          "SAVE CONTACTS",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContactCard({
    required int index,
    required String label,
    required TextEditingController controller,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
        border: Border.all(
          color: isPrimary ? AppColors.primaryLight.withValues(alpha: 0.4) : Colors.grey.shade100,
          width: isPrimary ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isPrimary ? AppColors.primaryLight : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$index",
                  style: GoogleFonts.poppins(
                    color: isPrimary ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isPrimary ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                if (!PhoneValidator.isValid(val)) {
                  return 'Invalid format. E.g. 0412 345 678 or +61 412 345 678';
                }
              }
              return null;
            },
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primaryLight, size: 20),
              hintText: "Enter phone number (e.g. 0412 345 678)",
              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
