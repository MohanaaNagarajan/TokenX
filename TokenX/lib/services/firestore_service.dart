import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';
import 'mock_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final MockDataService _mock = MockDataService();

  bool get _isFirebaseAvailable => _firestore != null;

  // Check if token already exists for student on given date
  Future<bool> hasAppliedForDate(String studentUid, String date) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final doc = await fs.collection('tokens').doc('${studentUid}_$date').get();
        return doc.exists;
      } catch (_) {
        return _mock.hasTokenForDate(studentUid, date);
      }
    }
    return _mock.hasTokenForDate(studentUid, date);
  }

  // Create new token
  Future<TokenModel> createToken(TokenModel token) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final docRef = fs.collection('tokens').doc(token.documentId);
        final existing = await docRef.get();
        if (existing.exists) {
          throw 'You have already applied for a token for this date.';
        }
        await docRef.set(token.toMap());
        return token;
      } catch (e) {
        if (e is String) rethrow;
        return await _mock.createToken(token);
      }
    }
    return await _mock.createToken(token);
  }

  // Stream tokens for a specific student (My Tokens)
  Stream<List<TokenModel>> streamStudentTokens(String studentUid) {
    final fs = _firestore;
    if (fs != null) {
      try {
        return fs
            .collection('tokens')
            .where('studentUid', isEqualTo: studentUid)
            .snapshots()
            .map((snap) {
          final list = snap.docs.map((d) => TokenModel.fromMap(d.data(), d.id)).toList();
          list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          return list;
        });
      } catch (_) {
        return _mock.tokenStream.map((all) =>
            all.where((t) => t.studentUid == studentUid).toList());
      }
    }
    return _mock.tokenStream.map((all) =>
        all.where((t) => t.studentUid == studentUid).toList());
  }

  // Stream all tokens for Warden Dashboard & Token List
  Stream<List<TokenModel>> streamAllTokens() {
    final fs = _firestore;
    if (fs != null) {
      try {
        return fs.collection('tokens').snapshots().map((snap) {
          final list = snap.docs.map((d) => TokenModel.fromMap(d.data(), d.id)).toList();
          list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          return list;
        });
      } catch (_) {
        return _mock.tokenStream;
      }
    }
    return _mock.tokenStream;
  }

  // Update status (e.g. Redeemed by warden)
  Future<void> updateTokenStatus(String documentId, String newStatus) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('tokens').doc(documentId).update({'status': newStatus});
        return;
      } catch (_) {}
    }
    await _mock.updateTokenStatus(documentId, newStatus);
  }
}
