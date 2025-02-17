import 'package:flutter/material.dart';

class TherapistAppointmentsScreen extends StatefulWidget {
  @override
  _TherapistAppointmentsScreenState createState() =>
      _TherapistAppointmentsScreenState();
}

class _TherapistAppointmentsScreenState
    extends State<TherapistAppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [
    {
      "client": "John Doe",
      "date": "2025-02-18",
      "time": "10:00 AM",
      "status": "Pending",
    },
    {
      "client": "Emma Smith",
      "date": "2025-02-19",
      "time": "2:30 PM",
      "status": "Confirmed",
    },
    {
      "client": "Michael Brown",
      "date": "2025-02-20",
      "time": "4:00 PM",
      "status": "Completed",
    },
  ];

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
                setState(() {
                  appointment["status"] = "Completed";
                });
                Navigator.pop(context);
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
        child: ListView.builder(
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
