import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/incident_model.dart';

class MapScreen extends StatefulWidget {
  final IncidentModel incident;

  const MapScreen({super.key, required this.incident});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

  // Kothamangalam Fire Station
  // Update with exact coordinates!
  static const double _stationLat = 10.0603;
  static const double _stationLng = 76.6347;

  // Build map URL with parameters
  String get _mapUrl {
    final base = 'https://resqlink-eb041.web.app/map_view.html';
    final params = StringBuffer('?');

    // Add fire station coords
    params.write('slat=$_stationLat&slng=$_stationLng');

    // Add caller location if available
    if (widget.incident.latitude != null) {
      params.write('&clat=${widget.incident.latitude}');
      params.write('&clng=${widget.incident.longitude}');
    }

    // Add incident details
    params.write('&type=${widget.incident.incidentType}');
    params.write('&phone=${widget.incident.callerPhone}');
    params.write('&status=${widget.incident.status}');

    return base + params.toString();
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '📞 ${widget.incident.callerPhone}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView showing map
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_mapUrl),
            ),
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
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: const Color(0xFF1a1a1a),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Loading map...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}