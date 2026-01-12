/// Environment configuration for the Badminton Academy Management App
///
/// This file contains environment-specific settings that should be configured
/// based on your development setup or production deployment.
///
/// IMPORTANT FOR DEVELOPERS:
/// ========================
/// When working on a different computer or network:
/// 1. Run 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux) in terminal
/// 2. Find your computer's IPv4 Address (e.g., 192.168.1.7)
/// 3. Update the 'developmentIp' value below with YOUR IP address
/// 4. Save this file and hot reload your Flutter app (press 'r' in terminal)
///
class Environment {
  // ==================== DEVELOPMENT / PRODUCTION MODE ====================

  /// Set to true for development (local backend)
  /// Set to false for production (deployed backend on cloud)
  static const bool isDevelopment = true;

  // ==================== BACKEND CONFIGURATION ====================

  /// YOUR COMPUTER'S LOCAL IP ADDRESS
  ///
  /// To find your IP address:
  /// - Windows: Open Command Prompt and run 'ipconfig'
  ///   Look for "IPv4 Address" under your Wi-Fi or Ethernet adapter
  /// - Mac: Open Terminal and run 'ifconfig'
  ///   Look for "inet" under your active network interface (en0 or en1)
  /// - Linux: Open Terminal and run 'ifconfig' or 'ip addr'
  ///   Look for "inet" under your active network interface
  ///
  /// Example: If your IP is 192.168.1.15, change the line below to:
  /// static const String developmentIp = '192.168.1.15';
  static const String developmentIp = ''; // ← CHANGE THIS TO YOUR IP

  /// Backend server port (usually 8000 for FastAPI)
  static const int port = 8000;

  /// Production backend URL (when deployed to cloud)
  /// Update this when you deploy your backend to Heroku, AWS, etc.
  /// Example: 'https://badminton-api.herokuapp.com'
  static const String productionUrl = 'https://api.yourdomain.com';

  // ==================== AUTOMATIC URL SELECTION ====================

  /// Returns the appropriate API base URL based on environment
  ///
  /// In development mode: Returns http://YOUR_IP:8000
  /// In production mode: Returns the production URL
  static String get apiBaseUrl {
    if (isDevelopment) {
      // Development mode: Use local network IP for testing on phone
      return 'http://$developmentIp:$port';
    } else {
      // Production mode: Use cloud server URL
      return productionUrl;
    }
  }

  // ==================== DEBUGGING ====================

  /// Get current environment information (useful for debugging)
  static Map<String, dynamic> get info => {
        'mode': isDevelopment ? 'Development' : 'Production',
        'baseUrl': apiBaseUrl,
        'developmentIp': developmentIp,
        'port': port,
        'productionUrl': productionUrl,
      };

  /// Print current environment configuration (for debugging)
  static void printConfig() {
    print('🔧 Environment Configuration:');
    print('   Mode: ${isDevelopment ? 'Development' : 'Production'}');
    print('   Base URL: $apiBaseUrl');
    if (isDevelopment) {
      print('   Development IP: $developmentIp');
      print('   Port: $port');
    }
  }
}
