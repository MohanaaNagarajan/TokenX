import 'dart:math';
import 'package:intl/intl.dart';

class TokenModel {
  final String tokenId;
  final String studentUid;
  final String studentName;
  final String studentEmail;
  final String date; // YYYY-MM-DD
  final String day;
  final String category; // 'Vegetarian' or 'Non-Vegetarian'
  final String foodItem;
  final String status; // 'Applied', 'Redeemed', 'Cancelled'
  final DateTime appliedAt;

  TokenModel({
    required this.tokenId,
    required this.studentUid,
    required this.studentName,
    required this.studentEmail,
    required this.date,
    required this.day,
    required this.category,
    required this.foodItem,
    this.status = 'Applied',
    DateTime? appliedAt,
  }) : appliedAt = appliedAt ?? DateTime.now();

  String get documentId => '${studentUid}_$date';

  bool get isNonVegetarian => category.toLowerCase().contains('non');
  bool get isVegetarian => !isNonVegetarian;

  String get formattedAppliedAt =>
      DateFormat('dd MMM yyyy, hh:mm a').format(appliedAt);

  String get formattedDate {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('EEEE, d MMMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  String get shortFormattedDate {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('EEE, d MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'tokenId': tokenId,
      'studentUid': studentUid,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'date': date,
      'day': day,
      'category': category,
      'foodItem': foodItem,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  factory TokenModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TokenModel(
      tokenId: map['tokenId'] ?? 'TX-UNKNOWN',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? 'KRCT Student',
      studentEmail: map['studentEmail'] ?? '',
      date: map['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      day: map['day'] ?? 'Monday',
      category: map['category'] ?? 'Vegetarian',
      foodItem: map['foodItem'] ?? '',
      status: map['status'] ?? 'Applied',
      appliedAt: map['appliedAt'] != null
          ? DateTime.tryParse(map['appliedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static String generateTokenId(DateTime targetDate, [int? sequence]) {
    final dateStr = DateFormat('yyyyMMdd').format(targetDate);
    final numStr = sequence != null
        ? sequence.toString().padLeft(4, '0')
        : (1000 + Random().nextInt(9000)).toString();
    return 'TX-$dateStr-$numStr';
  }

  TokenModel copyWith({
    String? status,
  }) {
    return TokenModel(
      tokenId: tokenId,
      studentUid: studentUid,
      studentName: studentName,
      studentEmail: studentEmail,
      date: date,
      day: day,
      category: category,
      foodItem: foodItem,
      status: status ?? this.status,
      appliedAt: appliedAt,
    );
  }
}
