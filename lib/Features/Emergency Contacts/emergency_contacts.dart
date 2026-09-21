import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Common Widgets/constants.dart';
import 'add_contacts.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  late String _contact1 = '';
  late String _contact2 = '';
  late String _contact3 = '';
  late String _contact4 = '';
  late String _contact5 = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _contact1 = prefs.getString('contact1') ?? '';
      _contact2 = prefs.getString('contact2') ?? '';
      _contact3 = prefs.getString('contact3') ?? '';
      _contact4 = prefs.getString('contact4') ?? '';
      _contact5 = prefs.getString('contact5') ?? '';
    });
  }

  Widget _buildContactCard(int index, String phone) {
    final bool hasPhone = phone.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
        border: Border.all(
          color: hasPhone ? AppColors.primary.withValues(alpha: 0.25) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasPhone
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasPhone ? Icons.phone_in_talk_rounded : Icons.phone_disabled_outlined,
              color: hasPhone ? AppColors.primary : Colors.grey.shade400,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency Contact $index",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasPhone ? phone : "No phone number saved",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: hasPhone ? AppColors.textDark : AppColors.textMuted,
                    fontWeight: hasPhone ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (hasPhone)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffd1fae5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Active",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff065f46),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                await Get.to(() => const add_contact());
                _loadContacts();
              },
              child: Text(
                "+ Add",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
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
        actions: [
          IconButton(
            tooltip: "Edit Contacts",
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            onPressed: () async {
              await Get.to(() => const add_contact());
              _loadContacts();
            },
          ),
          const SizedBox(width: 4),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "These contacts will receive immediate SMS alerts with your GPS location when you press SOS.",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildContactCard(1, _contact1),
          _buildContactCard(2, _contact2),
          _buildContactCard(3, _contact3),
          _buildContactCard(4, _contact4),
          _buildContactCard(5, _contact5),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await Get.to(() => const add_contact());
              _loadContacts();
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              "Update Phone Numbers",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
