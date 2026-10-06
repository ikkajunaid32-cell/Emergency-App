import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/explore_controller.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/task_card_eatclub.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExploreController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshTasks,
          color: AppTheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // Search & Filter Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DAILY EXPLORE",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Text(
                                "Today's Tasks",
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          // Sort Button
                          Obx(() => OutlinedButton.icon(
                                onPressed: () => _showSortModal(context, controller),
                                icon: const Icon(Icons.sort_rounded, size: 16),
                                label: Text(
                                  controller.sortOption.value == TaskSortOption.highestPoints
                                      ? "Points"
                                      : controller.sortOption.value == TaskSortOption.expiringSoon
                                          ? "Deadline"
                                          : "Featured",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.textDark,
                                  side: const BorderSide(color: AppTheme.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark),
                          decoration: InputDecoration(
                            hintText: "Search daily tasks by title or keyword...",
                            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textLight),
                            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      controller.searchController.clear();
                                    },
                                  )
                                : const SizedBox.shrink()),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Category Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Obx(() {
                          final selectedId = controller.selectedCategoryId.value;
                          return Row(
                            children: controller.categories.map((cat) {
                              final isSelected = selectedId == cat.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => controller.selectCategory(cat.id),
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primary : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? AppTheme.primary : AppTheme.border,
                                        width: 1,
                                      ),
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
                                    child: Row(
                                      children: [
                                        Icon(
                                          cat.icon,
                                          size: 15,
                                          color: isSelected ? Colors.white : AppTheme.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          cat.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            color: isSelected ? Colors.white : AppTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Task Cards List
              Obx(() {
                final tasks = controller.filteredTasks;
                if (tasks.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.assignment_late_outlined,
                              size: 48,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            "No Available Tasks Found",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try clearing your search query or choosing another category.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = tasks[index];
                        return TaskCardEatClub(task: task);
                      },
                      childCount: tasks.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortModal(BuildContext context, ExploreController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  "Sort Daily Tasks",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSortTile(
                  context,
                  title: "Featured / Recommended",
                  subtitle: "Default curated order for today",
                  option: TaskSortOption.featured,
                  controller: controller,
                ),
                _buildSortTile(
                  context,
                  title: "Highest Points Reward",
                  subtitle: "Show tasks that earn the most points first",
                  option: TaskSortOption.highestPoints,
                  controller: controller,
                ),
                _buildSortTile(
                  context,
                  title: "Expiring Soonest",
                  subtitle: "Show urgent deadlines closing today first",
                  option: TaskSortOption.expiringSoon,
                  controller: controller,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required TaskSortOption option,
    required ExploreController controller,
  }) {
    return Obx(() {
      final isSelected = controller.sortOption.value == option;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14.5,
            color: isSelected ? AppTheme.primary : AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
            : null,
        onTap: () {
          controller.setSortOption(option);
          Navigator.pop(context);
        },
      );
    });
  }
}
