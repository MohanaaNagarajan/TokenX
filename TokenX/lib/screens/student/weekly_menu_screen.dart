import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/menu_model.dart';
import 'apply_token_screen.dart';

class WeeklyMenuScreen extends StatelessWidget {
  const WeeklyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayWeekday = DateTime.now().weekday;
    final menuItems = MenuModel.weeklyMenu.where((m) => m.isAvailable).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Weekly Special Menu'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Subtitle Banner
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Special food is served Monday through Saturday. Tap any day to book your token.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Days List
          ...menuItems.map((item) {
            final isToday = item.weekday == todayWeekday;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isToday ? AppColors.primary : AppColors.cardBorder,
                  width: isToday ? 1.8 : 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Calculate date of upcoming matching weekday
                    final now = DateTime.now();
                    final daysAhead = (item.weekday - now.weekday + 7) % 7;
                    final targetDate = now.add(Duration(days: daysAhead));

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ApplyTokenScreen(initialDate: targetDate),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.dayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'TODAY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.textMuted, size: 20),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: 12),

                        // Non-Vegetarian Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.nonVegBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lunch_dining_rounded,
                                size: 14,
                                color: AppColors.nonVegRed,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Non-Veg: ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.nonVegRed,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.nonVegFood,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Vegetarian Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.vegBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                size: 14,
                                color: AppColors.vegGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Veg: ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.vegGreen,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.vegFood,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Sunday Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.bedtime_outlined, color: AppColors.textMuted),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sunday (No Special Food)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Regular hostel mess menu is served. Token booking closed.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
