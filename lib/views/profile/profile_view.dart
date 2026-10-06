import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../services/app_data_service.dart';
import '../admin_mobile/admin_mobile_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appData = AppDataService.instance;
    final authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Profile & Settings",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // User Card
            Obx(() {
              final user = appData.currentUser.value;
              final name = user?.name ?? "Citizen User";
              final email = user?.email ?? "citizen@eatclubtasks.com";
              final phone = user?.phone ?? "0412 345 678";
              final role = user?.role ?? "user";
              final isAdmin = user?.isAdmin ?? false;

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppTheme.cardShadow,
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: AppTheme.primaryLight,
                          backgroundImage: user?.avatarUrl != null
                              ? CachedNetworkImageProvider(user!.avatarUrl!)
                              : null,
                          child: user?.avatarUrl == null
                              ? const Icon(Icons.person_rounded, size: 36, color: AppTheme.primary)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? AppTheme.accentPurple.withValues(alpha: 0.12)
                                          : AppTheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      role.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isAdmin ? AppTheme.accentPurple : AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                email,
                                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                phone,
                                style: GoogleFonts.inter(fontSize: 12.5, color: AppTheme.textLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppTheme.border),

                    // 3 KPI Badges Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          "${user?.points ?? 0}",
                          "Points Wallet",
                          Icons.stars_rounded,
                          Colors.amber.shade700,
                        ),
                        _buildStatColumn(
                          "${appData.myCompletedSubmissions.length}",
                          "Completed",
                          Icons.check_circle_rounded,
                          AppTheme.accentGreen,
                        ),
                        _buildStatColumn(
                          "${appData.myPendingSubmissions.length}",
                          "Pending",
                          Icons.hourglass_top_rounded,
                          AppTheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 18),

            // Admin Console Shortcut (if admin)
            Obx(() {
              final isAdmin = appData.currentUser.value?.isAdmin ?? false;
              if (!isAdmin) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Admin Command Center",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Review submissions, create tasks & manage rewards",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.accentPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {
                        Get.to(() => const AdminMobileView());
                      },
                      child: Text(
                        "Open",
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Role Switcher Tile for Easy Testing
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, color: AppTheme.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quick Role Switcher (Testing)",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          "Toggle between Citizen & Admin view in 1 tap",
                          style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    final role = appData.currentUser.value?.role ?? 'user';
                    return SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'user', label: Text('User')),
                        ButtonSegment(value: 'admin', label: Text('Admin')),
                      ],
                      selected: {role},
                      onSelectionChanged: (newVal) {
                        appData.switchDemoRole(newVal.first);
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Settings Options
            _buildSettingsTile(
              icon: Icons.notifications_active_outlined,
              title: "Push Notifications",
              subtitle: "Alerts for new daily tasks, approvals & deadlines",
              trailing: Switch(
                value: true,
                activeThumbColor: AppTheme.primary,
                onChanged: (val) {},
              ),
            ),
            _buildSettingsTile(
              icon: Icons.history_rounded,
              title: "Points Transaction Ledger",
              subtitle: "View complete earning & spending history",
              onTap: () => _showPointsHistoryModal(context),
            ),
            _buildSettingsTile(
              icon: Icons.shield_outlined,
              title: "Privacy & Terms of Service",
              subtitle: "Read our community standards & data policy",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: authController.logout,
                icon: const Icon(Icons.logout_rounded, color: AppTheme.danger, size: 18),
                label: Text(
                  "SIGN OUT",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.danger,
                    letterSpacing: 0.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceSubtle,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
        ),
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textLight),
      ),
    );
  }

  void _showPointsHistoryModal(BuildContext context) {
    final appData = AppDataService.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Points Transaction Ledger",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final txs = appData.pointTransactions;
                  if (txs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("No transactions recorded yet.")),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: txs.length,
                      itemBuilder: (context, index) {
                        final tx = txs[index];
                        final isEarned = tx.isEarned;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isEarned ? const Color(0xFFECFDF5) : Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isEarned ? Icons.add_rounded : Icons.remove_rounded,
                              color: isEarned ? AppTheme.accentGreen : AppTheme.danger,
                            ),
                          ),
                          title: Text(tx.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text(tx.description, style: GoogleFonts.inter(fontSize: 12)),
                          trailing: Text(
                            "${isEarned ? '+' : '-'}${tx.amount} PTS",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: isEarned ? AppTheme.accentGreen : AppTheme.danger,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
