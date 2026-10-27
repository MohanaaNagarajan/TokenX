import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import 'student_home.dart';
import 'weekly_menu_screen.dart';
import 'apply_token_screen.dart';
import 'my_tokens_screen.dart';
import 'student_profile_screen.dart';

class StudentMainNav extends StatefulWidget {
  final int initialIndex;
  const StudentMainNav({super.key, this.initialIndex = 0});

  @override
  State<StudentMainNav> createState() => StudentMainNavState();
}

class StudentMainNavState extends State<StudentMainNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      StudentHome(onNavigateToTab: switchTab),
      const WeeklyMenuScreen(),
      const ApplyTokenScreen(),
      const MyTokensScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_week_outlined),
              activeIcon: Icon(Icons.calendar_view_week_rounded),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Apply',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number_rounded),
              label: 'My Tokens',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
