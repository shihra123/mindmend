import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;  // Assuming you pass the logged-in userId to this screen
  
  NotificationsScreen({required this.userId});
  
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  // Firestore reference for notifications
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen for real-time updates of the notifications collection
  Stream<QuerySnapshot> _notificationsStream() {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: widget.userId)  // Filter by current logged-in user
        .orderBy('time', descending: true)  // Sort by most recent notifications
        .snapshots();
  }

  // Mark the notification as read in Firestore
  Future<void> _markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Delete the notification from Firestore
  Future<void> _deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _notificationsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final notifications = snapshot.data!.docs;

            if (notifications.isEmpty) {
              return Center(
                child: Text(
                  "No new notifications!",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['isRead'] ?? false;
                final notificationId = notification.id;
                final title = notification['title'];
                final message = notification['message'];
                final time = (notification['time'] as Timestamp).toDate();

                return Card(
                  color: isRead ? Colors.white70 : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.notifications,
                        color: Colors.deepOrangeAccent),
                    title: Text(title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd – hh:mm a').format(time),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isRead)
                          IconButton(
                            icon: Icon(Icons.done, color: Colors.green),
                            onPressed: () => _markAsRead(notificationId),
                          ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNotification(notificationId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
