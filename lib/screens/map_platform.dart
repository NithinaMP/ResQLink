// lib/screens/map_platform.dart
// Conditional import: picks the right implementation at compile time.
// On web  → map_web.dart  (real dart:html / dart:ui_web)
// On other → map_stub.dart (empty no-ops, so Android/iOS compile cleanly)

export 'map_stub.dart'
if (dart.library.html) 'map_web.dart';