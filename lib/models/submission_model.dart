class SubmissionModel {
  final String id;
  final String taskId;
  final String taskTitle;
  final int pointsReward;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime submittedAt;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  
  // Submitted Evidence
  final String? textResponse;
  final List<String> photoUrls;
  final String? videoUrl;
  final List<String> fileUrls;
  final double? locationLat;
  final double? locationLng;
  final String? locationAddress;

  final String? reviewedBy;
  final DateTime? reviewedAt;

  SubmissionModel({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.pointsReward,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.submittedAt,
    this.status = 'pending',
    this.rejectionReason,
    this.textResponse,
    this.photoUrls = const [],
    this.videoUrl,
    this.fileUrls = const [],
    this.locationLat,
    this.locationLng,
    this.locationAddress,
    this.reviewedBy,
    this.reviewedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'pointsReward': pointsReward,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'textResponse': textResponse,
      'photoUrls': photoUrls,
      'videoUrl': videoUrl,
      'fileUrls': fileUrls,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'locationAddress': locationAddress,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SubmissionModel(
      id: docId ?? map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      taskTitle: map['taskTitle'] ?? 'Task Submission',
      pointsReward: (map['pointsReward'] as num?)?.toInt() ?? 0,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'User',
      userEmail: map['userEmail'] ?? '',
      submittedAt: map['submittedAt'] != null
          ? DateTime.tryParse(map['submittedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      textResponse: map['textResponse'],
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      videoUrl: map['videoUrl'],
      fileUrls: List<String>.from(map['fileUrls'] ?? []),
      locationLat: (map['locationLat'] as num?)?.toDouble(),
      locationLng: (map['locationLng'] as num?)?.toDouble(),
      locationAddress: map['locationAddress'],
      reviewedBy: map['reviewedBy'],
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.tryParse(map['reviewedAt'].toString())
          : null,
    );
  }

  SubmissionModel copyWith({
    String? status,
    String? rejectionReason,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return SubmissionModel(
      id: id,
      taskId: taskId,
      taskTitle: taskTitle,
      pointsReward: pointsReward,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      submittedAt: submittedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      textResponse: textResponse,
      photoUrls: photoUrls,
      videoUrl: videoUrl,
      fileUrls: fileUrls,
      locationLat: locationLat,
      locationLng: locationLng,
      locationAddress: locationAddress,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
