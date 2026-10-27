import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/menu_model.dart';
import '../../models/token_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/food_card.dart';
import '../auth/login_screen.dart';
import 'apply_token_screen.dart';
import 'student_complaints_screen.dart';

class StudentHome extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const StudentHome({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final today = DateTime.now();
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy').format(today);
    final todayMenu = MenuModel.getForDate(today);
    final isSunday = today.weekday == DateTime.sunday;
    final todayDateStr = DateFormat('yyyy-MM-dd').format(today);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello 👋',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (user?.name ?? 'Student').split(' ').first,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Student',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Text(
                          (user?.name.isNotEmpty == true ? user!.name[0] : 'S'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded,
                            color: AppColors.textSecondary),
                        tooltip: 'Logout',
                        onPressed: () async {
                          await AuthService().signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Applied Token Notification (If already applied)
              if (user != null)
                StreamBuilder<List<TokenModel>>(
                  stream: FirestoreService().streamStudentTokens(user.uid),
                  builder: (context, snapshot) {
                    final todayToken = snapshot.data
                        ?.where((t) => t.date == todayDateStr)
                        .firstOrNull;

                    if (todayToken != null) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.appliedBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.appliedText.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.appliedText,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Token Applied for Today!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.appliedText,
                                    ),
                                  ),
                                  Text(
                                    '${todayToken.tokenId} • ${todayToken.foodItem} (${todayToken.category})',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.appliedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

              // Today's Special Food Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Special",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              todayFormatted,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isSunday) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.event_busy_rounded,
                                size: 36, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text(
                              'No Special Food Token Available Today',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Special-food tokens are available Monday to Saturday only.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Two Side-by-Side Cards (Non-Veg & Veg)
                      SizedBox(
                        height: 220,
                        child: Row(
                          children: [
                            // Non-Veg Card
                            Expanded(
                              child: FoodSpecialCard(
                                category: 'Non-Vegetarian',
                                foodItem: todayMenu.nonVegFood,
                                onApply: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ApplyTokenScreen(
                                        initialCategory: 'Non-Vegetarian',
                                        initialDate: today,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Veg Card
                            Expanded(
                              child: FoodSpecialCard(
                                category: 'Vegetarian',
                                foodItem: todayMenu.vegFood,
                                onApply: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ApplyTokenScreen(
                                        initialCategory: 'Vegetarian',
                                        initialDate: today,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Food Complaint Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.nonVegBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.nonVegBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.report_problem_rounded, color: AppColors.nonVegRed, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Food Complaint',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.nonVegRedDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Not satisfied with today\'s special food?',
                      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentComplaintsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.nonVegRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Report a Problem'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
