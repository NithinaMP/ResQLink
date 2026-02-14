import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../services/firestore_service.dart';

class NewIncidentScreen extends StatefulWidget {
  const NewIncidentScreen({super.key});

  @override
  State<NewIncidentScreen> createState() =>
      _NewIncidentScreenState();
}

class _NewIncidentScreenState extends State<NewIncidentScreen> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  String _selectedType = 'Fire';
  String _selectedPriority = 'High';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _incidentTypes = [
    {'type': 'Fire', 'icon': '🔥'},
    {'type': 'Accident', 'icon': '🚗'},
    {'type': 'Medical', 'icon': '🏥'},
    {'type': 'Flood', 'icon': '🌊'},
    {'type': 'Rescue', 'icon': '🆘'},
    {'type': 'Other', 'icon': '⚠️'},
  ];

  Future<void> _createIncident() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final incident = IncidentModel(
      id: '',
      callerPhone: _phoneController.text.trim(),
      incidentType: _selectedType,
      status: 'NEW',
      timestamp: DateTime.now(),
      address: _addressController.text.trim(),
    );

    final id = await _firestoreService.createIncident(incident);

    setState(() => _isLoading = false);

    if (id != null && mounted) {
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Incident created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to create incident!'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text(
          '🚨 New Incident',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Caller phone
              _sectionTitle('📞 Caller Phone Number'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Enter caller phone number',
                  Icons.phone,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter caller phone number';
                  }
                  if (val.length < 10) {
                    return 'Enter valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Location/Address
              _sectionTitle('📍 Incident Location'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: _inputDecoration(
                  'Enter address or landmark\n(e.g. Near KSRTC Bus Stand, Kothamangalam)',
                  Icons.location_on,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter incident location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Incident type
              _sectionTitle('🚒 Incident Type'),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2,
                ),
                itemCount: _incidentTypes.length,
                itemBuilder: (context, i) {
                  final type = _incidentTypes[i];
                  final isSelected = _selectedType == type['type'];
                  return GestureDetector(
                    onTap: () => setState(
                            () => _selectedType = type['type']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.red.withOpacity(0.3)
                            : const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.red
                              : Colors.grey[700]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${type['icon']} ${type['type']}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Priority
              _sectionTitle('⚡ Priority Level'),
              const SizedBox(height: 8),
              Row(
                children: ['High', 'Medium', 'Low'].map((p) {
                  final isSelected = _selectedPriority == p;
                  final color = p == 'High'
                      ? Colors.red
                      : p == 'Medium'
                      ? Colors.orange
                      : Colors.green;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedPriority = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                            isSelected ? color : Colors.grey[700]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            p,
                            style: TextStyle(
                              color:
                              isSelected ? color : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createIncident,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_alert, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Create Incident',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widgets
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF2a2a2a),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}