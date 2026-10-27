import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import 'warden_dashboard_screen.dart';
import 'warden_token_list_screen.dart';
import 'warden_summary_screen.dart';
import 'warden_complaints_screen.dart';
import 'warden_profile_screen.dart';

class WardenMainNav extends StatefulWidget {
  final int initialIndex;
  const WardenMainNav({super.key, this.initialIndex = 0});

  @override
  State<WardenMainNav> createState() => WardenMainNavState();
}

class WardenMainNavState extends State<WardenMainNav> {
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
      WardenDashboardScreen(onNavigateToTab: switchTab),
      const WardenTokenListScreen(),
      const WardenSummaryScreen(),
      const WardenComplaintsScreen(),
      const WardenProfileScreen(),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              activeIcon: Icon(Icons.format_list_bulleted_rounded),
              label: 'Tokens',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics_rounded),
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report_problem_outlined),
              activeIcon: Icon(Icons.report_problem_rounded),
              label: 'Complaints',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
