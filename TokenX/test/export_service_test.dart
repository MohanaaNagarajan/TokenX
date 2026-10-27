import 'package:flutter_test/flutter_test.dart';
import 'package:tokenx/models/token_model.dart';
import 'package:tokenx/services/export_service.dart';

void main() {
  group('CSV Export Format Requirements', () {
    test('CSV Header and row format matches Requirement 37', () {
      final tokens = [
        TokenModel(
          tokenId: 'TX-20261005-0001',
          studentUid: 'student_001',
          studentName: 'Arun Kumar',
          studentEmail: 'student1@krct.ac.in',
          date: '2026-10-05',
          day: 'Monday',
          category: 'Non-Vegetarian',
          foodItem: 'Chicken 65',
          status: 'Applied',
          appliedAt: DateTime(2026, 10, 4, 19, 35, 0),
        ),
      ];

      final csv = ExportService.generateCsvString(tokens);
      final lines = csv.trim().split('\n');

      expect(lines.first.trim(), equals('Token ID,Student Name,Student Email,Date,Day,Category,Food Item,Applied At,Status'));
      expect(lines[1].trim(), contains('TX-20261005-0001,Arun Kumar,student1@krct.ac.in,2026-10-05,Monday,Non-Vegetarian,Chicken 65'));
      expect(lines[1].trim(), contains('Applied'));
    });
  });
}
