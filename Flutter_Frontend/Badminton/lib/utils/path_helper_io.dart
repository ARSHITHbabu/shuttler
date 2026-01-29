import 'package:path_provider/path_provider.dart';

/// IO implementation for mobile/desktop platforms
/// Prioritizes Downloads directory for better user experience on mobile
Future<String?> getApplicationDocumentsPathImpl() async {
  try {
    // Try to get Downloads directory first (best for mobile UX)
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      return downloadsDir.path;
    }
  } catch (e) {
    // Downloads directory not available, continue to fallback
  }

  try {
    // Try external storage directory (Android) or Documents (iOS/Desktop)
    final externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      return externalDir.path;
    }
  } catch (e) {
    // External storage not available, continue to fallback
  }

  // Fallback to application documents directory
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}
