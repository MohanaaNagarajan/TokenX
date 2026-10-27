import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../student/student_main_nav.dart';
import '../warden/warden_main_nav.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedDept = 'Computer Science and Engineering';
  String _selectedYear = 'I Year';
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final List<String> _departments = [
    'Computer Science and Engineering',
    'Electronics & Communication',
    'Electrical & Electronics',
    'Information Technology',
    'Mechanical Engineering',
    'Civil Engineering',
    'Artificial Intelligence & Data Science'
  ];

  final List<String> _years = ['I Year', 'II Year', 'III Year', 'IV Year'];

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        department: _selectedDept,
        year: _selectedYear,
      );

      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => user.isWarden 
            ? const WardenMainNav() 
            : const StudentMainNav(),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register your college email ID to proceed.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Name Field
                const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Enter your full name', Icons.person_outline),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Email Field
                const Text('College Email ID', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('name.dept23@krct.ac.in', Icons.email_outlined),
                  validator: AuthService.validateCollegeEmail,
                ),
                const SizedBox(height: 16),

                // Password Field
                const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration('Create a strong password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                // Department Dropdown
                const Text('Department', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDept,
                  decoration: _inputDecoration('', Icons.business_center_outlined).copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (val) => setState(() => _selectedDept = val!),
                ),
                const SizedBox(height: 16),

                // Year Dropdown
                const Text('Year of Study', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: _inputDecoration('', Icons.school_outlined).copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (val) => setState(() => _selectedYear = val!),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
