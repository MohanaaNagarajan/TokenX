import 'package:flutter/material.dart';
import 'package:tokenx/models/complaint_model.dart';
import 'package:tokenx/services/complaint_service.dart';
import 'warden_complaint_details_screen.dart';

class WardenComplaintsScreen extends StatefulWidget {
  const WardenComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<WardenComplaintsScreen> createState() => _WardenComplaintsScreenState();
}

class _WardenComplaintsScreenState extends State<WardenComplaintsScreen> {
  final ComplaintService _complaintService = ComplaintService();

  String _getPriorityBadge(int count) {
    if (count <= 5) return 'LOW';
    if (count <= 15) return 'MEDIUM';
    if (count <= 25) return 'HIGH';
    return 'CRITICAL';
  }

  Color _getBadgeColor(String badge) {
    switch (badge) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.deepOrange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warden Complaints')),
      body: StreamBuilder<List<ComplaintModel>>(
        stream: _complaintService.streamAllComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final complaints = snapshot.data ?? [];
          
          int total = complaints.length;
          int open = complaints.where((c) => c.status == 'Open').length;
          int underReview = complaints.where((c) => c.status == 'Under Review').length;
          int resolved = complaints.where((c) => c.status == 'Resolved').length;
          
          Map<String, List<ComplaintModel>> foodGroups = {};
          for (var c in complaints) {
            if (!foodGroups.containsKey(c.foodItem)) {
              foodGroups[c.foodItem] = [];
            }
            foodGroups[c.foodItem]!.add(c);
          }
          
          List<MapEntry<String, List<ComplaintModel>>> sortedFoods = foodGroups.entries.toList()
            ..sort((a, b) => b.value.length.compareTo(a.value.length));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildSummaryCard('Total', total, Colors.blue),
                      _buildSummaryCard('Open', open, Colors.orange),
                      _buildSummaryCard('Under Review', underReview, Colors.purple),
                      _buildSummaryCard('Resolved', resolved, Colors.green),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'MOST COMPLAINED FOODS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedFoods.length,
                  itemBuilder: (context, index) {
                    final food = sortedFoods[index].key;
                    final foodComplaints = sortedFoods[index].value;
                    final count = foodComplaints.length;
                    final badge = _getPriorityBadge(count);
                    
                    return ListTile(
                      title: Text(food),
                      subtitle: Text('Complaints: $count'),
                      trailing: Chip(
                        label: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: _getBadgeColor(badge),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WardenComplaintDetailsScreen(complaint: foodComplaints.first),
                          ),
                        );
                      },
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'ALL COMPLAINTS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return ListTile(
                      title: Text(complaint.foodItem),
                      subtitle: Text('${complaint.studentName} - ${complaint.status}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WardenComplaintDetailsScreen(complaint: complaint),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(count.toString(), style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
