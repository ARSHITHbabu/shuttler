import 'package:intl/intl.dart';
import '../models/batch.dart';

/// Utility class for batch time operations
class BatchTimeUtils {
  /// Parse batch timing string (e.g., "6:00 AM - 7:30 AM") and extract end time
  /// Returns DateTime with today's date and the end time
  static DateTime? parseBatchEndTime(String timing) {
    try {
      // Parse timing like "6:00 AM - 7:30 AM" or "18:00 - 19:30"
      final parts = timing.split(' - ');
      if (parts.length != 2) return null;

      final endTimeStr = parts[1].trim();
      
      // Try parsing with AM/PM format first
      try {
        final timeFormat = DateFormat('h:mm a');
        final time = timeFormat.parse(endTimeStr);
        final now = DateTime.now();
        // Use the parsed hour and minute directly
        return DateTime(now.year, now.month, now.day, time.hour, time.minute);
      } catch (_) {
        // Try 24-hour format
        try {
          final timeParts = endTimeStr.split(':');
          if (timeParts.length == 2) {
            final hourStr = timeParts[0].trim();
            final minuteStr = timeParts[1].trim().split(' ')[0]; // Remove AM/PM if present
            final hour = int.parse(hourStr);
            final minute = int.parse(minuteStr);
            final now = DateTime.now();
            return DateTime(now.year, now.month, now.day, hour, minute);
          }
        } catch (_) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Check if a batch has finished based on current time
  static bool isBatchFinished(Batch batch) {
    final endTime = parseBatchEndTime(batch.timing);
    if (endTime == null) return false;
    
    final now = DateTime.now();
    return now.isAfter(endTime);
  }

  /// Check if a batch is upcoming (scheduled for today after current time or future days)
  static bool isBatchUpcoming(Batch batch) {
    final endTime = parseBatchEndTime(batch.timing);
    if (endTime == null) return false;
    
    final now = DateTime.now();
    return now.isBefore(endTime);
  }

  /// Get the next occurrence date for a batch based on its days
  static DateTime? getNextBatchDate(Batch batch) {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayDayName = dayNames[now.weekday - 1];
    
    // Check if batch runs today
    if (batch.days.contains(todayDayName)) {
      final endTime = parseBatchEndTime(batch.timing);
      if (endTime != null && now.isBefore(endTime)) {
        // Batch is today and hasn't finished
        return DateTime(now.year, now.month, now.day);
      }
    }
    
    // Find next occurrence
    for (int i = 1; i <= 7; i++) {
      final checkDate = now.add(Duration(days: i));
      final checkDayName = dayNames[checkDate.weekday - 1];
      if (batch.days.contains(checkDayName)) {
        return DateTime(checkDate.year, checkDate.month, checkDate.day);
      }
    }
    
    return null;
  }
}
