import 'package:flutter/material.dart';

class ViewUsersScreen extends StatelessWidget {
  // Sample data for users (replace with real data later)
  final List<Map<String, String>> users = [
    {
      'name': 'John Doe',
      'email': 'johndoe@example.com',
      'gender': 'Male',
      'dob': '1990-05-15',
      'phone': '123-456-7890',
      'photo': 'https://www.example.com/john_doe.jpg',
    },
    {
      'name': 'Jane Smith',
      'email': 'janesmith@example.com',
      'gender': 'Female',
      'dob': '1985-10-25',
      'phone': '987-654-3210',
      'photo': 'https://www.example.com/jane_smith.jpg',
    },
    {
      'name': 'Michael Johnson',
      'email': 'michaelj@example.com',
      'gender': 'Male',
      'dob': '1992-03-09',
      'phone': '555-666-7777',
      'photo': 'https://www.example.com/michael_johnson.jpg',
    },
    {
      'name': 'Emily Davis',
      'email': 'emilyd@example.com',
      'gender': 'Female',
      'dob': '1988-07-30',
      'phone': '444-555-6666',
      'photo': 'https://www.example.com/emily_davis.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Users"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Handle the user tap (for example, navigate to user details page)
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
                    backgroundImage: NetworkImage(users[index]['photo']!),
                    backgroundColor: Colors.grey[300],
                    child: users[index]['photo'] == null
                        ? Icon(Icons.person, color: Colors.white)
                        : null, // Placeholder if no image
                  ),
                  title: Text(
                    users[index]['name']!,
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
                        'Email: ${users[index]['email']}',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      Text(
                        'Gender: ${users[index]['gender']}',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      Text(
                        'DOB: ${users[index]['dob']}',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      Text(
                        'Phone: ${users[index]['phone']}',
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
        ),
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
