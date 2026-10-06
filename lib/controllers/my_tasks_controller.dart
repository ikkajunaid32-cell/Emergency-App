import 'package:get/get.dart';
import '../models/task_model.dart';
import '../models/submission_model.dart';
import '../services/app_data_service.dart';

class MyTasksController extends GetxController {
  final appData = AppDataService.instance;
  final RxInt selectedTabIndex = 0.obs;

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  // Active tasks (tasks the user explicitly tapped 'Start Task' on and haven't yet submitted)
  List<TaskModel> get activeStartedTasks {
    final ids = appData.activeStartedTaskIds;
    return appData.allTasks.where((t) => ids.contains(t.id)).toList();
  }

  // Pending review
  List<SubmissionModel> get pendingSubmissions => appData.myPendingSubmissions;

  // Completed
  List<SubmissionModel> get completedSubmissions => appData.myCompletedSubmissions;

  // Rejected
  List<SubmissionModel> get rejectedSubmissions => appData.myRejectedSubmissions;
}
