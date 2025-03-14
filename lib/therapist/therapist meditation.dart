import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MeditationScreen extends StatefulWidget {
  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  List<String> meditationSessions = [
    "Morning Calm - 10 min",
    "Stress Relief - 15 min",
    "Sleep Meditation - 20 min",
    "Focus Boost - 12 min",
    "Relaxation Guide - 18 min"
  ];

  List<Map<String, dynamic>> completedAppointments = [];

  final TextEditingController _sessionController = TextEditingController();
  String selectedMeditation = "";

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchCompletedAppointments();
  }

  // Fetch completed appointments from Firestore
  Future<void> _fetchCompletedAppointments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'Completed')
          .get();

      setState(() {
        completedAppointments = snapshot.docs
            .map((doc) => {
                  'client': doc['client'],
                  'date': doc['date'],
                  'time': doc['time'],
                  'appointmentId': doc.id,
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  void _addNewSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Meditation"),
        content: TextField(
          controller: _sessionController,
          decoration: const InputDecoration(hintText: "Enter session name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sessionController.clear();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_sessionController.text.isNotEmpty) {
                setState(() {
                  meditationSessions.add(_sessionController.text);
                });
                Navigator.pop(context);
                _sessionController.clear();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // Assign meditation session to completed client
  void _assignMeditationToClient(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Assign Meditation to ${appointment['client']}"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Choose a meditation session for ${appointment['client']}:"),
            DropdownButton<String>(
              value: selectedMeditation.isEmpty ? null : selectedMeditation,
              hint: const Text("Select Meditation"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMeditation = newValue!;
                });
                Navigator.pop(context); // Close dialog after selecting meditation
                // Here you can save the assignment to Firestore or any database
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Meditation session '$selectedMeditation' assigned to ${appointment['client']}"),
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Optionally, update Firestore with the selected meditation
                FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(appointment['appointmentId'])
                    .update({
                  'meditationAssigned': selectedMeditation,
                });
              },
              items: meditationSessions.map<DropdownMenuItem<String>>(
                (String session) {
                  return DropdownMenuItem<String>(
                    value: session,
                    child: Text(session),
                  );
                },
              ).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without doing anything
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meditation for Clients"),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addNewSession,
              icon: const Icon(Icons.add),
              label: const Text("Add Meditation Session"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Completed Appointments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: completedAppointments.length,
                itemBuilder: (context, index) {
                  var appointment = completedAppointments[index];
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.deepOrangeAccent),
                      title: Text(
                        appointment["client"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text("${appointment["date"]} - ${appointment["time"]}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow,
                            color: Colors.deepOrangeAccent),
                        onPressed: () =>
                            _assignMeditationToClient(appointment),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
