import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_config.dart';
import '../../models/token_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/token_card.dart';
import 'apply_token_screen.dart';

class MyTokensScreen extends StatefulWidget {
  const MyTokensScreen({super.key});

  @override
  State<MyTokensScreen> createState() => _MyTokensScreenState();
}

class _MyTokensScreenState extends State<MyTokensScreen> {
  int _selectedSegment = 0; // 0: Upcoming, 1: History
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Tokens'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Segmented Tab Selector (Upcoming | History)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSegment = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedSegment == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedSegment == 0
                              ? const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Upcoming',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedSegment == 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedSegment == 0
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSegment = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedSegment == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedSegment == 1
                              ? const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'History',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedSegment == 1
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedSegment == 1
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tokens Stream List
          Expanded(
            child: user == null
                ? const EmptyStateWidget(
                    icon: Icons.person_off_rounded,
                    title: 'Not Logged In',
                    subtitle: 'Please log in to view your token history.',
                  )
                : StreamBuilder<List<TokenModel>>(
                    stream: _firestoreService.streamStudentTokens(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allTokens = snapshot.data ?? [];

                      final filteredTokens = allTokens.where((t) {
                        if (_selectedSegment == 0) {
                          // Upcoming: date >= today and not redeemed
                          return t.date.compareTo(todayStr) >= 0 &&
                              t.status == 'Applied';
                        } else {
                          // History: date < today or redeemed/cancelled
                          return t.date.compareTo(todayStr) < 0 ||
                              t.status != 'Applied';
                        }
                      }).toList();

                      if (filteredTokens.isEmpty) {
                        return EmptyStateWidget(
                          icon: Icons.confirmation_number_outlined,
                          title: AppConfig.studentEmptyTokens,
                          subtitle: _selectedSegment == 0
                              ? 'Apply for a special food token for today or later this week!'
                              : 'Your past mess tokens will show up here.',
                          actionLabel:
                              _selectedSegment == 0 ? 'Apply for Token' : null,
                          onAction: _selectedSegment == 0
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ApplyTokenScreen(),
                                    ),
                                  );
                                }
                              : null,
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: filteredTokens.length,
                        itemBuilder: (context, index) {
                          final token = filteredTokens[index];
                          return TokenListItemCard(
                            token: token,
                            onTap: () => _showTokenDetailsModal(context, token),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showTokenDetailsModal(BuildContext context, TokenModel token) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            TokenTicketCard(token: token),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
