import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../models/category_model.dart';
import '../../models/submission_model.dart';
import '../../models/task_model.dart';
import '../../services/app_data_service.dart';

class AdminMobileView extends StatefulWidget {
  const AdminMobileView({Key? key}) : super(key: key);

  @override
  State<AdminMobileView> createState() => _AdminMobileViewState();
}

class _AdminMobileViewState extends State<AdminMobileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final appData = AppDataService.instance;

  // New Task Form State
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _pointsController = TextEditingController(text: "150");
  final _bannerController = TextEditingController(
      text: "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800");
  String _selectedCategory = 'Community';
  int _deadlineHours = 24;
  bool _reqText = true;
  bool _reqPhoto = true;
  bool _reqVideo = false;
  bool _reqFile = false;
  bool _reqLocation = false;
  final bool _isRecurring = false;
  final String _recurrence = 'daily';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Admin Command Center",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: [
            Obx(() => Tab(
                  text: "Review (${appData.allPendingSubmissionsForAdmin.length})",
                )),
            const Tab(text: "Create Task"),
            const Tab(text: "Overview"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewQueueTab(),
          _buildCreateTaskTab(),
          _buildOverviewTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: REVIEW QUEUE
  // ==========================================
  Widget _buildReviewQueueTab() {
    return Obx(() {
      final pendingSubs = appData.allPendingSubmissionsForAdmin;
      if (pendingSubs.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt_rounded, size: 64, color: AppTheme.accentGreen),
                const SizedBox(height: 16),
                Text(
                  "All Caught Up!",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  "There are currently zero pending task submissions awaiting administrator review.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingSubs.length,
        itemBuilder: (context, index) {
          final sub = pendingSubs[index];
          return _buildSubmissionReviewCard(sub);
        },
      );
    });
  }

  Widget _buildSubmissionReviewCard(SubmissionModel sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pending_actions_rounded,
                        color: Color(0xFFD97706), size: 14),
                    const SizedBox(width: 5),
                    Text(
                      "AWAITING REVIEW",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "+${sub.pointsReward} PTS",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            sub.taskTitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Submitted by: ${sub.userName} (${sub.userEmail})",
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
          const Divider(height: 18, color: AppTheme.border),

          // Submitted Evidence Content
          if (sub.textResponse != null && sub.textResponse!.isNotEmpty) ...[
            Text(
              "Written Answer:",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                sub.textResponse!,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark),
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (sub.photoUrls.isNotEmpty) ...[
            Text(
              "Photo Evidence (${sub.photoUrls.length}):",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sub.photoUrls.length,
                itemBuilder: (context, i) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(sub.photoUrls[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (sub.locationAddress != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppTheme.accentGreen, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "GPS Verified: ${sub.locationAddress}",
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF047857)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Action Buttons: Approve or Reject
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _promptRejectionModal(sub),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.danger, size: 16),
                  label: Text(
                    "Reject",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.danger,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    appData.reviewSubmission(submissionId: sub.id, approve: true);
                    Get.snackbar(
                      "Submission Approved! 🎉",
                      "+${sub.pointsReward} points automatically awarded to ${sub.userName}.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF10B981),
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  label: Text(
                    "Approve",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _promptRejectionModal(SubmissionModel sub) {
    final reasonController = TextEditingController(text: "Evidence does not meet the specified instructions.");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Reject Submission",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please provide a specific feedback reason for ${sub.userName}:",
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Enter rejection reason...",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                appData.reviewSubmission(
                  submissionId: sub.id,
                  approve: false,
                  rejectionReason: reasonController.text.trim(),
                );
                Get.snackbar(
                  "Submission Rejected",
                  "Feedback sent to user.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.danger,
                  colorText: Colors.white,
                );
              },
              child: const Text("Confirm Rejection"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 2: CREATE TASK STUDIO
  // ==========================================
  Widget _buildCreateTaskTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Publish Daily Mission",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Text(
            "Create tasks that immediately appear on users' Explore screen.",
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleController,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              labelText: "Task Title *",
              hintText: "e.g. Park Cleanup or 10,000 Steps",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),

          // Short Description
          TextField(
            controller: _descController,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              labelText: "Short Summary / Teaser *",
              hintText: "Displayed on the Explore card preview",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),

          // Detailed Instructions
          TextField(
            controller: _instructionsController,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              labelText: "Detailed Instructions for User *",
              hintText: "Step 1...\nStep 2...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),

          // Points & Deadline Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Points Reward *",
                    hintText: "150",
                    prefixIcon: const Icon(Icons.stars_rounded, color: Colors.amber),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _deadlineHours,
                  decoration: InputDecoration(
                    labelText: "Expires In",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 8, child: Text("8 Hours")),
                    DropdownMenuItem(value: 12, child: Text("12 Hours")),
                    DropdownMenuItem(value: 24, child: Text("24 Hours (Daily)")),
                    DropdownMenuItem(value: 48, child: Text("48 Hours")),
                    DropdownMenuItem(value: 168, child: Text("1 Week")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _deadlineHours = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: "Task Category",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: CategoryModel.defaultCategories
                .where((c) => c.id != 'all')
                .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 14),

          // Banner Image URL
          TextField(
            controller: _bannerController,
            style: GoogleFonts.inter(fontSize: 13),
            decoration: InputDecoration(
              labelText: "Banner Image URL",
              hintText: "https://...",
              prefixIcon: const Icon(Icons.image_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 18),

          // Required Submission Evidence Toggles
          Text(
            "Required Submission Types:",
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            title: const Text("Require Text / Notes"),
            value: _reqText,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _reqText = v ?? true),
          ),
          CheckboxListTile(
            title: const Text("Require Photo Proof"),
            value: _reqPhoto,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _reqPhoto = v ?? true),
          ),
          CheckboxListTile(
            title: const Text("Require Video Clip Proof"),
            value: _reqVideo,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _reqVideo = v ?? false),
          ),
          CheckboxListTile(
            title: const Text("Require Document / File Upload"),
            value: _reqFile,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _reqFile = v ?? false),
          ),
          CheckboxListTile(
            title: const Text("Require GPS Location Verification"),
            value: _reqLocation,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _reqLocation = v ?? false),
          ),
          const SizedBox(height: 20),

          // Publish Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _publishTask,
              icon: const Icon(Icons.cloud_upload_rounded),
              label: Text(
                "PUBLISH TASK TO EXPLORE",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _publishTask() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final instructions = _instructionsController.text.trim();
    final points = int.tryParse(_pointsController.text.trim()) ?? 100;

    if (title.isEmpty || desc.isEmpty) {
      Get.snackbar("Missing Fields", "Please provide at least a title and summary description.");
      return;
    }

    List<SubmissionType> requirements = [];
    if (_reqText) requirements.add(SubmissionType.text);
    if (_reqPhoto) requirements.add(SubmissionType.photo);
    if (_reqVideo) requirements.add(SubmissionType.video);
    if (_reqFile) requirements.add(SubmissionType.file);
    if (_reqLocation) requirements.add(SubmissionType.location);
    if (requirements.isEmpty) requirements.add(SubmissionType.text);

    final now = DateTime.now();
    final newTask = TaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: desc,
      detailedInstructions: instructions.isNotEmpty ? instructions : desc,
      bannerUrl: _bannerController.text.trim().isNotEmpty
          ? _bannerController.text.trim()
          : "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800",
      category: _selectedCategory,
      pointsReward: points,
      requiredSubmissions: requirements,
      startDate: now,
      deadline: now.add(Duration(hours: _deadlineHours)),
      isRecurring: _isRecurring,
      recurrenceRule: _recurrence,
      createdBy: 'admin',
      createdAt: now,
    );

    appData.createOrScheduleTask(newTask);

    _titleController.clear();
    _descController.clear();
    _instructionsController.clear();

    _tabController.animateTo(0);
    Get.snackbar(
      "Task Published! 🚀",
      "'$title' is now live on the Explore section for all users.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // ==========================================
  // TAB 3: OVERVIEW & TELEMETRY
  // ==========================================
  Widget _buildOverviewTab() {
    return Obx(() {
      final totalTasks = appData.allTasks.length;
      final pendingCount = appData.allPendingSubmissionsForAdmin.length;
      final completedCount = appData.totalCompletedCount;
      final pointsAwarded = appData.totalPointsAwarded;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "System Health & KPIs",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),

            // 4 Grid KPI Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.35,
              children: [
                _buildKpiCard("Active Tasks", "$totalTasks", Icons.assignment_rounded,
                    AppTheme.primary),
                _buildKpiCard("Pending Review", "$pendingCount", Icons.pending_actions_rounded,
                    Colors.amber.shade700),
                _buildKpiCard("Completed", "$completedCount", Icons.check_circle_rounded,
                    AppTheme.accentGreen),
                _buildKpiCard("Points Awarded", "$pointsAwarded", Icons.stars_rounded,
                    AppTheme.accentPurple),
              ],
            ),
            const SizedBox(height: 24),

            // Web Dashboard Access Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.laptop_chromebook_rounded, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        "Web-Based Admin Dashboard",
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "You also have a dedicated web portal in the `admin_dashboard/` directory. Open it in any desktop browser for high-volume evidence inspection, full screen video playback, and exportable reports.",
                    style: GoogleFonts.inter(fontSize: 12.5, color: AppTheme.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
