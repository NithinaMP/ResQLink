// lib/screens/map_stub.dart
// Stub implementations for non-web platforms.
// dart:html and dart:ui_web do not exist on Android/iOS,
// so this file provides empty stand-ins that satisfy the compiler.

void registerIframeViewFactory(String viewId, String url) {
  // No-op on non-web platforms
}

void openInNewTab(String url) {
  // No-op on non-web platforms
}