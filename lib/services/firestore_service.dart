import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create new incident
  Future<String?> createIncident(IncidentModel incident) async {
    try {
      DocumentReference ref = await _db
          .collection('incidents')
          .add(incident.toMap());
      return ref.id;
    } catch (e) {
      print('Error creating incident: $e');
      return null;
    }
  }

  // Get real-time stream of incidents
  Stream<List<IncidentModel>> getIncidentsStream() {
    return _db
        .collection('incidents')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => IncidentModel.fromMap(
        doc.data(), doc.id))
        .toList());
  }

  // Update incident status
  Future<void> updateStatus(String id, String status) async {
    try {
      await _db
          .collection('incidents')
          .doc(id)
          .update({'status': status});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // Get counts for stats
  Future<Map<String, int>> getIncidentCounts() async {
    try {
      final snapshot = await _db.collection('incidents').get();
      int active = 0, enRoute = 0, resolved = 0;
      for (var doc in snapshot.docs) {
        final status = doc.data()['status'];
        if (status == 'NEW') active++;
        else if (status == 'EN_ROUTE') enRoute++;
        else if (status == 'RESOLVED') resolved++;
      }
      return {
        'active': active,
        'enRoute': enRoute,
        'resolved': resolved
      };
    } catch (e) {
      return {'active': 0, 'enRoute': 0, 'resolved': 0};
    }
  }
}