import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_config.dart';
import '../../models/token_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/token_card.dart';
import 'token_details_screen.dart';

class WardenTokenListScreen extends StatefulWidget {
  const WardenTokenListScreen({super.key});

  @override
  State<WardenTokenListScreen> createState() => _WardenTokenListScreenState();
}

class _WardenTokenListScreenState extends State<WardenTokenListScreen> {
  final _searchController = TextEditingController();
  final _firestoreService = FirestoreService();

  String _searchQuery = '';
  String _dateFilter = 'All'; // 'All', 'Today', 'Tomorrow', 'Custom'
  DateTime? _customDate;
  String _categoryFilter = 'All'; // 'All', 'Vegetarian', 'Non-Vegetarian'
  String _statusFilter = 'All'; // 'All', 'Applied', 'Redeemed'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Student Token Applications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Input Field
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search student name / email / token ID',
                      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 20, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Date Filter Dropdown Chip
                      _buildFilterMenuChip(
                        label: _getDateFilterLabel(),
                        isActive: _dateFilter != 'All',
                        onSelected: (val) {
                          if (val == 'Custom') {
                            _selectCustomDate();
                          } else {
                            setState(() {
                              _dateFilter = val;
                              _customDate = null;
                            });
                          }
                        },
                        items: const ['All', 'Today', 'Tomorrow', 'Custom'],
                      ),
                      const SizedBox(width: 8),

                      // Category Filter Dropdown Chip
                      _buildFilterMenuChip(
                        label: _categoryFilter == 'All' ? 'Category: All' : _categoryFilter,
                        isActive: _categoryFilter != 'All',
                        onSelected: (val) => setState(() => _categoryFilter = val),
                        items: const ['All', 'Vegetarian', 'Non-Vegetarian'],
                      ),
                      const SizedBox(width: 8),

                      // Status Filter Dropdown Chip
                      _buildFilterMenuChip(
                        label: _statusFilter == 'All' ? 'Status: All' : _statusFilter,
                        isActive: _statusFilter != 'All',
                        onSelected: (val) => setState(() => _statusFilter = val),
                        items: const ['All', 'Applied', 'Redeemed'],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Real-time Applications Stream
          Expanded(
            child: StreamBuilder<List<TokenModel>>(
              stream: _firestoreService.streamAllTokens(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTokens = snapshot.data ?? [];

                // Filter tokens
                final filtered = allTokens.where((t) {
                  // Search query filter
                  if (_searchQuery.isNotEmpty) {
                    final matchName = t.studentName.toLowerCase().contains(_searchQuery);
                    final matchEmail = t.studentEmail.toLowerCase().contains(_searchQuery);
                    final matchId = t.tokenId.toLowerCase().contains(_searchQuery);
                    if (!matchName && !matchEmail && !matchId) return false;
                  }

                  // Date filter
                  if (_dateFilter == 'Today' && t.date != todayStr) return false;
                  if (_dateFilter == 'Tomorrow' && t.date != tomorrowStr) return false;
                  if (_dateFilter == 'Custom' && _customDate != null) {
                    final customStr = DateFormat('yyyy-MM-dd').format(_customDate!);
                    if (t.date != customStr) return false;
                  }

                  // Category filter
                  if (_categoryFilter != 'All' && t.category != _categoryFilter) return false;

                  // Status filter
                  if (_statusFilter != 'All' && t.status != _statusFilter) return false;

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: AppConfig.wardenEmptyTokens,
                    subtitle: 'Try changing your search keywords or resetting filters.',
                    actionLabel: 'Reset Filters',
                    onAction: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _dateFilter = 'All';
                        _customDate = null;
                        _categoryFilter = 'All';
                        _statusFilter = 'All';
                      });
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final token = filtered[index];
                    return TokenListItemCard(
                      token: token,
                      showStudentInfo: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TokenDetailsScreen(token: token),
                          ),
                        );
                      },
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

  String _getDateFilterLabel() {
    if (_dateFilter == 'Custom' && _customDate != null) {
      return DateFormat('dd MMM').format(_customDate!);
    }
    return _dateFilter == 'All' ? 'Date: All' : _dateFilter;
  }

  Widget _buildFilterMenuChip({
    required String label,
    required bool isActive,
    required void Function(String) onSelected,
    required List<String> items,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (ctx) => items
          .map((item) => PopupMenuItem(value: item, child: Text(item)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
            width: isActive ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _dateFilter = 'Custom';
        _customDate = picked;
      });
    }
  }
}
