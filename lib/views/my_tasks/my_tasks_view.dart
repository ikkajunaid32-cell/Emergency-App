import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../controllers/my_tasks_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/submission_model.dart';
import '../../models/task_model.dart';
import '../explore/widgets/task_card_eatclub.dart';

class MyTasksView extends StatelessWidget {
  const MyTasksView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyTasksController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "My Tasks",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          // 4 Tab Segmented Control
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Obx(() {
              final activeTab = controller.selectedTabIndex.value;
              return Row(
                children: [
                  _buildTabButton("Active", 0, activeTab, controller,
                      count: controller.activeStartedTasks.length),
                  _buildTabButton("Pending", 1, activeTab, controller,
                      count: controller.pendingSubmissions.length),
                  _buildTabButton("Completed", 2, activeTab, controller,
                      count: controller.completedSubmissions.length),
                  _buildTabButton("Rejected", 3, activeTab, controller,
                      count: controller.rejectedSubmissions.length),
                ],
              );
            }),
          ),

          // Content List
          Expanded(
            child: Obx(() {
              final tab = controller.selectedTabIndex.value;
              switch (tab) {
                case 0:
                  return _buildActiveTasksList(controller.activeStartedTasks);
                case 1:
                  return _buildSubmissionsList(
                    controller.pendingSubmissions,
                    statusType: "Pending Review",
                    emptyMessage: "No submissions currently pending review.",
                  );
                case 2:
                  return _buildSubmissionsList(
                    controller.completedSubmissions,
                    statusType: "Approved & Completed",
                    emptyMessage: "No approved tasks yet. Complete a task to earn points!",
                  );
                case 3:
                default:
                  return _buildSubmissionsList(
                    controller.rejectedSubmissions,
                    statusType: "Rejected",
                    emptyMessage: "No rejected tasks. Great job on clean submissions!",
                  );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      String label, int index, int currentTab, MyTasksController controller,
      {int count = 0}) {
    final isSelected = currentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.selectTab(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
              ),
              if (count > 0)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$count",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTasksList(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.directions_run_rounded,
        title: "No Active In-Progress Tasks",
        subtitle: "Browse the Explore tab and tap 'Start Task' on missions you want to tackle today.",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCardEatClub(task: tasks[index]);
      },
    );
  }

  Widget _buildSubmissionsList(List<SubmissionModel> submissions,
      {required String statusType, required String emptyMessage}) {
    if (submissions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_rounded,
        title: "No $statusType Tasks",
        subtitle: emptyMessage,
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy • h:mm a');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final sub = submissions[index];
        Color statusColor;
        IconData statusIcon;
        String statusLabel;

        if (sub.isApproved) {
          statusColor = AppTheme.accentGreen;
          statusIcon = Icons.check_circle_rounded;
          statusLabel = "APPROVED (+${sub.pointsReward} PTS)";
        } else if (sub.isRejected) {
          statusColor = AppTheme.danger;
          statusIcon = Icons.cancel_rounded;
          statusLabel = "REJECTED BY ADMIN";
        } else {
          statusColor = AppTheme.accentAmber;
          statusIcon = Icons.hourglass_top_rounded;
          statusLabel = "PENDING ADMIN REVIEW";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    dateFormat.format(sub.submittedAt),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Task Title
              Text(
                sub.taskTitle,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),

              // Rejection Reason Alert if rejected
              if (sub.isRejected && sub.rejectionReason != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppTheme.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ADMIN FEEDBACK / REASON:",
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sub.rejectionReason!,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: Colors.red.shade900,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Submitted Notes if present
              if (sub.textResponse != null && sub.textResponse!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "\"${sub.textResponse}\"",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],

              // Evidence tags summary
              const SizedBox(height: 12),
              Row(
                children: [
                  if (sub.photoUrls.isNotEmpty)
                    _buildEvidencePill(Icons.photo_rounded, "${sub.photoUrls.length} Photo(s)"),
                  if (sub.videoUrl != null)
                    _buildEvidencePill(Icons.videocam_rounded, "Video Clip"),
                  if (sub.locationAddress != null)
                    _buildEvidencePill(Icons.location_on_rounded, "GPS Verified"),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${sub.pointsReward} PTS",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvidencePill(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 10.5, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      {required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
