import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/token_model.dart';
import '../../services/export_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';

class WardenExportScreen extends StatefulWidget {
  final DateTime? initialDate;

  const WardenExportScreen({super.key, this.initialDate});

  @override
  State<WardenExportScreen> createState() => _WardenExportScreenState();
}

class _WardenExportScreenState extends State<WardenExportScreen> {
  late DateTime _selectedDate;
  String _selectedCategory = 'All'; // 'All', 'Vegetarian', 'Non-Vegetarian'
  bool _isExporting = false;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

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

  Future<void> _handleExport(List<TokenModel> allTokens) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final filtered = allTokens.where((t) {
      if (t.date != dateStr) return false;
      if (_selectedCategory != 'All' && t.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No token records found for the selected filter.'),
          backgroundColor: AppColors.nonVegRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final result = await ExportService().exportAndShare(
        filtered,
        filenamePrefix: 'KRCT_Mess_${dateStr}_$_selectedCategory',
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.vegGreen),
              SizedBox(width: 8),
              Text('Export Complete', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Text(
            'Successfully exported ${filtered.length} token record(s) for ${DateFormat('d MMMM yyyy').format(_selectedDate)}.\n\nFile is ready for the hostel kitchen mess administration.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await ExportService.copyToClipboard(filtered);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CSV copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Copy to Clipboard'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Export Token Data',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<TokenModel>>(
        stream: _firestoreService.streamAllTokens(),
        builder: (context, snapshot) {
          final allTokens = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Select Date Card
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                const SizedBox(height: 24),

                // Category Filter Radio Options
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _buildRadioTile('All', 'All Categories (Combined)'),
                      const Divider(height: 1, indent: 56, color: AppColors.divider),
                      _buildRadioTile('Vegetarian', 'Vegetarian Only'),
                      const Divider(height: 1, indent: 56, color: AppColors.divider),
                      _buildRadioTile('Non-Vegetarian', 'Non-Vegetarian Only'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Export Button
                CustomButton(
                  label: 'EXPORT CSV',
                  icon: Icons.file_download_outlined,
                  onPressed: () => _handleExport(allTokens),
                  isLoading: _isExporting,
                  backgroundColor: AppColors.primary,
                ),
                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Filtered data will be exported as CSV file.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
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

  Widget _buildRadioTile(String value, String subtitle) {
    final isSelected = _selectedCategory == value;
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedCategory,
      onChanged: (val) {
        if (val != null) setState(() => _selectedCategory = val);
      },
      activeColor: AppColors.primary,
      title: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
      ),
    );
  }
}
