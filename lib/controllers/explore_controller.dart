import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../services/app_data_service.dart';

enum TaskSortOption { featured, highestPoints, expiringSoon }

class ExploreController extends GetxController {
  final appData = AppDataService.instance;

  final searchController = TextEditingController();
  final RxString selectedCategoryId = 'all'.obs;
  final Rx<TaskSortOption> sortOption = TaskSortOption.featured.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isRefreshing = false.obs;

  List<CategoryModel> get categories => CategoryModel.defaultCategories;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
  }

  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  void setSortOption(TaskSortOption option) {
    sortOption.value = option;
  }

  List<TaskModel> get filteredTasks {
    List<TaskModel> tasks = List.from(appData.allTasks);

    // Filter out expired or non-active tasks
    tasks = tasks.where((t) => t.status == 'active' && !t.isExpired).toList();

    // Filter by Category
    if (selectedCategoryId.value != 'all') {
      final category = categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);
      if (category != null) {
        tasks = tasks.where((t) =>
            t.category.toLowerCase().contains(category.name.toLowerCase()) ||
            category.name.toLowerCase().contains(t.category.toLowerCase())).toList();
      }
    }

    // Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      tasks = tasks.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q)).toList();
    }

    // Sort
    switch (sortOption.value) {
      case TaskSortOption.highestPoints:
        tasks.sort((a, b) => b.pointsReward.compareTo(a.pointsReward));
        break;
      case TaskSortOption.expiringSoon:
        tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case TaskSortOption.featured:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return tasks;
  }

  Future<void> refreshTasks() async {
    isRefreshing.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isRefreshing.value = false;
  }
}
