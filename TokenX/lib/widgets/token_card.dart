import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/token_model.dart';

class TokenTicketCard extends StatelessWidget {
  final TokenModel token;

  const TokenTicketCard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final isNonVeg = token.isNonVegetarian;
    final accentColor = isNonVeg ? AppColors.nonVegRed : AppColors.vegGreen;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Header: Token ID & Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      token.tokenId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.appliedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.appliedText.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 13, color: AppColors.appliedText),
                      const SizedBox(width: 4),
                      Text(
                        token.status,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.appliedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashed Perforation Line with Side Notches
          _buildPerforationDivider(),

          // Token Details Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.primary,
                  label: 'Date',
                  value: token.formattedDate,
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  icon: Icons.local_offer_outlined,
                  iconColor: accentColor,
                  label: 'Category',
                  value: token.category,
                  valueColor: accentColor,
                  isBold: true,
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  icon: Icons.restaurant_rounded,
                  iconColor: accentColor,
                  label: 'Special Food',
                  value: token.foodItem,
                  valueColor: AppColors.textPrimary,
                  isBold: true,
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.textSecondary,
                  label: 'Student',
                  value: '${token.studentName}\n(${token.studentEmail})',
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.textMuted,
                  label: 'Applied At',
                  value: token.formattedAppliedAt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerforationDivider() {
    return Row(
      children: [
        // Left cutout notch
        Container(
          width: 14,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
        ),
        // Dashed line
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 5.0;
              const dashSpace = 4.0;
              final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  count,
                  (_) => const SizedBox(
                    width: dashWidth,
                    height: 1.2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.divider),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Right cutout notch
        Container(
          width: 14,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
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
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TokenListItemCard extends StatelessWidget {
  final TokenModel token;
  final VoidCallback? onTap;
  final bool showStudentInfo;

  const TokenListItemCard({
    super.key,
    required this.token,
    this.onTap,
    this.showStudentInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNonVeg = token.isNonVegetarian;
    final accentColor = isNonVeg ? AppColors.nonVegRed : AppColors.vegGreen;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Food Category Icon Thumbnail
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isNonVeg
                        ? AppColors.nonVegBackground
                        : AppColors.vegBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNonVeg
                          ? AppColors.nonVegBorder
                          : AppColors.vegBorder,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isNonVeg
                          ? Icons.lunch_dining_rounded
                          : Icons.eco_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            token.tokenId,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.appliedBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              token.status,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.appliedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (showStudentInfo) ...[
                        Text(
                          '${token.studentName} • ${token.studentEmail}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        '${token.foodItem} • ${token.category}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${token.shortFormattedDate} • ${token.formattedAppliedAt}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
