class PointTransactionModel {
  final String id;
  final String userId;
  final int amount;
  final String type; // 'earned' or 'spent'
  final String title;
  final String description;
  final DateTime timestamp;

  PointTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  bool get isEarned => type == 'earned';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PointTransactionModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return PointTransactionModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      type: map['type'] ?? 'earned',
      title: map['title'] ?? 'Point Transaction',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
