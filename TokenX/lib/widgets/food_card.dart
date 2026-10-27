import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class FoodSpecialCard extends StatelessWidget {
  final String category; // 'Non-Vegetarian' or 'Vegetarian'
  final String foodItem;
  final VoidCallback? onApply;
  final bool isSelected;
  final bool isRadioMode;

  const FoodSpecialCard({
    super.key,
    required this.category,
    required this.foodItem,
    this.onApply,
    this.isSelected = false,
    this.isRadioMode = false,
  });

  bool get isNonVeg => category.toLowerCase().contains('non');

  @override
  Widget build(BuildContext context) {
    final bg = isNonVeg ? AppColors.nonVegBackground : AppColors.vegBackground;
    final border = isSelected
        ? AppColors.primary
        : (isNonVeg ? AppColors.nonVegBorder : AppColors.vegBorder);
    final accentColor = isNonVeg ? AppColors.nonVegRed : AppColors.vegGreen;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: isSelected ? 2 : 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: isRadioMode ? _buildRadioLayout(accentColor) : _buildHomeLayout(accentColor),
    );
  }

  Widget _buildHomeLayout(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNonVeg ? Icons.lunch_dining_rounded : Icons.eco_rounded,
                color: accentColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                category,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Food Thumbnail
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: accentColor.withOpacity(0.2), width: 2),
          ),
          child: Center(
            child: Icon(
              isNonVeg ? Icons.set_meal_rounded : Icons.grass_rounded,
              color: accentColor,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Food Item Name
        Text(
          foodItem,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (onApply != null)
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply Token',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRadioLayout(Color accentColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Center(
            child: Icon(
              isNonVeg ? Icons.lunch_dining_rounded : Icons.eco_rounded,
              color: accentColor,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                foodItem,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              width: 2,
            ),
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
