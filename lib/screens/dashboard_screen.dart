import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/incident_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'new_incident_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  Color _statusColor(String status) {
    switch (status) {
      case 'NEW': return Colors.red;
      case 'EN_ROUTE': return Colors.orange;
      case 'ON_SITE': return Colors.blue;
      case 'RESOLVED': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'NEW': return Icons.notification_important;
      case 'EN_ROUTE': return Icons.directions_car;
      case 'ON_SITE': return Icons.location_on;
      case 'RESOLVED': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  String _typeEmoji(String type) {
    switch (type) {
      case 'Fire': return '🔥';
      case 'Accident': return '🚗';
      case 'Medical': return '🏥';
      case 'Flood': return '🌊';
      case 'Rescue': return '🆘';
      default: return '⚠️';
    }
  }

  void _showStatusUpdate(IncidentModel incident) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2a2a2a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Incident Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...['NEW', 'EN_ROUTE', 'ON_SITE', 'RESOLVED']
                .map((status) => ListTile(
              leading: Icon(
                _statusIcon(status),
                color: _statusColor(status),
              ),
              title: Text(
                status.replaceAll('_', ' '),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: incident.status == status
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () async {
                await _firestoreService.updateStatus(
                    incident.id, status);
                if (mounted) Navigator.pop(context);
              },
            ))
                .toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              'ResQLink',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                FirebaseAuth.instance.currentUser?.email?.split('@')[0] ??
                    'Officer',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewIncidentScreen()),
        ),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text(
          'New Incident',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<List<IncidentModel>>(
        stream: _firestoreService.getIncidentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final incidents = snapshot.data ?? [];
          final active = incidents.where((i) => i.status == 'NEW').length;
          final enRoute = incidents.where((i) => i.status == 'EN_ROUTE').length;
          final resolved = incidents.where((i) => i.status == 'RESOLVED').length;

          return Column(
            children: [
              // Stats Row
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF2a2a2a),
                child: Row(
                  children: [
                    _statCard('🔴 Active', active.toString(), Colors.red),
                    const SizedBox(width: 10),
                    _statCard('🟠 En Route', enRoute.toString(), Colors.orange),
                    const SizedBox(width: 10),
                    _statCard('✅ Resolved', resolved.toString(), Colors.green),
                  ],
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Incidents',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${incidents.length} total',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: incidents.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, color: Colors.grey, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'No incidents yet',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Press "New Incident" when a call comes in',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: incidents.length,
                  itemBuilder: (context, i) =>
                      _incidentCard(incidents[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _incidentCard(IncidentModel incident) {
    return GestureDetector(
      onTap: () => _showStatusUpdate(incident),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _statusColor(incident.status).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Type and phone
                Row(
                  children: [
                    Text(
                      _typeEmoji(incident.incidentType),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.incidentType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '📞 ${incident.callerPhone}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(incident.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(incident.status)),
                  ),
                  child: Text(
                    incident.status.replaceAll('_', ' '),
                    style: TextStyle(
                      color: _statusColor(incident.status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Address
            if (incident.address != null && incident.address!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      incident.address!,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],

            // Location status indicator
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  incident.locationShared == true
                      ? Icons.location_on
                      : Icons.location_off,
                  color: incident.locationShared == true
                      ? Colors.green
                      : Colors.grey,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  incident.locationShared == true
                      ? 'Location received ✅'
                      : 'Waiting for location...',
                  style: TextStyle(
                    color: incident.locationShared == true
                        ? Colors.green
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ✅ NEW: Time + Tap hint row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time display
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.grey, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      incident.formattedTime, // ✅ Uses new formattedTime getter
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                // Tap hint
                const Row(
                  children: [
                    Icon(Icons.touch_app, color: Colors.grey, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Tap to update status',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}