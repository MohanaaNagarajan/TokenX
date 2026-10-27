import 'package:flutter/material.dart';
import 'package:tokenx/models/complaint_model.dart';
import 'package:tokenx/services/complaint_service.dart';

class WardenComplaintDetailsScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const WardenComplaintDetailsScreen({Key? key, required this.complaint}) : super(key: key);

  @override
  State<WardenComplaintDetailsScreen> createState() => _WardenComplaintDetailsScreenState();
}

class _WardenComplaintDetailsScreenState extends State<WardenComplaintDetailsScreen> {
  final TextEditingController _noteController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _updateStatus(String status) async {
    await _complaintService.updateStatus(widget.complaint.complaintId, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status')));
      Navigator.pop(context);
    }
  }

  void _addNote() async {
    final note = _noteController.text.trim();
    if (note.isNotEmpty) {
      await _complaintService.addWardenNote(widget.complaint.complaintId, note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added successfully')));
        _noteController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Name: ${widget.complaint.studentName}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Email: ${widget.complaint.studentEmail}'),
            const SizedBox(height: 8),
            Text('Food: ${widget.complaint.foodItem}'),
            const SizedBox(height: 8),
            Text('Category: ${widget.complaint.category}'),
            const SizedBox(height: 8),
            Text('Status: ${widget.complaint.status}'),
            const SizedBox(height: 8),
            Text('Priority: ${widget.complaint.priority}'),
            const SizedBox(height: 16),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.complaint.description),
            const SizedBox(height: 32),
            const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: () => _updateStatus('Under Review'), child: const Text('Under Review')),
                ElevatedButton(onPressed: () => _updateStatus('Resolved'), child: const Text('Resolved')),
                ElevatedButton(onPressed: () => _updateStatus('Closed'), child: const Text('Closed')),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Add Internal Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Enter warden note here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addNote, child: const Text('Add Note')),
          ],
        ),
      ),
    );
  }
}
