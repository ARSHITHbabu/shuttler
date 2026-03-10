/// Platform-agnostic screen security helper
/// Prevents screenshots and screen recordings on sensitive screens (e.g. Fees)
/// Uses conditional imports to provide the right implementation
import 'screen_security_stub.dart'
    if (dart.library.io) 'screen_security_mobile.dart';

class ScreenSecurity {
  /// Enable screen protection (Android only)
  static Future<void> protect() => ScreenSecurityImpl.protect();
  
  /// Disable screen protection (Android only)
  static Future<void> unprotect() => ScreenSecurityImpl.unprotect();
}
