class IncidentModel {
  final String id;
  final String callerPhone;
  final double? latitude;
  final double? longitude;
  final String incidentType;
  final String status;
  final String timestamp;
  final String? address;

  IncidentModel({
    required this.id,
    required this.callerPhone,
    this.latitude,
    this.longitude,
    required this.incidentType,
    required this.status,
    required this.timestamp,
    this.address,
  });

  // Create from Firestore document
  factory IncidentModel.fromMap(Map<String, dynamic> map, String docId) {
    return IncidentModel(
      id: docId,
      callerPhone: map['callerPhone'] ?? 'Unknown',
      latitude: map['location']?['lat']?.toDouble(),
      longitude: map['location']?['lng']?.toDouble(),
      incidentType: map['incidentType'] ?? 'Unknown',
      status: map['status'] ?? 'NEW',
      timestamp: map['timestamp'] ?? '',
      address: map['address'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'callerPhone': callerPhone,
      'location': latitude != null ? {
        'lat': latitude,
        'lng': longitude,
      } : null,
      'incidentType': incidentType,
      'status': status,
      'timestamp': timestamp,
      'address': address,
    };
  }
}