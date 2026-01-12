import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Settings methods
  Future<void> setLanguage(String languageCode) async {
    final prefs = await _prefs;
    await prefs.setString('language', languageCode);
  }

  Future<String> getLanguage() async {
    final prefs = await _prefs;
    return prefs.getString('language') ?? 'en';
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool('notifications', enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool('notifications') ?? true;
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  /// More aggressive cleanup: clear shared prefs and delete files from
  /// app documents and temporary directories. Use this when user logs out
  /// and you want to remove all locally stored data.
  Future<void> clearAllExpanded() async {
    try {
      final prefs = await _prefs;
      await prefs.clear();
    } catch (e) {
      // ignore
    }

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      await _deleteDirectoryContents(docsDir);
    } catch (e) {
      // ignore
    }

    try {
      final tempDir = await getTemporaryDirectory();
      await _deleteDirectoryContents(tempDir);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _deleteDirectoryContents(Directory dir) async {
    if (!await dir.exists()) return;
    try {
      final children = dir.listSync();
      for (final child in children) {
        try {
          if (child is File) {
            await child.delete(recursive: true);
          } else if (child is Directory) {
            await child.delete(recursive: true);
          }
        } catch (_) {
          // ignore individual failures
        }
      }
    } catch (_) {
      // ignore
    }
  }
}
