import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static String getConfidenceText(BuildContext context, double confidence) {
    final t = (AppLocalizations.of(context));
    if (confidence >= 0.9) return t.translate('veryHigh');
    if (confidence >= 0.7) return t.translate('high');
    if (confidence >= 0.5) return t.translate('medium');
    if (confidence >= 0.3) return t.translate('low');
    return t.translate('veryLow');
  }

  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static Future<bool> confirmDialog(
      BuildContext context, String title, String content) async {
    final appLocalizations = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(appLocalizations.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(appLocalizations.translate('confirm')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String getCropEmoji(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'maize':
        return '🌽';
      case 'rice':
        return '🌾';
      case 'wheat':
        return '🌾';
      case 'tomato':
        return '🍅';
      case 'potato':
        return '🥔';
      case 'beans':
        return '🫘';
      case 'cassava':
        return '🥔';
      case 'banana':
        return '🍌';
      default:
        return '🌱';
    }
  }

  static double calculateFileSizeInMB(String filePath) {
    final file = File(filePath);
    final sizeInBytes = file.lengthSync();
    return sizeInBytes / (1024 * 1024);
  }

  static bool isImageSizeValid(String filePath) {
    final sizeMB = calculateFileSizeInMB(filePath);
    return sizeMB <= 5; // 5MB limit
  }
}
