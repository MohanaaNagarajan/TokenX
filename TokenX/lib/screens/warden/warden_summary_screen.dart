import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/menu_model.dart';
import '../../models/token_model.dart';
import '../../services/firestore_service.dart';
import 'warden_export_screen.dart';

class WardenSummaryScreen extends StatefulWidget {
  const WardenSummaryScreen({super.key});

  @override
  State<WardenSummaryScreen> createState() => _WardenSummaryScreenState();
}

class _WardenSummaryScreenState extends State<WardenSummaryScreen> {
  DateTime _selectedDate = DateTime.now();
  final _firestoreService = FirestoreService();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final formattedHeaderDate = DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);
    final menu = MenuModel.getForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Food Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'Export',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WardenExportScreen(initialDate: _selectedDate),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TokenModel>>(
        stream: _firestoreService.streamAllTokens(),
        builder: (context, snapshot) {
          final allTokens = snapshot.data ?? [];
          final dateTokens = allTokens.where((t) => t.date == dateStr).toList();

          final vegTokens = dateTokens.where((t) => t.isVegetarian).toList();
          final nonVegTokens = dateTokens.where((t) => t.isNonVegetarian).toList();

          final totalRequirement = dateTokens.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selector Header
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            formattedHeaderDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Non-Vegetarian Food Box
                _buildFoodSectionCard(
                  title: 'NON-VEGETARIAN',
                  dishName: menu.nonVegFood,
                  categoryTotal: nonVegTokens.length,
                  dishCount: nonVegTokens.length,
                  accentColor: AppColors.nonVegRed,
                  bgColor: AppColors.nonVegBackground,
                  borderColor: AppColors.nonVegBorder,
                  icon: Icons.lunch_dining_rounded,
                ),
                const SizedBox(height: 16),

                // Vegetarian Food Box
                _buildFoodSectionCard(
                  title: 'VEGETARIAN',
                  dishName: menu.vegFood,
                  categoryTotal: vegTokens.length,
                  dishCount: vegTokens.length,
                  accentColor: AppColors.vegGreen,
                  bgColor: AppColors.vegBackground,
                  borderColor: AppColors.vegBorder,
                  icon: Icons.eco_rounded,
                ),
                const SizedBox(height: 20),

                // Total Requirement Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A0D5C46),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL REQUIREMENT',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white70,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Hostel Mess Food Count',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$totalRequirement',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Export Button for Kitchen Contractors
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WardenExportScreen(initialDate: _selectedDate),
                        ),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined,
                        color: AppColors.primary),
                    label: const Text(
                      'Export List for Mess Staff',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodSectionCard({
    required String title,
    required String dishName,
    required int categoryTotal,
    required int dishCount,
    required Color accentColor,
    required Color bgColor,
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: $categoryTotal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),

          // Dish Breakdown Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      dishName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$dishCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
