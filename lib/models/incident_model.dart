import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentModel {
  final String id;
  final String callerPhone;
  final double? latitude;
  final double? longitude;
  final String incidentType;
  final String status;
  final DateTime timestamp;
  final String? address;
  final bool? locationShared;

  IncidentModel({
    required this.id,
    required this.callerPhone,
    this.latitude,
    this.longitude,
    required this.incidentType,
    required this.status,
    required this.timestamp,
    this.address,
    this.locationShared,

  });

  // Create from Firestore document
  factory IncidentModel.fromMap(Map<String, dynamic> map, String docId) {
    // Fix: Handle BOTH Timestamp and String formats!
    DateTime parsedTime;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      // Firebase Timestamp object
      parsedTime = ts.toDate();
    } else if (ts is String) {
      // String format
      parsedTime = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      // Fallback
      parsedTime = DateTime.now();
    }

    return IncidentModel(
      id: docId,
      callerPhone: map['callerPhone'] ?? 'Unknown',
      latitude: map['location']?['lat']?.toDouble(),
      longitude: map['location']?['lng']?.toDouble(),
      incidentType: map['incidentType'] ?? 'Unknown',
      status: map['status'] ?? 'NEW',
      timestamp: parsedTime,
      address: map['address'],
      locationShared: map['locationShared'] ?? false,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'callerPhone': callerPhone,
      'location': latitude != null
          ? {
        'lat': latitude,
        'lng': longitude,
      }
          : null,
      'incidentType': incidentType,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp), // Store as Timestamp
      'address': address,
    };
  }

  // Format time for display
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}