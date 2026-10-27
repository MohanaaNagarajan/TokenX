import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String complaintId;
  final String studentUid;
  final String studentName;
  final String studentEmail;
  final String tokenId;
  final String foodItem;
  final String category;
  final String description;
  final int? rating;
  final String date;
  final String day;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? wardenNote;

  ComplaintModel({
    required this.complaintId,
    required this.studentUid,
    required this.studentName,
    required this.studentEmail,
    required this.tokenId,
    required this.foodItem,
    required this.category,
    required this.description,
    this.rating,
    required this.date,
    required this.day,
    this.status = 'Submitted',
    this.priority = 'Low',
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.wardenNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'studentUid': studentUid,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'tokenId': tokenId,
      'foodItem': foodItem,
      'category': category,
      'description': description,
      'rating': rating,
      'date': date,
      'day': day,
      'status': status,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'wardenNote': wardenNote,
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String id) {
    return ComplaintModel(
      complaintId: id,
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      tokenId: map['tokenId'] ?? '',
      foodItem: map['foodItem'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      rating: map['rating'],
      date: map['date'] ?? '',
      day: map['day'] ?? '',
      status: map['status'] ?? 'Submitted',
      priority: map['priority'] ?? 'Low',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      resolvedAt: map['resolvedAt'] is Timestamp 
          ? (map['resolvedAt'] as Timestamp).toDate() 
          : null,
      wardenNote: map['wardenNote'],
    );
  }

  ComplaintModel copyWith({
    String? status,
    String? priority,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? wardenNote,
  }) {
    return ComplaintModel(
      complaintId: complaintId,
      studentUid: studentUid,
      studentName: studentName,
      studentEmail: studentEmail,
      tokenId: tokenId,
      foodItem: foodItem,
      category: category,
      description: description,
      rating: rating,
      date: date,
      day: day,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      wardenNote: wardenNote ?? this.wardenNote,
    );
  }
}
