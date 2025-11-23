import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String hostelId;
  final String userName;
  final String? userPhone;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.hostelId,
    required this.userName,
    this.userPhone,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'hostelId': hostelId,
      'userName': userName,
      'userPhone': userPhone,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory Review.fromMap(String id, Map<String, dynamic> map) {
    return Review(
      id: id,
      hostelId: map['hostelId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'],
      rating: map['rating'] ?? 5,
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

