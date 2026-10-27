import 'package:flutter_test/flutter_test.dart';
import 'package:tokenx/models/token_model.dart';

void main() {
  group('Token Model & Uniqueness Tests', () {
    test('Token ID generation pattern TX-YYYYMMDD-XXXX', () {
      final date = DateTime(2026, 10, 5);
      final tokenId = TokenModel.generateTokenId(date, 1);
      expect(tokenId, equals('TX-20261005-0001'));
    });

    test('Deterministic Document ID prevents duplicates at DB level', () {
      final token = TokenModel(
        tokenId: 'TX-20261005-0001',
        studentUid: 'student_123',
        studentName: 'Arun Kumar',
        studentEmail: 'student1@krct.ac.in',
        date: '2026-10-05',
        day: 'Monday',
        category: 'Non-Vegetarian',
        foodItem: 'Chicken 65',
      );

      expect(token.documentId, equals('student_123_2026-10-05'));
    });

    test('Serialization and Deserialization', () {
      final token = TokenModel(
        tokenId: 'TX-20261005-0002',
        studentUid: 'student_456',
        studentName: 'Priya S',
        studentEmail: 'student2@krct.ac.in',
        date: '2026-10-05',
        day: 'Monday',
        category: 'Vegetarian',
        foodItem: 'Gobi 65',
      );

      final map = token.toMap();
      final reconstructed = TokenModel.fromMap(map, token.documentId);

      expect(reconstructed.tokenId, equals(token.tokenId));
      expect(reconstructed.studentUid, equals(token.studentUid));
      expect(reconstructed.foodItem, equals(token.foodItem));
      expect(reconstructed.category, equals('Vegetarian'));
      expect(reconstructed.isVegetarian, isTrue);
      expect(reconstructed.isNonVegetarian, isFalse);
    });
  });
}
