import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TherapistAppointmentsScreen extends StatefulWidget {
  @override
  _TherapistAppointmentsScreenState createState() =>
      _TherapistAppointmentsScreenState();
}

class _TherapistAppointmentsScreenState
    extends State<TherapistAppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    User? user = _auth.currentUser; // Get the logged-in user
    if (user != null) {
      try {
        // Fetch appointments for the logged-in therapist from Firestore
        QuerySnapshot snapshot = await _firestore
            .collection('appointments')
            .where('therapistId', isEqualTo: user.uid) // filter by therapistId
            .get();

        List<Map<String, dynamic>> fetchedAppointments = snapshot.docs
            .map((doc) => {
                  "client": doc['clientName'],
                  "date": doc['date'],
                  "time": doc['time'],
                  "status": doc['status'],
                  "id": doc.id,
                })
            .toList();

        setState(() {
          appointments = fetchedAppointments; // Update state with fetched data
        });
      } catch (e) {
        print("Error fetching appointments: $e");
      }
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Appointment Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Client: ${appointment["client"]}"),
            Text("Date: ${appointment["date"]}"),
            Text("Time: ${appointment["time"]}"),
            Text("Status: ${appointment["status"]}"),
          ],
        ),
        actions: [
          if (appointment["status"] != "Completed")
            TextButton(
              onPressed: () {
                // Update appointment status to 'Completed' in Firestore
                _firestore
                    .collection('appointments')
                    .doc(appointment['id'])
                    .update({'status': 'Completed'}).then((_) {
                  setState(() {
                    appointment["status"] = "Completed";
                  });
                  Navigator.pop(context);
                });
              },
              child: Text("Mark as Completed"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Therapist Appointments"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: appointments.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading:
                          Icon(Icons.calendar_today, color: Colors.deepOrangeAccent),
                      title: Text(
                        appointment["client"],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text("${appointment["date"]} - ${appointment["time"]}"),
                      trailing: Text(
                        appointment["status"],
                        style: TextStyle(
                          color: appointment["status"] == "Completed"
                              ? Colors.green
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _showAppointmentDetails(appointment),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
