import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import 'mock_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final MockDataService _mock = MockDataService();
  UserModel? _cachedUser;

  UserModel? get currentUser => _cachedUser ?? _mock.currentUser;

  Stream<UserModel?> get authStateChanges {
    final auth = _auth;
    if (auth != null) {
      return auth.authStateChanges().asyncMap((fbUser) async {
        if (fbUser == null) {
          _cachedUser = null;
          return null;
        }
        return await _fetchUserProfile(fbUser.uid, fbUser.email ?? '');
      });
    }
    return _mock.authStateChanges;
  }

  static bool isKrctEmail(String email) {
    return email.trim().toLowerCase().endsWith(AppConfig.allowedDomain);
  }

  static String? validateCollegeEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Please enter your college email ID';
    }
    if (!isKrctEmail(email)) {
      return AppConfig.invalidDomainError;
    }
    return null;
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
    required String year,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!isKrctEmail(normalizedEmail)) {
      throw AppConfig.invalidDomainError;
    }

    final auth = _auth;
    final firestore = _firestore;

    if (auth != null && firestore != null) {
      try {
        final cred = await auth.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        
        final user = UserModel(
          uid: cred.user!.uid,
          name: name,
          email: normalizedEmail,
          role: 'student',
          department: department,
          year: year,
        );
        
        await firestore.collection('users').doc(user.uid).set(user.toMap());
        _cachedUser = user;
        return user;
      } on FirebaseAuthException catch (e) {
        throw e.message ?? 'Registration failed.';
      }
    } else {
      // Mock mode registration
      final user = await _mock.signUp(normalizedEmail, password, name, department, year);
      _cachedUser = user;
      return user;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // 1. Strict Domain Validation
    if (!isKrctEmail(normalizedEmail)) {
      throw AppConfig.invalidDomainError;
    }

    if (password.trim().isEmpty) {
      throw 'Please enter your password.';
    }

    // 2. Try Firebase Auth if available, otherwise use Mock service
    final auth = _auth;
    final firestore = _firestore;

    if (auth != null && firestore != null) {
      try {
        UserCredential cred;
        try {
          cred = await auth.signInWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            // Auto-register student if account does not exist yet
            cred = await auth.createUserWithEmailAndPassword(
              email: normalizedEmail,
              password: password,
            );
          } else if (e.code == 'wrong-password') {
            throw 'Incorrect password. Please verify your credentials.';
          } else {
            throw e.message ?? 'Authentication failed.';
          }
        }

        final fbUser = cred.user!;
        final userModel = await _fetchOrCreateProfile(fbUser.uid, normalizedEmail);
        _cachedUser = userModel;
        return userModel;
      } catch (e) {
        if (e is String) rethrow;
        // If Firebase network / initialization fails, fallback cleanly to mock
        final user = await _mock.signIn(normalizedEmail, password);
        _cachedUser = user;
        return user;
      }
    } else {
      // Mock mode for local testing / emulator evaluation
      final user = await _mock.signIn(normalizedEmail, password);
      _cachedUser = user;
      return user;
    }
  }

  Future<UserModel> _fetchUserProfile(String uid, String email) async {
    try {
      final doc = await _firestore?.collection('users').doc(uid).get();
      if (doc != null && doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
    } catch (_) {}

    return _createDefaultUserModel(uid, email);
  }

  Future<UserModel> _fetchOrCreateProfile(String uid, String email) async {
    final user = await _fetchUserProfile(uid, email);
    try {
      await _firestore?.collection('users').doc(uid).set(user.toMap(), SetOptions(merge: true));
    } catch (_) {}
    return user;
  }

  UserModel _createDefaultUserModel(String uid, String email) {
    final isWarden = email.toLowerCase() == AppConfig.wardenEmail.toLowerCase();
    final namePart = email.split('@').first;
    final name = isWarden
        ? 'Hostel Warden'
        : namePart
            .split('.')
            .map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '')
            .join(' ');

    return UserModel(
      uid: uid,
      name: name.isNotEmpty ? name : 'KRCT Student',
      email: email,
      role: isWarden ? 'warden' : 'student',
    );
  }

  Future<void> signOut() async {
    _cachedUser = null;
    try {
      await _auth?.signOut();
    } catch (_) {}
    await _mock.signOut();
  }
}
