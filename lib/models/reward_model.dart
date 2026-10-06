class RewardModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int pointsCost;
  final int stock;
  final String category;
  final bool isAvailable;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pointsCost,
    this.stock = 50,
    this.category = 'Vouchers',
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'pointsCost': pointsCost,
      'stock': stock,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  factory RewardModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return RewardModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? 'https://images.unsplash.com/photo-1556742049-0a67c5574f73',
      pointsCost: (map['pointsCost'] as num?)?.toInt() ?? 100,
      stock: (map['stock'] as num?)?.toInt() ?? 10,
      category: map['category'] ?? 'General',
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}

class RedemptionModel {
  final String id;
  final String rewardId;
  final String rewardTitle;
  final String rewardImageUrl;
  final int pointsCost;
  final String userId;
  final String userName;
  final DateTime redeemedAt;
  final String status; // 'pending', 'fulfilled'

  RedemptionModel({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.rewardImageUrl,
    required this.pointsCost,
    required this.userId,
    required this.userName,
    required this.redeemedAt,
    this.status = 'fulfilled',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'rewardImageUrl': rewardImageUrl,
      'pointsCost': pointsCost,
      'userId': userId,
      'userName': userName,
      'redeemedAt': redeemedAt.toIso8601String(),
      'status': status,
    };
  }

  factory RedemptionModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return RedemptionModel(
      id: docId ?? map['id'] ?? '',
      rewardId: map['rewardId'] ?? '',
      rewardTitle: map['rewardTitle'] ?? '',
      rewardImageUrl: map['rewardImageUrl'] ?? '',
      pointsCost: (map['pointsCost'] as num?)?.toInt() ?? 0,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      redeemedAt: map['redeemedAt'] != null
          ? DateTime.tryParse(map['redeemedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'fulfilled',
    );
  }
}
