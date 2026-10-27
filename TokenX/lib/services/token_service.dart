import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/menu_model.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  // Validate if date is allowed for booking
  static String? validateBookingDate(DateTime targetDate) {
    if (!MenuModel.isSpecialFoodDay(targetDate)) {
      return AppConfig.sundayMessage;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDay = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (bookingDay.isBefore(today)) {
      return 'Cannot apply token for a past date.';
    }

    // Check cutoff deadline for same-day booking
    if (bookingDay.isAtSameMomentAs(today)) {
      final deadline = DateTime(
        today.year,
        today.month,
        today.day,
        AppConfig.deadlineCutoffHour,
        AppConfig.deadlineCutoffMinute,
      );
      if (now.isAfter(deadline)) {
        return AppConfig.closedDeadlineError;
      }
    }

    return null;
  }

  // Check if booking is open for target date
  static bool isBookingOpen(DateTime targetDate) {
    return validateBookingDate(targetDate) == null;
  }

  // Apply for a new special food token
  Future<TokenModel> applyToken({
    required UserModel student,
    required DateTime targetDate,
    required String category, // 'Vegetarian' or 'Non-Vegetarian'
  }) async {
    // 1. Date & Deadline Validation
    final dateError = validateBookingDate(targetDate);
    if (dateError != null) {
      throw dateError;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);

    // 2. Duplicate Validation
    final hasExisting = await _firestoreService.hasAppliedForDate(student.uid, dateStr);
    if (hasExisting) {
      throw AppConfig.duplicateTokenError;
    }

    // 3. Resolve Food Item from Menu
    final foodItem = MenuModel.getFoodItem(targetDate, category);
    final dayName = DateFormat('EEEE').format(targetDate);

    // 4. Generate Unique Token ID
    final tokenId = TokenModel.generateTokenId(targetDate);

    final newToken = TokenModel(
      tokenId: tokenId,
      studentUid: student.uid,
      studentName: student.name,
      studentEmail: student.email,
      date: dateStr,
      day: dayName,
      category: category,
      foodItem: foodItem,
      status: 'Applied',
      appliedAt: DateTime.now(),
    );

    // 5. Commit to Firestore
    return await _firestoreService.createToken(newToken);
  }
}
