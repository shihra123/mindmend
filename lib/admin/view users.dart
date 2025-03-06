import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Users"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No users found"));
          }
          
          var users = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index].data() as Map<String, dynamic>;
              
              return GestureDetector(
                onTap: () {
                  // Navigate to user details page (implement later)
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: user['profileImage'] != null
                          ? NetworkImage(user['profileImage'])
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: user['profileImage'] == null
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      user['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          'Email: ${user['email'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          'Gender: ${user['gender'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          'DOB: ${user['dob'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          'Phone: ${user['phone'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ViewUsersScreen(),
  ));
}
