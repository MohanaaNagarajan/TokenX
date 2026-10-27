import 'dart:async';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/token_model.dart';
import '../models/complaint_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;

  final Map<String, UserModel> _users = {};
  final Map<String, TokenModel> _tokens = {};
  final Map<String, ComplaintModel> _complaints = {};

  final _tokenStreamController = StreamController<List<TokenModel>>.broadcast();
  final _authStreamController = StreamController<UserModel?>.broadcast();
  final _complaintStreamController = StreamController<List<ComplaintModel>>.broadcast();

  UserModel? _currentUser;

  MockDataService._internal() {
    _seedInitialData();
  }

  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get authStateChanges => _authStreamController.stream;
  Stream<List<TokenModel>> get tokenStream async* {
    yield _tokens.values.toList()..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    yield* _tokenStreamController.stream;
  }

  Stream<List<ComplaintModel>> get complaintStream async* {
    yield _complaints.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield* _complaintStreamController.stream;
  }

  void _notifyComplaints() {
    final list = _complaints.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _complaintStreamController.add(list);
  }

  void _seedInitialData() {
    // Seed Users
    final warden = UserModel(
      uid: 'warden_001',
      name: 'Hostel Warden',
      email: AppConfig.wardenEmail,
      role: 'warden',
      department: 'Hostel Administration',
      year: 'Staff',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    _users[warden.email.toLowerCase()] = warden;

    final student1 = UserModel(
      uid: 'student_001',
      name: 'Student',
      email: 'student1@krct.ac.in',
      role: 'student',
      department: 'Computer Science and Engineering',
      year: 'III Year',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    );
    _users[student1.email.toLowerCase()] = student1;

    final student2 = UserModel(
      uid: 'student_002',
      name: 'Priya S',
      email: 'student2@krct.ac.in',
      role: 'student',
      department: 'Electronics & Communication',
      year: 'IV Year',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );
    _users[student2.email.toLowerCase()] = student2;

    final student3 = UserModel(
      uid: 'student_003',
      name: 'Vignesh R',
      email: 'student3@krct.ac.in',
      role: 'student',
      department: 'Information Technology',
      year: 'II Year',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );
    _users[student3.email.toLowerCase()] = student3;

    // Seed Sample Tokens matching UI mockups
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    final seedTokens = [
      TokenModel(
        tokenId: 'TX-20261005-0001',
        studentUid: student1.uid,
        studentName: student1.name,
        studentEmail: student1.email,
        date: todayStr,
        day: DateFormat('EEEE').format(today),
        category: 'Non-Vegetarian',
        foodItem: 'Chicken 65',
        status: 'Applied',
        appliedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      TokenModel(
        tokenId: 'TX-20261005-0002',
        studentUid: student2.uid,
        studentName: student2.name,
        studentEmail: student2.email,
        date: todayStr,
        day: DateFormat('EEEE').format(today),
        category: 'Vegetarian',
        foodItem: 'Gobi 65',
        status: 'Applied',
        appliedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TokenModel(
        tokenId: 'TX-20261005-0003',
        studentUid: student3.uid,
        studentName: student3.name,
        studentEmail: student3.email,
        date: todayStr,
        day: DateFormat('EEEE').format(today),
        category: 'Non-Vegetarian',
        foodItem: 'Chicken 65',
        status: 'Applied',
        appliedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      TokenModel(
        tokenId: 'TX-20261006-0004',
        studentUid: 'student_004',
        studentName: 'Meena K',
        studentEmail: 'student4@krct.ac.in',
        date: DateFormat('yyyy-MM-dd').format(today.add(const Duration(days: 1))),
        day: 'Tuesday',
        category: 'Vegetarian',
        foodItem: 'Mushroom Biryani',
        status: 'Applied',
        appliedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ];

    for (final t in seedTokens) {
      _tokens[t.documentId] = t;
    }
    _notifyTokens();
  }

  void _notifyTokens() {
    final list = _tokens.values.toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    _tokenStreamController.add(list);
  }

  Future<UserModel> signUp(String email, String password, String name, String department, String year) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final normalized = email.trim().toLowerCase();

    if (_users.containsKey(normalized)) {
      throw 'Email already in use';
    }

    final newUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: normalized,
      role: 'student',
      department: department,
      year: year,
    );

    _users[normalized] = newUser;
    _currentUser = newUser;
    _authStreamController.add(_currentUser);
    return newUser;
  }

  // Authentication Operations
  Future<UserModel> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final normalized = email.trim().toLowerCase();

    if (!normalized.endsWith(AppConfig.allowedDomain)) {
      throw AppConfig.invalidDomainError;
    }

    if (password.trim().isEmpty) {
      throw 'Please enter your password.';
    }

    if (_users.containsKey(normalized)) {
      _currentUser = _users[normalized];
    } else {
      // Auto-register new KRCT student
      final namePart = normalized.split('@').first;
      final capitalized = namePart
          .split('.')
          .map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '')
          .join(' ');
      
      final newUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: capitalized.isNotEmpty ? capitalized : 'KRCT Student',
        email: normalized,
        role: normalized == AppConfig.wardenEmail.toLowerCase() ? 'warden' : 'student',
      );
      _users[normalized] = newUser;
      _currentUser = newUser;
    }

    _authStreamController.add(_currentUser);
    return _currentUser!;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
    _authStreamController.add(null);
  }

  // Token Operations
  bool hasTokenForDate(String studentUid, String date) {
    final docId = '${studentUid}_$date';
    return _tokens.containsKey(docId);
  }

  Future<TokenModel> createToken(TokenModel token) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_tokens.containsKey(token.documentId)) {
      throw AppConfig.duplicateTokenError;
    }

    _tokens[token.documentId] = token;
    _notifyTokens();
    return token;
  }

  List<TokenModel> getTokensForStudent(String studentUid) {
    return _tokens.values
        .where((t) => t.studentUid == studentUid)
        .toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
  }

  List<TokenModel> getAllTokens() {
    return _tokens.values.toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
  }

  Future<void> updateTokenStatus(String documentId, String status) async {
    if (_tokens.containsKey(documentId)) {
      _tokens[documentId] = _tokens[documentId]!.copyWith(status: status);
      _notifyTokens();
    }
  }

  Future<ComplaintModel> createComplaint(ComplaintModel complaint) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _complaints[complaint.complaintId] = complaint;
    _notifyComplaints();
    return complaint;
  }

  Future<void> updateComplaintStatus(String id, String status) async {
    if (_complaints.containsKey(id)) {
      _complaints[id] = _complaints[id]!.copyWith(
        status: status,
        resolvedAt: status == 'Resolved' ? DateTime.now() : _complaints[id]!.resolvedAt,
      );
      _notifyComplaints();
    }
  }

  Future<void> updateComplaintPriority(String id, String priority) async {
    if (_complaints.containsKey(id)) {
      _complaints[id] = _complaints[id]!.copyWith(priority: priority);
      _notifyComplaints();
    }
  }

  Future<void> addWardenNote(String id, String note) async {
    if (_complaints.containsKey(id)) {
      _complaints[id] = _complaints[id]!.copyWith(wardenNote: note);
      _notifyComplaints();
    }
  }
}
