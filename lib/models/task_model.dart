enum SubmissionType { text, photo, video, file, location }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String detailedInstructions;
  final String bannerUrl;
  final String category;
  final int pointsReward;
  final List<SubmissionType> requiredSubmissions;
  final DateTime startDate;
  final DateTime deadline;
  final bool isRecurring;
  final String? recurrenceRule; // 'daily', 'weekly', 'none'
  final String status; // 'active', 'draft', 'expired'
  final String createdBy;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.detailedInstructions,
    required this.bannerUrl,
    required this.category,
    required this.pointsReward,
    required this.requiredSubmissions,
    required this.startDate,
    required this.deadline,
    this.isRecurring = false,
    this.recurrenceRule,
    this.status = 'active',
    required this.createdBy,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(deadline);
  
  Duration get remainingDuration {
    final diff = deadline.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get formattedRemainingTime {
    final rem = remainingDuration;
    if (rem == Duration.zero) return "Expired";
    if (rem.inDays > 0) return "${rem.inDays}d ${rem.inHours % 24}h left";
    if (rem.inHours > 0) return "${rem.inHours}h ${rem.inMinutes % 60}m left";
    return "${rem.inMinutes}m left";
  }

  bool get requiresText => requiredSubmissions.contains(SubmissionType.text);
  bool get requiresPhoto => requiredSubmissions.contains(SubmissionType.photo);
  bool get requiresVideo => requiredSubmissions.contains(SubmissionType.video);
  bool get requiresFile => requiredSubmissions.contains(SubmissionType.file);
  bool get requiresLocation => requiredSubmissions.contains(SubmissionType.location);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'detailedInstructions': detailedInstructions,
      'bannerUrl': bannerUrl,
      'category': category,
      'pointsReward': pointsReward,
      'requiredSubmissions': requiredSubmissions.map((e) => e.name).toList(),
      'startDate': startDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    List<SubmissionType> submissions = [];
    if (map['requiredSubmissions'] != null) {
      final list = map['requiredSubmissions'] as List;
      for (var item in list) {
        try {
          submissions.add(SubmissionType.values.byName(item.toString().toLowerCase()));
        } catch (_) {}
      }
    }
    if (submissions.isEmpty) {
      submissions = [SubmissionType.photo, SubmissionType.text];
    }

    return TaskModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      detailedInstructions: map['detailedInstructions'] ?? map['description'] ?? '',
      bannerUrl: map['bannerUrl'] ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
      category: map['category'] ?? 'General',
      pointsReward: (map['pointsReward'] as num?)?.toInt() ?? 50,
      requiredSubmissions: submissions,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'].toString()) ?? DateTime.now().add(const Duration(hours: 24))
          : DateTime.now().add(const Duration(hours: 24)),
      isRecurring: map['isRecurring'] ?? false,
      recurrenceRule: map['recurrenceRule'],
      status: map['status'] ?? 'active',
      createdBy: map['createdBy'] ?? 'admin',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
