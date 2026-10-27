import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/token_model.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  // Convert tokens to CSV string
  static String generateCsvString(List<TokenModel> tokens) {
    final buffer = StringBuffer();
    // Header row
    buffer.writeln('Token ID,Student Name,Student Email,Date,Day,Category,Food Item,Applied At,Status');

    for (final token in tokens) {
      final safeName = _escapeCsv(token.studentName);
      final safeFood = _escapeCsv(token.foodItem);
      final applied = DateFormat('yyyy-MM-dd HH:mm:ss').format(token.appliedAt);

      buffer.writeln(
        '${token.tokenId},$safeName,${token.studentEmail},${token.date},${token.day},${token.category},$safeFood,$applied,${token.status}',
      );
    }

    return buffer.toString();
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  // Copy CSV to device clipboard
  static Future<void> copyToClipboard(List<TokenModel> tokens) async {
    final csv = generateCsvString(tokens);
    await Clipboard.setData(ClipboardData(text: csv));
  }

  // Share CSV file via system sheet
  Future<String> exportAndShare(List<TokenModel> tokens, {String? filenamePrefix}) async {
    final csvContent = generateCsvString(tokens);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${filenamePrefix ?? "TokenX_Mess_Tokens"}_$timestamp.csv';

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csvContent);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'KRCT Hostel Mess Token Export - $timestamp',
        subject: 'TokenX Mess Food Tokens ($timestamp)',
      );

      return file.path;
    } catch (_) {
      // Fallback: Copy to clipboard if file system or share sheet is restricted
      await Clipboard.setData(ClipboardData(text: csvContent));
      return 'copied_to_clipboard';
    }
  }
}
