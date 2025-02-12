import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [
    {
      "title": "Appointment Reminder",
      "message": "You have an appointment tomorrow at 10 AM.",
      "time": DateTime.now().subtract(Duration(hours: 1)),
      "isRead": false
    },
    {
      "title": "New Message",
      "message": "Dr. Smith sent you a message.",
      "time": DateTime.now().subtract(Duration(days: 1)),
      "isRead": false
    },
    {
      "title": "Therapist Available",
      "message": "Dr. Johnson has new available slots.",
      "time": DateTime.now().subtract(Duration(days: 2)),
      "isRead": true
    },
  ];

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]["isRead"] = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _notifications.isEmpty
            ? Center(
                child: Text(
                  "No new notifications!",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    color:
                        notification["isRead"] ? Colors.white70 : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.notifications,
                          color: Colors.deepOrangeAccent),
                      title: Text(notification["title"],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification["message"]),
                          SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy-MM-dd – hh:mm a')
                                .format(notification["time"]),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!notification["isRead"])
                            IconButton(
                              icon: Icon(Icons.done, color: Colors.green),
                              onPressed: () => _markAsRead(index),
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNotification(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
