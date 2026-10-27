import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_config.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../student/student_main_nav.dart';
import '../warden/warden_main_nav.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // 1. Domain Validation Check
    if (!AuthService.isKrctEmail(email)) {
      setState(() {
        _errorMessage = AppConfig.invalidDomainError;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Role-based routing
      if (user.isWarden) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WardenMainNav()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentMainNav()),
        );
      }
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

  void _fillDemoCredentials(String roleKey) {
    final creds = AppConfig.demoAccounts[roleKey];
    if (creds != null) {
      _emailController.text = creds['email']!;
      _passwordController.text = creds['password']!;
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // KRCT College Logo Header
                const KrctCollegeLogo(),
                const SizedBox(height: 20),

                // Welcome to TokenX
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Token',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'X',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppConfig.appTagline,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Error Banner
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.nonVegBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.nonVegBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.nonVegRed,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.nonVegRed,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: 'College Email ID',
                        hint: 'student@krct.ac.in',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter password',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please contact KRCT Hostel Office to reset credentials.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Login Button
                      CustomButton(
                        label: 'Login',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        backgroundColor: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      
                      // Sign Up Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Allowed Domain Security Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.vegBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.vegBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 14,
                              color: AppColors.vegGreen,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Only @krct.ac.in accounts are allowed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.vegGreenDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Fast Viva Demonstration Chips
                      const Text(
                        'Demo Quick Login (Viva / Evaluation)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.person, size: 14, color: AppColors.primary),
                            label: const Text('Student', style: TextStyle(fontSize: 11)),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.cardBorder),
                            onPressed: () => _fillDemoCredentials('student1'),
                          ),
                          const SizedBox(width: 10),
                          ActionChip(
                            avatar: const Icon(Icons.shield_rounded, size: 14, color: AppColors.primary),
                            label: const Text('Warden', style: TextStyle(fontSize: 11)),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.cardBorder),
                            onPressed: () => _fillDemoCredentials('warden'),
                          ),
                        ],
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
