import 'package:hive_flutter/hive_flutter.dart';
import '../models/session_history.dart';
import 'dart:convert';

class SessionHistoryService {
  static const String _historyBoxName = 'session_history';
  
  // Initialize Hive
  static Future<void> init() async {
    try {
      print("Initializing Hive...");
      await Hive.initFlutter();
      print("Opening Hive box: $_historyBoxName");
      await Hive.openBox(_historyBoxName);
      print("Hive box opened successfully");
      
      // Print all stored keys for debugging
      final box = Hive.box(_historyBoxName);
      print("Current keys in Hive: ${box.keys.toList()}");
    } catch (e) {
      print("Error initializing Hive: $e");
      // Try to recreate the box if there was an error
      try {
        await Hive.deleteBoxFromDisk(_historyBoxName);
        print("Deleted problematic box, recreating...");
        await Hive.openBox(_historyBoxName);
        print("Box recreated successfully");
      } catch (e2) {
        print("Failed to recreate box: $e2");
      }
    }
  }
  
  // Save session history for a day
  static Future<void> saveSessionHistory(SessionHistory history) async {
    try {
      final box = Hive.box(_historyBoxName);
      final json = history.toJson();
      final jsonString = jsonEncode(json);
      await box.put(history.date, jsonString);
      print("Successfully saved history for ${history.date} with ${history.sessions.length} sessions");
    } catch (e) {
      print("Error saving session history: $e");
    }
  }
  
  // Get session history for a specific day (returns null if not found)
  static SessionHistory? getSessionHistoryForDay(String date) {
    try {
      final box = Hive.box(_historyBoxName);
      final jsonString = box.get(date);
      print("Fetching history for $date, found: ${jsonString != null}");
      
      if (jsonString == null) return null;
      
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final history = SessionHistory.fromJson(map);
      print("Successfully loaded history for $date: ${history.sessions.length} sessions");
      return history;
    } catch (e) {
      print("Error getting session history for $date: $e");
      return null;
    }
  }
  
  // Get all session history
  static List<SessionHistory> getAllSessionHistory() {
    final box = Hive.box(_historyBoxName);
    final List<SessionHistory> result = [];
    
    print("Getting all session history. Keys: ${box.keys.toList()}");
    
    for (final key in box.keys) {
      try {
        final jsonString = box.get(key);
        if (jsonString != null) {
          final map = jsonDecode(jsonString) as Map<String, dynamic>;
          result.add(SessionHistory.fromJson(map));
        }
      } catch (e) {
        print("Error parsing session history for key $key: $e");
      }
    }
    
    print("Found ${result.length} historical sessions");
    return result;
  }
  
  // Get session history for a date range (inclusive)
  static List<SessionHistory> getSessionHistoryForRange(DateTime startDate, DateTime endDate) {
    final List<SessionHistory> result = [];
    final box = Hive.box(_historyBoxName);
    
    for (DateTime date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      try {
        final jsonString = box.get(dateKey);
        
        if (jsonString != null) {
          final map = jsonDecode(jsonString) as Map<String, dynamic>;
          result.add(SessionHistory.fromJson(map));
        }
      } catch (e) {
        print("Error parsing session history for $dateKey: $e");
      }
    }
    
    return result;
  }
  
  // Get the total duration in seconds for a specific day (returns 0 if not found)
  static int getTotalDurationForDay(String date) {
    try {
      final history = getSessionHistoryForDay(date);
      final duration = history?.totalDuration ?? 0;
      print("Total duration for $date: ${duration}s");
      return duration;
    } catch (e) {
      print("Error getting total duration for $date: $e");
      return 0;
    }
  }
  
  // Debug method to check all stored data
  static void debugPrintAllData() {
    try {
      final box = Hive.box(_historyBoxName);
      print("=== DEBUG: ALL STORED SESSION DATA ===");
      print("Box name: $_historyBoxName");
      print("Box is open: ${box.isOpen}");
      print("Total keys: ${box.keys.length}");
      
      for (final key in box.keys) {
        try {
          final value = box.get(key);
          if (value != null) {
            final map = jsonDecode(value) as Map<String, dynamic>;
            final history = SessionHistory.fromJson(map);
            print("$key: ${history.sessions.length} sessions, ${history.totalDuration}s total");
          } else {
            print("$key: null value");
          }
        } catch (e) {
          print("$key: Error parsing - $e");
        }
      }
      print("======================================");
    } catch (e) {
      print("Error in debugPrintAllData: $e");
    }
  }
} 