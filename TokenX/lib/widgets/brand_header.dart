import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_config.dart';

class BrandHeader extends StatelessWidget {
  final bool showTagline;
  final double iconSize;

  const BrandHeader({
    super.key,
    this.showTagline = true,
    this.iconSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TokenX Chef Hat & Cloche Badge
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(iconSize * 0.28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0D5C46),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white,
              size: iconSize * 0.55,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // App Title
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Token',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'X',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          const Text(
            AppConfig.appTagline,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class KrctCollegeLogo extends StatelessWidget {
  const KrctCollegeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_balance_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          AppConfig.collegeShort,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const Text(
          AppConfig.collegeName,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
