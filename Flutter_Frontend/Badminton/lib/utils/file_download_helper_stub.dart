import 'dart:typed_data';

/// Stub implementation for non-web platforms
void downloadFileWeb(Uint8List bytes, String fileName, String mimeType) {
  throw UnsupportedError('Web download is only supported on web platform');
}
