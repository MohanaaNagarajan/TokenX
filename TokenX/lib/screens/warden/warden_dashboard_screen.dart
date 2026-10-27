import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/menu_model.dart';
import '../../models/token_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/stat_card.dart';
import 'warden_export_screen.dart';

class WardenDashboardScreen extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const WardenDashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy').format(today);
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final todayMenu = MenuModel.getForDate(today);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Hostel Warden Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Export CSV',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WardenExportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<TokenModel>>(
        stream: FirestoreService().streamAllTokens(),
        builder: (context, snapshot) {
          final allTokens = snapshot.data ?? [];
          final todayTokens = allTokens.where((t) => t.date == todayStr).toList();

          // Calculate Dynamic Statistics from real Firestore stream
          final totalCount = allTokens.length;
          final todayCount = todayTokens.length;
          final vegCount = todayTokens.where((t) => t.isVegetarian).length;
          final nonVegCount = todayTokens.where((t) => t.isNonVegetarian).length;

          final chicken65Count = todayTokens
              .where((t) => t.foodItem == todayMenu.nonVegFood)
              .length;
          final gobi65Count = todayTokens
              .where((t) => t.foodItem == todayMenu.vegFood)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warden Info Card
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
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              'Hostel Warden',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              todayFormatted,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2x2 Metric Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.35,
                  children: [
                    StatMetricCard(
                      title: 'Total Tokens',
                      value: '$totalCount',
                      icon: Icons.groups_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryContainer,
                    ),
                    StatMetricCard(
                      title: 'Vegetarian',
                      value: '$vegCount',
                      icon: Icons.eco_rounded,
                      iconColor: AppColors.vegGreen,
                      iconBgColor: AppColors.vegBackground,
                    ),
                    StatMetricCard(
                      title: 'Non-Vegetarian',
                      value: '$nonVegCount',
                      icon: Icons.lunch_dining_rounded,
                      iconColor: AppColors.nonVegRed,
                      iconBgColor: AppColors.nonVegBackground,
                    ),
                    StatMetricCard(
                      title: "Today's Tokens",
                      value: '$todayCount',
                      icon: Icons.calendar_today_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Today's Food Requirement Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Food Requirement",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => onNavigateToTab?.call(2),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Non-Veg Requirement Row
                      _buildRequirementRow(
                        dishName: todayMenu.nonVegFood,
                        category: 'Non-Vegetarian',
                        count: nonVegCount,
                        icon: Icons.lunch_dining_rounded,
                        accentColor: AppColors.nonVegRed,
                        bgColor: AppColors.nonVegBackground,
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 12),

                      // Veg Requirement Row
                      _buildRequirementRow(
                        dishName: todayMenu.vegFood,
                        category: 'Vegetarian',
                        count: vegCount,
                        icon: Icons.eco_rounded,
                        accentColor: AppColors.vegGreen,
                        bgColor: AppColors.vegBackground,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Navigation Action Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onNavigateToTab?.call(1),
                        icon: const Icon(Icons.format_list_bulleted_rounded, size: 18),
                        label: const Text('View All Tokens'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WardenExportScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.file_download_outlined, size: 18),
                        label: const Text('Export CSV'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequirementRow({
    required String dishName,
    required String category,
    required int count,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dishName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                category,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
