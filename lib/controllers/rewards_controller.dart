import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/reward_model.dart';
import '../services/app_data_service.dart';

class RewardsController extends GetxController {
  final appData = AppDataService.instance;
  final RxString selectedCategory = 'All'.obs;
  final RxBool isRedeeming = false.obs;

  int get currentPoints => appData.currentUser.value?.points ?? 0;

  List<String> get rewardCategories => [
    'All',
    'Vouchers',
    'Dining & Drinks',
    'Health & Fitness',
    'Shopping',
    'Entertainment',
    'Eco Merchandise',
  ];

  List<RewardModel> get filteredRewards {
    if (selectedCategory.value == 'All') {
      return appData.allRewards;
    }
    return appData.allRewards
        .where((r) => r.category.toLowerCase() == selectedCategory.value.toLowerCase())
        .toList();
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  Future<void> redeemReward(RewardModel reward) async {
    if (currentPoints < reward.pointsCost) {
      Get.snackbar(
        "Insufficient Points",
        "You need ${reward.pointsCost - currentPoints} more points to redeem this reward.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    isRedeeming.value = true;
    final success = await appData.redeemReward(reward);
    isRedeeming.value = false;

    if (success) {
      Get.snackbar(
        "Redemption Successful! 🎉",
        "You have redeemed '${reward.title}'. Details sent to your email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
