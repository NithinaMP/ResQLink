// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import '../models/incident_model.dart';
//
// class MapScreen extends StatefulWidget {
//   final IncidentModel incident;
//
//   const MapScreen({super.key, required this.incident});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   InAppWebViewController? _webViewController;
//   bool _isLoading = true;
//
//   // Kothamangalam Fire Station
//   // Update with exact coordinates!
//   static const double _stationLat = 10.0603;
//   static const double _stationLng = 76.6347;
//
//   // Build map URL with parameters
//   String get _mapUrl {
//     final base = 'https://resqlink-eb041.web.app/map_view.html';
//     final params = StringBuffer('?');
//
//     // Add fire station coords
//     params.write('slat=$_stationLat&slng=$_stationLng');
//
//     // Add caller location if available
//     if (widget.incident.latitude != null) {
//       params.write('&clat=${widget.incident.latitude}');
//       params.write('&clng=${widget.incident.longitude}');
//     }
//
//     // Add incident details
//     params.write('&type=${widget.incident.incidentType}');
//     params.write('&phone=${widget.incident.callerPhone}');
//     params.write('&status=${widget.incident.status}');
//
//     return base + params.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1a1a1a),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2a2a2a),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '🗺️ ${widget.incident.incidentType} - Map View',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               '📞 ${widget.incident.callerPhone}',
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           // Refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: () {
//               _webViewController?.reload();
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // WebView showing map
//           InAppWebView(
//             initialUrlRequest: URLRequest(
//               url: WebUri(_mapUrl),
//             ),
//             initialSettings: InAppWebViewSettings(
//               javaScriptEnabled: true,
//               useShouldOverrideUrlLoading: true,
//             ),
//             onWebViewCreated: (controller) {
//               _webViewController = controller;
//             },
//             onLoadStop: (controller, url) {
//               setState(() => _isLoading = false);
//             },
//           ),
//
//           // Loading indicator
//           if (_isLoading)
//             Container(
//               color: const Color(0xFF1a1a1a),
//               child: const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(color: Colors.red),
//                     SizedBox(height: 16),
//                     Text(
//                       'Loading map...',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }



// lib/screens/map_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import '../models/incident_model.dart';
// import 'map_platform.dart'; // ← Platform-specific bridge
//
// class MapScreen extends StatefulWidget {
//   final IncidentModel incident;
//   const MapScreen({super.key, required this.incident});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   // ── Constants ──────────────────────────────────────────────────
//   static const double _stationLat = 10.0603;
//   static const double _stationLng = 76.6347;
//
//   // Colour palette
//   static const Color _bg      = Color(0xFF1a1a1a);
//   static const Color _surface = Color(0xFF2a2a2a);
//   static const Color _accent  = Color(0xFFE53935);
//   static const Color _textPri = Colors.white;
//   static const Color _textSec = Colors.grey;
//
//   // ── State ──────────────────────────────────────────────────────
//   late String _viewId;
//   bool _isRegistered = false;
//   bool _isMapLoading = true;
//   bool _hasMapError  = false;
//   int  _refreshCount = 0;
//
//   // ── URL builder ────────────────────────────────────────────────
//   String get _mapUrl {
//     final buf = StringBuffer(
//       'https://resqlink-eb041.web.app/map_view.html?'
//           'slat=$_stationLat&slng=$_stationLng',
//     );
//     if (widget.incident.latitude != null) {
//       buf.write(
//         '&clat=${widget.incident.latitude}'
//             '&clng=${widget.incident.longitude}',
//       );
//     }
//     buf
//       ..write('&type=${Uri.encodeComponent(widget.incident.incidentType)}')
//       ..write('&phone=${Uri.encodeComponent(widget.incident.callerPhone)}')
//       ..write('&status=${Uri.encodeComponent(widget.incident.status)}')
//       ..write('&t=${DateTime.now().millisecondsSinceEpoch}');
//     return buf.toString();
//   }
//
//   // ── Helpers ────────────────────────────────────────────────────
//   Color get _statusColor {
//     switch (widget.incident.status.toLowerCase()) {
//       case 'new':
//       case 'active':    return Colors.red;
//       case 'en_route':  return Colors.orange;
//       case 'on_site':   return Colors.blue;
//       case 'resolved':  return Colors.green;
//       default:          return Colors.grey;
//     }
//   }
//
//   IconData get _incidentIcon {
//     switch (widget.incident.incidentType.toLowerCase()) {
//       case 'fire':     return Icons.local_fire_department;
//       case 'medical':  return Icons.medical_services;
//       case 'accident': return Icons.car_crash;
//       case 'flood':    return Icons.water;
//       case 'rescue':   return Icons.sos;
//       default:         return Icons.warning_amber_rounded;
//     }
//   }
//
//   // ── Map registration (web only via bridge) ─────────────────────
//   void _registerMap() {
//     if (_isRegistered) return;
//     _isRegistered = true;
//
//     try {
//       // On web  → map_web.dart creates real iframe
//       // On mobile → map_stub.dart is no-op (mobile uses InAppWebView fallback)
//       registerIframeViewFactory(_viewId, _mapUrl);
//
//       // Safety timeout — hide spinner after 10s
//       Future.delayed(const Duration(seconds: 10), () {
//         if (mounted && _isMapLoading) {
//           setState(() => _isMapLoading = false);
//         }
//       });
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isMapLoading = false;
//           _hasMapError  = true;
//         });
//       }
//     }
//   }
//
//   // ── Lifecycle ──────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _viewId = 'map-${DateTime.now().millisecondsSinceEpoch}';
//     if (kIsWeb) _registerMap();
//   }
//
//   void _reloadMap() {
//     setState(() {
//       _refreshCount++;
//       _viewId       = 'map-${DateTime.now().millisecondsSinceEpoch}-$_refreshCount';
//       _isRegistered = false;
//       _isMapLoading = true;
//       _hasMapError  = false;
//     });
//     if (kIsWeb) _registerMap();
//   }
//
//   // ── Build ──────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildInfoBar(),
//           Expanded(child: _buildMapArea()),
//           _buildBottomBar(),
//         ],
//       ),
//     );
//   }
//
//   // ── AppBar ─────────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: _surface,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new, color: _textPri, size: 20),
//         onPressed: () => Navigator.pop(context),
//         tooltip: 'Back',
//       ),
//       title: Row(
//         children: [
//           Icon(_incidentIcon, color: _accent, size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${widget.incident.incidentType} — Map View',
//                   style: const TextStyle(
//                     color: _textPri,
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   '📞 ${widget.incident.callerPhone}',
//                   style: const TextStyle(color: _textSec, fontSize: 11),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         _StatusBadge(
//           label: widget.incident.latitude != null ? '📍 GPS Found' : '⏳ No GPS',
//           color: widget.incident.latitude != null ? Colors.green : Colors.orange,
//         ),
//         IconButton(
//           icon: const Icon(Icons.refresh, color: _textPri),
//           tooltip: 'Reload map',
//           onPressed: _reloadMap,
//         ),
//         if (kIsWeb)
//           IconButton(
//             icon: const Icon(Icons.open_in_new, color: _textPri),
//             tooltip: 'Open in new tab',
//             onPressed: () => openInNewTab(_mapUrl),
//           ),
//       ],
//     );
//   }
//
//   // ── Info bar ───────────────────────────────────────────────────
//   Widget _buildInfoBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       color: _surface,
//       child: Row(
//         children: [
//           _Chip(label: widget.incident.incidentType, icon: _incidentIcon, color: _accent),
//           const SizedBox(width: 8),
//           _Chip(label: widget.incident.status.toUpperCase().replaceAll('_', ' '), color: _statusColor),
//           const SizedBox(width: 8),
//           if (widget.incident.address != null)
//             Expanded(
//               child: Row(
//                 children: [
//                   const Icon(Icons.location_on, color: _textSec, size: 14),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       widget.incident.address!,
//                       style: const TextStyle(color: _textSec, fontSize: 12),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ── Map area ───────────────────────────────────────────────────
//   Widget _buildMapArea() {
//     if (!kIsWeb) return _mobileMapView();
//
//     return Stack(
//       children: [
//         HtmlElementView(viewType: _viewId),
//
//         // Loading overlay
//         if (_isMapLoading)
//           Container(
//             color: _bg,
//             child: const Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(color: _accent),
//                   SizedBox(height: 16),
//                   Text('Loading map…',
//                       style: TextStyle(color: _textSec, fontSize: 14)),
//                 ],
//               ),
//             ),
//           ),
//
//         // Error overlay
//         if (_hasMapError)
//           Container(
//             color: _bg,
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.map_outlined, color: _textSec, size: 64),
//                   const SizedBox(height: 16),
//                   const Text('Failed to load map',
//                       style: TextStyle(
//                           color: _textPri,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   const Text('Check your network connection',
//                       style: TextStyle(color: _textSec, fontSize: 13)),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: _reloadMap,
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Retry'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _accent,
//                       foregroundColor: _textPri,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   // ── Bottom bar ─────────────────────────────────────────────────
//   Widget _buildBottomBar() {
//     if (widget.incident.latitude == null) return const SizedBox.shrink();
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: _surface,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.my_location, color: _accent, size: 14),
//               const SizedBox(width: 6),
//               Text(
//                 'Lat: ${widget.incident.latitude!.toStringAsFixed(5)}  '
//                     'Lng: ${widget.incident.longitude!.toStringAsFixed(5)}',
//                 style: const TextStyle(color: _textSec, fontSize: 12),
//               ),
//             ],
//           ),
//           if (widget.incident.locationShared == true)
//             const Row(
//               children: [
//                 Icon(Icons.share_location, color: Colors.green, size: 14),
//                 SizedBox(width: 4),
//                 Text(
//                   'Location Shared',
//                   style: TextStyle(
//                       color: Colors.green,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ── Mobile fallback ────────────────────────────────────────────
//   Widget _mobileMapView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(_incidentIcon, color: _accent, size: 72),
//             const SizedBox(height: 20),
//             const Text(
//               'Map View',
//               style: TextStyle(
//                   color: _textPri, fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(widget.incident.incidentType,
//                 style: const TextStyle(color: _textSec, fontSize: 14)),
//             const SizedBox(height: 24),
//             if (widget.incident.latitude != null) ...[
//               _CoordRow(
//                   label: 'Caller',
//                   lat: widget.incident.latitude!,
//                   lng: widget.incident.longitude!),
//               const SizedBox(height: 8),
//               _CoordRow(
//                   label: 'Station',
//                   lat: _stationLat,
//                   lng: _stationLng,
//                   color: Colors.blue),
//               const SizedBox(height: 28),
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue.withOpacity(0.4)),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.blue, size: 16),
//                     SizedBox(width: 8),
//                     Text(
//                       'Interactive map available on web',
//                       style: TextStyle(color: Colors.blue, fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ),
//             ] else ...[
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.orange.withOpacity(0.4)),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.location_off, color: Colors.orange),
//                     SizedBox(width: 10),
//                     Text('Location not shared yet',
//                         style: TextStyle(color: Colors.orange)),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ── Reusable widgets ──────────────────────────────────────────────
//
// class _StatusBadge extends StatelessWidget {
//   const _StatusBadge({required this.label, required this.color});
//   final String label;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.7)),
//       ),
//       child: Text(label,
//           style: TextStyle(
//               color: color, fontSize: 11, fontWeight: FontWeight.bold)),
//     );
//   }
// }
//
// class _Chip extends StatelessWidget {
//   const _Chip({required this.label, required this.color, this.icon});
//   final String label;
//   final Color color;
//   final IconData? icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.6)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (icon != null) ...[
//             Icon(icon, color: color, size: 13),
//             const SizedBox(width: 4),
//           ],
//           Text(label,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }
//
// class _CoordRow extends StatelessWidget {
//   const _CoordRow({
//     required this.label,
//     required this.lat,
//     required this.lng,
//     this.color = Colors.red,
//   });
//   final String label;
//   final double lat;
//   final double lng;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(Icons.location_pin, color: color, size: 16),
//         const SizedBox(width: 6),
//         Text(
//           '$label: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
//           style: const TextStyle(color: Colors.white70, fontSize: 13),
//         ),
//       ],
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/incident_model.dart';
import 'map_platform.dart';           // your existing platform bridge
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
if (dart.library.html) 'inappwebview_stub.dart';   // ← Important for web

class MapScreen extends StatefulWidget {
  final IncidentModel incident;
  const MapScreen({super.key, required this.incident});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

  static const double _stationLat = 10.0603;
  static const double _stationLng = 76.6347;

  String get _mapUrl {
    final base = 'https://resqlink-eb041.web.app/map_view.html';
    final params = StringBuffer('?slat=$_stationLat&slng=$_stationLng');

    if (widget.incident.latitude != null) {
      params.write('&clat=${widget.incident.latitude}&clng=${widget.incident.longitude}');
    }

    params
      ..write('&type=${Uri.encodeComponent(widget.incident.incidentType)}')
      ..write('&phone=${Uri.encodeComponent(widget.incident.callerPhone)}')
      ..write('&status=${Uri.encodeComponent(widget.incident.status)}')
      ..write('&t=${DateTime.now().millisecondsSinceEpoch}');   // cache bust

    return base + params.toString();
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Register iframe for web
      _registerWebMap();
    }
  }

  void _registerWebMap() {
    try {
      registerIframeViewFactory('resq-map-${DateTime.now().millisecondsSinceEpoch}', _mapUrl);
    } catch (e) {
      debugPrint('Map registration error: $e');
    }
  }

  void _reloadMap() {
    setState(() {
      _isLoading = true;
    });
    if (kIsWeb) {
      _registerWebMap();
    } else {
      _webViewController?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2a2a2a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🗺️ ${widget.incident.incidentType} - Map View',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '📞 ${widget.incident.callerPhone}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reloadMap,
          ),
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              onPressed: () => openInNewTab(_mapUrl),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map View (different implementation per platform) ──
          if (kIsWeb)
            HtmlElementView(viewType: 'resq-map-${DateTime.now().millisecondsSinceEpoch}')  // you may need to adjust viewId logic
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_mapUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStop: (controller, url) {
                setState(() => _isLoading = false);
              },
              onLoadError: (controller, url, code, message) {
                debugPrint('WebView error: $message');
              },
            ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: const Color(0xFF1a1a1a),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 16),
                    Text('Loading map...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}