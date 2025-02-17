import 'package:flutter/material.dart';

// Mock Therapist class
class Therapist {
  String name;
  String gender;
  String email;
  String qualification;
  String phone;
  double fee;

  Therapist({
    required this.name,
    required this.gender,
    required this.email,
    required this.qualification,
    required this.phone,
    required this.fee,
  });
}

class ManageTherapistScreen extends StatefulWidget {
  @override
  _ManageTherapistScreenState createState() => _ManageTherapistScreenState();
}

class _ManageTherapistScreenState extends State<ManageTherapistScreen> {
  // Sample therapist list
  final List<Therapist> therapists = [
    Therapist(
      name: 'John Doe',
      gender: 'Male',
      email: 'john.doe@example.com',
      qualification: 'PhD in Psychology',
      phone: '123-456-7890',
      fee: 100.0,
    ),
    Therapist(
      name: 'Jane Smith',
      gender: 'Female',
      email: 'jane.smith@example.com',
      qualification: 'MSc in Clinical Psychology',
      phone: '098-765-4321',
      fee: 150.0,
    ),
  ];

  // Function to delete a therapist
  void _deleteTherapist(int index) {
    setState(() {
      therapists.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Therapist deleted successfully')),
    );
  }

  // Function to update a therapist's details
  void _updateTherapist(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTherapistScreen(
          therapist: therapists[index],
          onUpdate: (updatedTherapist) {
            setState(() {
              therapists[index] = updatedTherapist;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Therapists'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: therapists.length,
          itemBuilder: (context, index) {
            final therapist = therapists[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.deepOrangeAccent),
                title: Text(
                  therapist.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                subtitle: Text('Qualification: ${therapist.qualification}'),
                trailing: Wrap(
                  spacing: 12,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.deepOrangeAccent),
                      onPressed: () => _updateTherapist(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTherapist(index),
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

class UpdateTherapistScreen extends StatefulWidget {
  final Therapist therapist;
  final Function(Therapist) onUpdate;

  UpdateTherapistScreen({required this.therapist, required this.onUpdate});

  @override
  _UpdateTherapistScreenState createState() => _UpdateTherapistScreenState();
}

class _UpdateTherapistScreenState extends State<UpdateTherapistScreen> {
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _qualificationController;
  late TextEditingController _phoneController;
  late TextEditingController _feeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.therapist.name);
    _genderController = TextEditingController(text: widget.therapist.gender);
    _emailController = TextEditingController(text: widget.therapist.email);
    _qualificationController =
        TextEditingController(text: widget.therapist.qualification);
    _phoneController = TextEditingController(text: widget.therapist.phone);
    _feeController =
        TextEditingController(text: widget.therapist.fee.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Therapist'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _qualificationController,
              decoration: InputDecoration(labelText: 'Qualification'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _feeController,
              decoration: InputDecoration(labelText: 'Fee'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTherapist = Therapist(
                  name: _nameController.text,
                  gender: _genderController.text,
                  email: _emailController.text,
                  qualification: _qualificationController.text,
                  phone: _phoneController.text,
                  fee: double.tryParse(_feeController.text) ?? 0,
                );
                widget.onUpdate(updatedTherapist);
              },
              child: Text('Update Therapist'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ManageTherapistScreen(),
  ));
}
