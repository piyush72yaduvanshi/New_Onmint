import 'package:intl/intl.dart';

class DateFormatter {
  /// Format date to human readable format like "Thursday 20th Feb 2026 4:20 PM"
  static String formatToHumanReadable(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Time TBD';
    }

    try {
      final dateTime = DateTime.parse(dateTimeString);
      
      // Get day name
      final dayName = DateFormat('EEEE').format(dateTime);
      
      // Get day with ordinal suffix
      final day = dateTime.day;
      final dayWithSuffix = _getDayWithOrdinalSuffix(day);
      
      // Get month name
      final monthName = DateFormat('MMM').format(dateTime);
      
      // Get year
      final year = dateTime.year;
      
      // Get time in 12-hour format
      final time = DateFormat('h:mm a').format(dateTime);
      
      return '$dayName $dayWithSuffix $monthName $year $time';
    } catch (e) {
      print('Error formatting date: $e');
      return dateTimeString;
    }
  }

  /// Format date for display in cards (shorter format)
  static String formatForCard(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Time TBD';
    }

    try {
      final dateTime = DateTime.parse(dateTimeString);
      
      // Check if it's today, tomorrow, or this week
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      
      final difference = appointmentDate.difference(today).inDays;
      
      final time = DateFormat('h:mm a').format(dateTime);
      
      if (difference == 0) {
        return 'Today $time';
      } else if (difference == 1) {
        return 'Tomorrow $time';
      } else if (difference < 7 && difference > 0) {
        final dayName = DateFormat('EEEE').format(dateTime);
        return '$dayName $time';
      } else {
        final shortDate = DateFormat('MMM d').format(dateTime);
        return '$shortDate $time';
      }
    } catch (e) {
      print('Error formatting date for card: $e');
      return dateTimeString;
    }
  }

  /// Get day with ordinal suffix (1st, 2nd, 3rd, 4th, etc.)
  static String _getDayWithOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  /// Format date for API (ISO format)
  static String formatForApi(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Parse API date string to DateTime
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing API date: $e');
      return null;
    }
  }

  /// Check if appointment is upcoming (within next 24 hours)
  static bool isUpcoming(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return false;
    }

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = dateTime.difference(now);
      
      return difference.inHours > 0 && difference.inHours <= 24;
    } catch (e) {
      return false;
    }
  }

  /// Check if appointment is overdue
  static bool isOverdue(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return false;
    }

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      
      return dateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  /// Get relative time (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Unknown time';
    }

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = dateTime.difference(now);
      
      if (difference.isNegative) {
        // Past time
        final absDifference = difference.abs();
        if (absDifference.inMinutes < 60) {
          return '${absDifference.inMinutes} minutes ago';
        } else if (absDifference.inHours < 24) {
          return '${absDifference.inHours} hours ago';
        } else {
          return '${absDifference.inDays} days ago';
        }
      } else {
        // Future time
        if (difference.inMinutes < 60) {
          return 'in ${difference.inMinutes} minutes';
        } else if (difference.inHours < 24) {
          return 'in ${difference.inHours} hours';
        } else {
          return 'in ${difference.inDays} days';
        }
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}