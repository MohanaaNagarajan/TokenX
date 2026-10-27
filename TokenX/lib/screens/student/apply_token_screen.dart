import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_config.dart';
import '../../models/menu_model.dart';
import '../../models/token_model.dart';
import '../../services/auth_service.dart';
import '../../services/token_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/food_card.dart';
import 'token_confirmation_screen.dart';

class ApplyTokenScreen extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialCategory;

  const ApplyTokenScreen({
    super.key,
    this.initialDate,
    this.initialCategory,
  });

  @override
  State<ApplyTokenScreen> createState() => _ApplyTokenScreenState();
}

class _ApplyTokenScreenState extends State<ApplyTokenScreen> {
  late DateTime _selectedDate;
  late String _selectedCategory; // 'Non-Vegetarian' or 'Vegetarian'
  final _tokenService = TokenService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to initialDate, or today (or tomorrow if today is Sunday)
    final now = DateTime.now();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    } else if (now.weekday == DateTime.sunday) {
      _selectedDate = now.add(const Duration(days: 1)); // Default Monday
    } else {
      _selectedDate = now;
    }

    _selectedCategory = widget.initialCategory ?? 'Non-Vegetarian';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
      selectableDayPredicate: (date) {
        // Disallow Sundays
        return date.weekday != DateTime.sunday;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked.weekday == DateTime.sunday) {
        _showSundayAlert();
        return;
      }
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
      });
    }
  }

  void _showSundayAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.accentOrange),
            SizedBox(width: 8),
            Text('Sunday Notice', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text(AppConfig.sundayMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApply() async {
    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to apply for tokens.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _tokenService.applyToken(
        student: user,
        targetDate: _selectedDate,
        category: _selectedCategory,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TokenConfirmationScreen(token: token),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);
    final deadlineError = TokenService.validateBookingDate(_selectedDate);
    final canApply = deadlineError == null;

    final nonVegDish = MenuModel.getFoodItem(_selectedDate, 'Non-Vegetarian');
    final vegDish = MenuModel.getFoodItem(_selectedDate, 'Vegetarian');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apply for Token'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper indicator (1 Date -> 2 Category -> 3 Confirm)
            _buildStepperHeader(),
            const SizedBox(height: 24),

            // Select Date Section
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 14,
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
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x04000000),
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
                        dateFormatted,
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

            // Error / Deadline Notice
            if (deadlineError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.nonVegBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.nonVegBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_off_rounded,
                        color: AppColors.nonVegRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        deadlineError,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.nonVegRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.nonVegBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.nonVegBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.nonVegRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.nonVegRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Choose Your Preference Section
            const Text(
              'Choose Your Preference',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Non-Vegetarian Radio Card
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = 'Non-Vegetarian';
                });
              },
              child: FoodSpecialCard(
                category: 'Non-Vegetarian',
                foodItem: nonVegDish,
                isRadioMode: true,
                isSelected: _selectedCategory == 'Non-Vegetarian',
              ),
            ),
            const SizedBox(height: 12),

            // Vegetarian Radio Card
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = 'Vegetarian';
                });
              },
              child: FoodSpecialCard(
                category: 'Vegetarian',
                foodItem: vegDish,
                isRadioMode: true,
                isSelected: _selectedCategory == 'Vegetarian',
              ),
            ),
            const SizedBox(height: 28),

            // Apply Token Button
            CustomButton(
              label: 'APPLY TOKEN',
              onPressed: canApply ? _handleApply : null,
              isLoading: _isLoading,
              backgroundColor: canApply ? AppColors.primary : AppColors.cardBorder,
              textColor: canApply ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(height: 14),

            // Footer Notice
            const Center(
              child: Text(
                '• Special-food tokens are available Monday to Saturday only.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepBadge('1', 'Date', isActive: true),
        _buildStepConnector(isCompleted: true),
        _buildStepBadge('2', 'Category', isActive: true),
        _buildStepConnector(isCompleted: false),
        _buildStepBadge('3', 'Confirm', isActive: false),
      ],
    );
  }

  Widget _buildStepBadge(String number, String title, {required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Container(
      width: 44,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16, left: 6, right: 6),
      color: isCompleted ? AppColors.primary : AppColors.divider,
    );
  }
}
