import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/token_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';

class TokenDetailsScreen extends StatefulWidget {
  final TokenModel token;

  const TokenDetailsScreen({super.key, required this.token});

  @override
  State<TokenDetailsScreen> createState() => _TokenDetailsScreenState();
}

class _TokenDetailsScreenState extends State<TokenDetailsScreen> {
  late TokenModel _token;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
  }

  Future<void> _markAsRedeemed() async {
    setState(() => _isUpdating = true);
    try {
      await FirestoreService().updateTokenStatus(_token.documentId, 'Redeemed');
      setState(() {
        _token = _token.copyWith(status: 'Redeemed');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token marked as Redeemed successfully.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.nonVegRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNonVeg = _token.isNonVegetarian;
    final accentColor = isNonVeg ? AppColors.nonVegRed : AppColors.vegGreen;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Token Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Details Container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Token ID and Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _token.tokenId,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _token.status == 'Redeemed'
                              ? AppColors.redeemedBg
                              : AppColors.appliedBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _token.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _token.status == 'Redeemed'
                                ? AppColors.redeemedText
                                : AppColors.appliedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Student',
                    value: _token.studentName,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _token.studentEmail,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: _token.formattedDate,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: Icons.local_offer_outlined,
                    label: 'Category',
                    value: _token.category,
                    valueColor: accentColor,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: Icons.restaurant_rounded,
                    label: 'Food Item',
                    value: _token.foodItem,
                    valueColor: AppColors.textPrimary,
                    isBold: true,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Applied At',
                    value: _token.formattedAppliedAt,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Warden Action Button
            if (_token.status != 'Redeemed')
              CustomButton(
                label: 'MARK AS REDEEMED',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _markAsRedeemed,
                isLoading: _isUpdating,
                backgroundColor: AppColors.primary,
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.redeemedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.done_all_rounded,
                        color: AppColors.redeemedText, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Token has already been redeemed at mess counter.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.redeemedText,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
