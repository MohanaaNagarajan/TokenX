import 'package:flutter_test/flutter_test.dart';
import 'package:tokenx/config/app_config.dart';
import 'package:tokenx/models/user_model.dart';
import 'package:tokenx/services/auth_service.dart';

void main() {
  group('Authentication & Domain Security Tests', () {
    test('Valid KRCT student email is accepted', () {
      const validStudent = 'student123@krct.ac.in';
      expect(AuthService.isKrctEmail(validStudent), isTrue);
      expect(AuthService.validateCollegeEmail(validStudent), isNull);
    });

    test('Warden email is recognized as valid KRCT email', () {
      const wardenEmail = 'hostelwarden@krct.ac.in';
      expect(AuthService.isKrctEmail(wardenEmail), isTrue);
      expect(AuthService.validateCollegeEmail(wardenEmail), isNull);
    });

    test('Invalid domains (gmail, yahoo, outlook) are rejected with exact required message', () {
      const invalidEmails = [
        'student123@gmail.com',
        'student123@yahoo.com',
        'student123@outlook.com',
        'warden@somedomain.org',
      ];

      for (final email in invalidEmails) {
        expect(AuthService.isKrctEmail(email), isFalse);
        final error = AuthService.validateCollegeEmail(email);
        expect(error, equals(AppConfig.invalidDomainError));
      }
    });

    test('Warden Authorization is strictly enforced', () {
      final wardenUser = UserModel(
        uid: 'w001',
        name: 'Hostel Warden',
        email: 'hostelwarden@krct.ac.in',
        role: 'warden',
      );
      expect(wardenUser.isWarden, isTrue);
      expect(wardenUser.isStudent, isFalse);

      final studentUser = UserModel(
        uid: 's001',
        name: 'Arun Kumar',
        email: 'student1@krct.ac.in',
        role: 'student',
      );
      expect(studentUser.isWarden, isFalse);
      expect(studentUser.isStudent, isTrue);

      // Even if role was set to 'warden', non-hostelwarden email cannot be warden
      final hackerUser = UserModel(
        uid: 'h001',
        name: 'Fake Warden',
        email: 'attacker@krct.ac.in',
        role: 'warden',
      );
      expect(hackerUser.isWarden, isFalse);
    });
  });
}
