import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/brand_header.dart';
import '../student/student_main_nav.dart';
import '../warden/warden_main_nav.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final user = AuthService().currentUser;
    if (user != null) {
      if (user.isWarden) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WardenMainNav()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentMainNav()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Top and Bottom subtle nature corner leaves
            Positioned(
              top: -20,
              left: -20,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.eco_rounded,
                  size: 160,
                  color: AppColors.primary,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: -20,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.eco_rounded,
                  size: 160,
                  color: AppColors.primary,
                ),
              ),
            ),

            // Main Brand Center
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const BrandHeader(
                    showTagline: true,
                    iconSize: 84,
                  ),
                ),
              ),
            ),

            // College Bottom Branding
            const Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: KrctCollegeLogo(),
            ),
          ],
        ),
      ),
    );
  }
}
