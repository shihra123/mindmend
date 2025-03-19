import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  @override
  _AdminAppointmentsScreenState createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('appointments').get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment status updated")),
      );

      setState(() {}); // Refresh the list after update
    } catch (e) {
      print("Error updating appointment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Appointments"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No appointments found"));
          }

          final appointments = snapshot.data!;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.person, "User: ${appointment['userName'] ?? 'Unknown'}"),
                      _buildDetailRow(Icons.healing, "Therapist: ${appointment['therapistName'] ?? 'Unknown'}"),
                      _buildDetailRow(Icons.date_range, "Date: ${appointment['date'] ?? 'Not specified'}"),
                      _buildDetailRow(Icons.access_time, "Time: ${appointment['time'] ?? 'Not specified'}"),
                      _buildDetailRow(Icons.confirmation_number, "Token No: ${appointment['tokenNo'] ?? 'N/A'}"),
                      _buildDetailRow(Icons.info, "Status: ${appointment['status'] ?? 'Pending'}"),

                      SizedBox(height: 15),

                      // Update Appointment Status Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => _updateAppointmentStatus(appointment['id'], "Confirmed"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Confirm", style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () => _updateAppointmentStatus(appointment['id'], "Cancelled"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Cancel", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
