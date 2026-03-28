// // // lib/screens/map_web.dart
// // // Web-only implementation.
// // // Only compiled on web — never imported directly, always via map_platform.dart.
// //
// // // ignore: avoid_web_libraries_in_flutter
// // import 'dart:html' as html;
// // // ignore: avoid_web_libraries_in_flutter
// // import 'dart:ui_web' as ui;
// //
// // void registerIframeViewFactory(String viewId, String url) {
// //   final iframe = html.IFrameElement()
// //     ..src = url
// //     ..style.border = 'none'
// //     ..style.width = '100%'
// //     ..style.height = '100%'
// //     ..allowFullscreen = true;
// //   ui.platformViewRegistry.registerViewFactory(viewId, (_) => iframe);
// // }
// //
// // void openInNewTab(String url) {
// //   html.window.open(url, '_blank');
// // }
//
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:ui_web' as ui;
//
// void registerIframeViewFactory(String viewId, String url) {
//   final iframe = html.IFrameElement()
//     ..src = url
//     ..style.border = 'none'
//     ..style.width = '100%'
//     ..style.height = '100%'
//     ..allowFullscreen = true;
//
//   ui.platformViewRegistry.registerViewFactory(viewId, (_) => iframe);
// }
//
// void openInNewTab(String url) {
//   html.window.open(url, '_blank');
// }



// lib/screens/map_web.dart
// Web-only implementation

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;

void registerIframeViewFactory(String viewId, String url) {
  final iframe = html.IFrameElement()
    ..src = url
    ..style.border = 'none'
    ..style.width = '100%'
    ..style.height = '100%'
    ..allowFullscreen = true;

  // No sandbox lines - this removes the red underline
  ui.platformViewRegistry.registerViewFactory(viewId, (_) => iframe);
}

void openInNewTab(String url) {
  html.window.open(url, '_blank');
}