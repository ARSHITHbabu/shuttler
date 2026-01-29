/// Platform-agnostic path helper
/// Uses conditional imports to provide the right implementation

// Conditional imports
import 'path_helper_stub.dart'
    if (dart.library.io) 'path_helper_io.dart';

/// Get application documents directory path
/// Returns null on web (use web download methods instead)
Future<String?> getApplicationDocumentsPath() => getApplicationDocumentsPathImpl();
