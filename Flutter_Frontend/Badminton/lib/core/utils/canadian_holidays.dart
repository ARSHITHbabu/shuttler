/// Canadian Federal Holidays Utility
/// Calculates all Canadian federal holidays for any given year
library;

class CanadianHolidays {
  /// Get all Canadian federal holidays for a given year
  static Map<DateTime, String> getHolidaysForYear(int year) {
    final holidays = <DateTime, String>{};
    
    // New Year's Day - January 1
    holidays[DateTime(year, 1, 1)] = "New Year's Day";
    
    // Good Friday - Friday before Easter Sunday
    final easter = _calculateEaster(year);
    final goodFriday = easter.subtract(const Duration(days: 2));
    holidays[goodFriday] = "Good Friday";
    
    // Easter Monday - Monday after Easter Sunday
    final easterMonday = easter.add(const Duration(days: 1));
    holidays[easterMonday] = "Easter Monday";
    
    // Victoria Day - Last Monday before May 25
    final victoriaDay = _getLastMondayBeforeMay25(year);
    holidays[victoriaDay] = "Victoria Day";
    
    // Canada Day - July 1
    holidays[DateTime(year, 7, 1)] = "Canada Day";
    
    // Labour Day - First Monday in September
    final labourDay = _getFirstMondayInSeptember(year);
    holidays[labourDay] = "Labour Day";
    
    // Thanksgiving - Second Monday in October
    final thanksgiving = _getSecondMondayInOctober(year);
    holidays[thanksgiving] = "Thanksgiving";
    
    // Remembrance Day - November 11
    holidays[DateTime(year, 11, 11)] = "Remembrance Day";
    
    // Christmas Day - December 25
    holidays[DateTime(year, 12, 25)] = "Christmas Day";
    
    // Boxing Day - December 26
    holidays[DateTime(year, 12, 26)] = "Boxing Day";
    
    return holidays;
  }
  
  /// Get holiday name for a specific date, or null if not a holiday
  static String? getHolidayName(DateTime date) {
    final holidays = getHolidaysForYear(date.year);
    final dateKey = DateTime(date.year, date.month, date.day);
    return holidays[dateKey];
  }
  
  /// Check if a date is a Canadian holiday
  static bool isHoliday(DateTime date) {
    return getHolidayName(date) != null;
  }
  
  /// Calculate Easter Sunday using the Computus algorithm
  static DateTime _calculateEaster(int year) {
    // Computus algorithm for calculating Easter
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }
  
  /// Get the last Monday before May 25 (Victoria Day)
  static DateTime _getLastMondayBeforeMay25(int year) {
    DateTime date = DateTime(year, 5, 25);
    // Go back to find the Monday
    while (date.weekday != DateTime.monday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }
  
  /// Get the first Monday in September (Labour Day)
  static DateTime _getFirstMondayInSeptember(int year) {
    DateTime date = DateTime(year, 9, 1);
    // Find the first Monday
    while (date.weekday != DateTime.monday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
  
  /// Get the second Monday in October (Thanksgiving)
  static DateTime _getSecondMondayInOctober(int year) {
    DateTime date = DateTime(year, 10, 1);
    // Find the first Monday
    while (date.weekday != DateTime.monday) {
      date = date.add(const Duration(days: 1));
    }
    // Add 7 days to get the second Monday
    return date.add(const Duration(days: 7));
  }
  
  /// Get all holidays for a date range
  static Map<DateTime, String> getHolidaysForDateRange(DateTime startDate, DateTime endDate) {
    final allHolidays = <DateTime, String>{};
    
    for (int year = startDate.year; year <= endDate.year; year++) {
      final yearHolidays = getHolidaysForYear(year);
      yearHolidays.forEach((date, name) {
        if (date.isAfter(startDate.subtract(const Duration(days: 1))) && 
            date.isBefore(endDate.add(const Duration(days: 1)))) {
          allHolidays[date] = name;
        }
      });
    }
    
    return allHolidays;
  }
}
