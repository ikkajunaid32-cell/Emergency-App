import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/task_detail_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';

class TaskDetailView extends StatelessWidget {
  final TaskModel task;

  const TaskDetailView({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(TaskDetailController(task: task), tag: task.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Full-bleed Header Image
          SliverAppBar(
            expandedHeight: 260.0,
            pinned: true,
            backgroundColor: AppTheme.secondary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.pointsBadgeGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      "+${task.pointsReward} PTS",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: task.bannerUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            task.category.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Task Details & Requirements Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deadline Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Color(0xFFD97706), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MISSION DEADLINE",
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                              Text(
                                "Must be completed and submitted within ${task.formattedRemainingTime}",
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: const Color(0xFF92400E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Overview Description
                  Text(
                    "Task Overview",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Instructions Card
                  Container(
                    width: double.infinity,
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
                        Row(
                          children: [
                            const Icon(Icons.format_list_bulleted_rounded,
                                color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Administrator Instructions",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: AppTheme.border),
                        Text(
                          task.detailedInstructions,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: AppTheme.textDark,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submission Section Header
                  Text(
                    "Submission & Evidence",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Upload the required proof for administrator review to receive +${task.pointsReward} points.",
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Submission Inputs
                  GetBuilder<TaskDetailController>(
                    tag: task.id,
                    builder: (ctrl) {
                      if (!ctrl.isTaskStarted) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(Icons.play_circle_fill_rounded,
                                    size: 64, color: AppTheme.primary.withValues(alpha: 0.8)),
                                const SizedBox(height: 12),
                                Text(
                                  "Ready to start this daily task?",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Tap below to begin and unlock submission fields.",
                                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: ctrl.startTask,
                                    icon: const Icon(Icons.flag_rounded),
                                    label: Text(
                                      "START TASK NOW",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Task is started -> Show required submission widgets
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Text Requirement Input
                          if (task.requiresText) ...[
                            _buildInputHeader(Icons.notes_rounded, "Written Response / Notes",
                                isRequired: true),
                            const SizedBox(height: 6),
                            TextField(
                              controller: ctrl.textResponseController,
                              maxLines: 3,
                              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark),
                              decoration: InputDecoration(
                                hintText: "Describe your activity, takeaways or key details...",
                                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppTheme.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppTheme.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 2. Photo Evidence Input
                          if (task.requiresPhoto) ...[
                            _buildInputHeader(Icons.camera_alt_outlined, "Photo Evidence",
                                isRequired: true),
                            const SizedBox(height: 8),
                            Obx(() => Column(
                                  children: [
                                    if (ctrl.selectedPhotos.isNotEmpty)
                                      SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: ctrl.selectedPhotos.length,
                                          itemBuilder: (context, idx) {
                                            final path = ctrl.selectedPhotos[idx];
                                            return Stack(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(right: 10),
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(14),
                                                    image: DecorationImage(
                                                      image: FileImage(File(path)),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 4,
                                                  right: 14,
                                                  child: InkWell(
                                                    onTap: () => ctrl.removePhoto(idx),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.black87,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.close,
                                                          color: Colors.white, size: 14),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => ctrl.pickPhoto(ImageSource.camera),
                                            icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                            label: const Text("Take Photo"),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppTheme.primary,
                                              side: const BorderSide(color: AppTheme.primary),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => ctrl.pickPhoto(ImageSource.gallery),
                                            icon: const Icon(Icons.photo_library_rounded, size: 18),
                                            label: const Text("Gallery"),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppTheme.textDark,
                                              side: const BorderSide(color: AppTheme.border),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            const SizedBox(height: 16),
                          ],

                          // 3. Video Evidence Input
                          if (task.requiresVideo) ...[
                            _buildInputHeader(Icons.videocam_outlined, "Video Clip Proof",
                                isRequired: true),
                            const SizedBox(height: 8),
                            Obx(() {
                              final video = ctrl.selectedVideo.value;
                              return video != null
                                  ? Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppTheme.accentGreen),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.video_file_rounded,
                                              color: AppTheme.accentGreen, size: 28),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              "Video Recorded (${video.split(Platform.pathSeparator).last})",
                                              style: GoogleFonts.inter(
                                                  fontSize: 13, fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: ctrl.removeVideo,
                                          ),
                                        ],
                                      ),
                                    )
                                  : OutlinedButton.icon(
                                      onPressed: () => ctrl.pickVideo(ImageSource.camera),
                                      icon: const Icon(Icons.videocam_rounded),
                                      label: const Text("Record or Select Video Clip"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.accentPurple,
                                        side: const BorderSide(color: AppTheme.accentPurple),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    );
                            }),
                            const SizedBox(height: 16),
                          ],

                          // 4. File Attachment Input
                          if (task.requiresFile) ...[
                            _buildInputHeader(Icons.attach_file_rounded, "Attach Documents / Files",
                                isRequired: true),
                            const SizedBox(height: 8),
                            Obx(() => Column(
                                  children: [
                                    ...ctrl.selectedFiles.map((f) => Container(
                                          margin: const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppTheme.border),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.description_outlined,
                                                  color: AppTheme.primary, size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  f.split(Platform.pathSeparator).last,
                                                  style: GoogleFonts.inter(fontSize: 12),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => ctrl.removeFile(ctrl.selectedFiles.indexOf(f)),
                                                child: const Icon(Icons.close, size: 16),
                                              ),
                                            ],
                                          ),
                                        )),
                                    OutlinedButton.icon(
                                      onPressed: ctrl.pickFiles,
                                      icon: const Icon(Icons.upload_file_rounded),
                                      label: const Text("Attach File (PDF, DOC, ZIP)"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.textDark,
                                        side: const BorderSide(color: AppTheme.border),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(height: 16),
                          ],

                          // 5. Location Verification Input
                          if (task.requiresLocation) ...[
                            _buildInputHeader(Icons.location_on_outlined, "Location Verification",
                                isRequired: true),
                            const SizedBox(height: 8),
                            Obx(() {
                              final address = ctrl.currentAddress.value;
                              final isLocating = ctrl.isFetchingLocation.value;

                              if (isLocating) {
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text("Acquiring high-accuracy GPS coordinates..."),
                                    ],
                                  ),
                                );
                              }

                              if (address.isNotEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.accentGreen),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppTheme.accentGreen, size: 22),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "GPS Verified",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF047857),
                                              ),
                                            ),
                                            Text(
                                              address,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: ctrl.captureLocation,
                                        child: const Text("Re-check"),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ElevatedButton.icon(
                                onPressed: ctrl.captureLocation,
                                icon: const Icon(Icons.my_location_rounded, color: Colors.white),
                                label: const Text("Verify Current GPS Location"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                          ],

                          // Submit Action Button
                          Obx(() => SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: ctrl.isSubmitting.value ? null : ctrl.submitTask,
                                  child: ctrl.isSubmitting.value
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.send_rounded, size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              "SUBMIT TASK FOR APPROVAL",
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              )),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputHeader(IconData icon, String title, {bool isRequired = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        if (isRequired)
          Text(
            " *",
            style: GoogleFonts.inter(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}
