/// Stub for dart:io on web platform
/// Provides minimal stubs to prevent compilation errors
/// These classes should never be instantiated on web - the code path is protected by kIsWeb check

/// Stub Directory class for web (should never be used)
class Directory {
  final String path;
  Directory(this.path);
  
  Future<bool> exists() async {
    throw UnsupportedError('Directory operations are not supported on web');
  }
  
  Future<Directory> create({bool recursive = false}) async {
    throw UnsupportedError('Directory operations are not supported on web');
  }
}

/// Stub File class for web (should never be used)
class File {
  final String path;
  File(this.path);
}
