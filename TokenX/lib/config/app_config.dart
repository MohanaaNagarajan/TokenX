class AppConfig {
  static const String appName = 'TokenX';
  static const String appTagline = 'Smart Hostel Mess Token Management';
  static const String collegeName = 'K Ramakrishnan College of Technology';
  static const String collegeShort = 'KRCT';

  // Domain Restrictions
  static const String allowedDomain = '@krct.ac.in';
  static const String wardenEmail = 'hostelwarden@krct.ac.in';

  // Exact Error Messages
  static const String invalidDomainError =
      'Invalid college email ID. Please use your @krct.ac.in email ID.';
  static const String duplicateTokenError =
      'You have already applied for a token for this date.';
  static const String sundayMessage =
      'Special-food tokens are available Monday to Saturday only.';
  static const String closedDeadlineError =
      'Token application is closed for this date.';
  static const String studentEmptyTokens =
      "You haven't applied for any tokens yet.";
  static const String wardenEmptyTokens =
      'No token applications found for this date.';

  // Deadline Configuration (Configurable cutoff time on booking date)
  static const int deadlineCutoffHour = 9; // 9:00 AM
  static const int deadlineCutoffMinute = 0;
  static const String timeZone = 'Asia/Kolkata';

  // Demo Credentials for Viva / Evaluation
  static const Map<String, Map<String, String>> demoAccounts = {
    'warden': {
      'email': 'hostelwarden@krct.ac.in',
      'password': 'Password@123',
      'name': 'Hostel Warden',
      'role': 'warden',
      'dept': 'Administration',
    },
    'student1': {
      'email': 'student1@krct.ac.in',
      'password': 'Password@123',
      'name': 'Student',
      'role': 'student',
      'dept': 'CSE',
      'year': 'III Year',
    },
    'student2': {
      'email': 'student2@krct.ac.in',
      'password': 'Password@123',
      'name': 'Priya S',
      'role': 'student',
      'dept': 'ECE',
      'year': 'IV Year',
    },
    'student3': {
      'email': 'student3@krct.ac.in',
      'password': 'Password@123',
      'name': 'Vignesh R',
      'role': 'student',
      'dept': 'IT',
      'year': 'II Year',
    },
  };
}
