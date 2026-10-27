import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';
import 'mock_service.dart';

class ComplaintService {
  static final ComplaintService _instance = ComplaintService._internal();
  factory ComplaintService() => _instance;
  ComplaintService._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final MockDataService _mock = MockDataService();

  Future<ComplaintModel> createComplaint(ComplaintModel complaint) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final docRef = fs.collection('complaints').doc(complaint.complaintId);
        final existing = await docRef.get();
        if (existing.exists) {
          throw 'Complaint already exists for this token.';
        }
        await docRef.set(complaint.toMap());
        _recalculatePriority(complaint.foodItem);
        return complaint;
      } catch (e) {
        if (e is String) rethrow;
        final res = await _mock.createComplaint(complaint);
        _recalculateMockPriority(complaint.foodItem);
        return res;
      }
    }
    final res = await _mock.createComplaint(complaint);
    _recalculateMockPriority(complaint.foodItem);
    return res;
  }

  Stream<List<ComplaintModel>> streamStudentComplaints(String studentUid) {
    final fs = _firestore;
    if (fs != null) {
      try {
        return fs
            .collection('complaints')
            .where('studentUid', isEqualTo: studentUid)
            .snapshots()
            .map((snap) {
          final list = snap.docs.map((d) => ComplaintModel.fromMap(d.data(), d.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
      } catch (_) {}
    }
    return _mock.complaintStream.map((all) =>
        all.where((c) => c.studentUid == studentUid).toList());
  }

  Stream<List<ComplaintModel>> streamAllComplaints() {
    final fs = _firestore;
    if (fs != null) {
      try {
        return fs.collection('complaints').snapshots().map((snap) {
          final list = snap.docs.map((d) => ComplaintModel.fromMap(d.data(), d.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
      } catch (_) {}
    }
    return _mock.complaintStream;
  }

  Future<void> updateStatus(String complaintId, String status) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('complaints').doc(complaintId).update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
          if (status == 'Resolved') 'resolvedAt': FieldValue.serverTimestamp(),
        });
        return;
      } catch (_) {}
    }
    await _mock.updateComplaintStatus(complaintId, status);
  }

  Future<void> addWardenNote(String complaintId, String note) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('complaints').doc(complaintId).update({
          'wardenNote': note,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      } catch (_) {}
    }
    await _mock.addWardenNote(complaintId, note);
  }

  // Priority Recalculation Logic
  Future<void> _recalculatePriority(String foodItem) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      final snap = await fs.collection('complaints').where('foodItem', isEqualTo: foodItem).get();
      final count = snap.docs.length;
      final newPriority = _getPriorityForCount(count);
      
      final batch = fs.batch();
      for (var doc in snap.docs) {
        if (doc.data()['priority'] != newPriority) {
          batch.update(doc.reference, {'priority': newPriority});
        }
      }
      await batch.commit();
    } catch (_) {}
  }

  void _recalculateMockPriority(String foodItem) async {
    final snap = await _mock.complaintStream.first;
    final foodComplaints = snap.where((c) => c.foodItem == foodItem).toList();
    final count = foodComplaints.length;
    final newPriority = _getPriorityForCount(count);

    for (var c in foodComplaints) {
      if (c.priority != newPriority) {
        await _mock.updateComplaintPriority(c.complaintId, newPriority);
      }
    }
  }

  String _getPriorityForCount(int count) {
    if (count > 25) return 'CRITICAL';
    if (count >= 16) return 'HIGH';
    if (count >= 6) return 'MEDIUM';
    return 'LOW';
  }
}
