import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/token_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/token_card.dart';
import 'student_main_nav.dart';

class TokenConfirmationScreen extends StatelessWidget {
  final TokenModel token;

  const TokenConfirmationScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration Success Checkmark
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Success Title
                const Text(
                  'TOKEN APPLIED\nSUCCESSFULLY!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                // Ticket Card with Notches and Dashes
                TokenTicketCard(token: token),
                const SizedBox(height: 28),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      CustomButton(
                        label: 'VIEW MY TOKENS',
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const StudentMainNav(initialIndex: 3),
                            ),
                            (route) => false,
                          );
                        },
                        backgroundColor: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const StudentMainNav(initialIndex: 0),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Go to Home',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
