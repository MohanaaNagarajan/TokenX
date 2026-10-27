import '../config/app_config.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' or 'warden'
  final String department;
  final String year;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.department = 'CSE',
    this.year = 'III Year',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isWarden =>
      email.trim().toLowerCase() == AppConfig.wardenEmail.toLowerCase() &&
      role == 'warden';

  bool get isStudent => !isWarden;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId.isNotEmpty ? docId : (map['uid'] ?? ''),
      name: map['name'] ?? 'KRCT Student',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      department: map['department'] ?? 'CSE',
      year: map['year'] ?? 'III Year',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? department,
    String? year,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      year: year ?? this.year,
      createdAt: createdAt,
    );
  }
}
