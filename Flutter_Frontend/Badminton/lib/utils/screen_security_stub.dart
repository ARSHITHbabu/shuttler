/// Stub for Screen Security on unsupported platforms
class ScreenSecurityImpl {
  static Future<void> protect() async {
    // No-op on unsupported platforms
  }
  
  static Future<void> unprotect() async {
    // No-op on unsupported platforms
  }
}
