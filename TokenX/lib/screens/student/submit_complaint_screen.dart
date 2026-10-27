import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_colors.dart';
import '../../models/complaint_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({Key? key}) : super(key: key);

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _selectedDate;
  String? _selectedFoodItem;
  String? _selectedCategory;
  int _selectedRating = 0;
  bool _isSubmitting = false;

  final List<String> _recentDates = List.generate(7, (index) {
    final date = DateTime.now().subtract(Duration(days: index));
    return DateFormat('yyyy-MM-dd').format(date);
  });

  final List<String> _foodItems = [
    'Breakfast',
    'Lunch',
    'Snacks',
    'Dinner',
    'Special Meal'
  ];

  final List<String> _categories = [
    'Food Quality',
    'Quantity',
    'Temperature',
    'Hygiene',
    'Other'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception("User not logged in");

      final parsedDate = DateFormat('yyyy-MM-dd').parse(_selectedDate!);
      final dayString = DateFormat('EEEE').format(parsedDate);
      final uuid = const Uuid().v4();

      final complaint = ComplaintModel(
        complaintId: uuid,
        studentUid: user.uid,
        studentName: user.name ?? 'Student',
        studentEmail: user.email ?? '',
        tokenId: 'TOKEN_${uuid.substring(0, 8).toUpperCase()}',
        foodItem: _selectedFoodItem!,
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        rating: _selectedRating,
        date: _selectedDate!,
        day: dayString,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ComplaintService().createComplaint(complaint);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text('Complaint submitted successfully.\nID: ${complaint.complaintId.substring(0, 8)}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting complaint: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      value: _selectedDate,
                      hint: const Text('Select a date'),
                      items: _recentDates.map((date) {
                        return DropdownMenuItem(
                          value: date,
                          child: Text(date),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDate = val;
                        });
                      },
                      validator: (val) => val == null ? 'Please select a date' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Select Food Item',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      value: _selectedFoodItem,
                      hint: const Text('Select food item'),
                      items: _foodItems.map((food) {
                        return DropdownMenuItem(
                          value: food,
                          child: Text(food),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedFoodItem = val;
                        });
                      },
                      validator: (val) => val == null ? 'Please select a food item' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      value: _selectedCategory,
                      hint: const Text('Select category'),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                      validator: (val) => val == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Rating (1-5)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final ratingValue = index + 1;
                        return IconButton(
                          icon: Icon(
                            ratingValue <= _selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRating = ratingValue;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Describe the issue...',
                        contentPadding: EdgeInsets.all(12),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        if (val.length > 300) {
                          return 'Description must be at most 300 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitComplaint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit Complaint',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
