import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTherapistScreen extends StatefulWidget {
  @override
  _ManageTherapistScreenState createState() => _ManageTherapistScreenState();
}

class _ManageTherapistScreenState extends State<ManageTherapistScreen> {
  final CollectionReference therapistsCollection =
      FirebaseFirestore.instance.collection('therapists');

  void _deleteTherapist(String id) {
    therapistsCollection.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Therapist deleted successfully')),
    );
  }

  void _updateTherapist(DocumentSnapshot therapist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTherapistScreen(therapist: therapist),
      ),
    );
  }

  void _approveTherapist(String id) {
    therapistsCollection.doc(id).update({'approved': true});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Therapist approved successfully')),
    );
  }

  void _rejectTherapist(String id) {
    therapistsCollection.doc(id).update({'approved': false});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Therapist rejected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Therapists'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: therapistsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No therapists found"));
          }

          var therapists = snapshot.data!.docs;

          return ListView.builder(
            itemCount: therapists.length,
            itemBuilder: (context, index) {
              var therapist = therapists[index].data() as Map<String, dynamic>;
              var docId = therapists[index].id;
              bool isApproved = therapist['approved'] ?? false;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: isApproved ? Colors.green : Colors.deepOrangeAccent,
                  ),
                  title: Text(
                    therapist['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qualification: ${therapist['qualification'] ?? 'N/A'}'),
                      Text('Phone: ${therapist['contactNumber'] ?? 'N/A'}'),
                      Text('Email: ${therapist['email'] ?? 'N/A'}'),
                      Text('Fee: \$${therapist['fees']?.toString() ?? 'N/A'}'),
                      Text('Created At: ${therapist['createdAt']?.toDate() ?? 'N/A'}'),
                      Text('Status: ${isApproved ? 'Approved' : 'Pending'}'),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 12,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.deepOrangeAccent),
                        onPressed: () => _updateTherapist(therapists[index]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTherapist(docId),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'approve') {
                            _approveTherapist(docId);
                          } else if (value == 'reject') {
                            _rejectTherapist(docId);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'approve',
                            child: Text('Approve'),
                          ),
                          PopupMenuItem<String>(
                            value: 'reject',
                            child: Text('Reject'),
                          ),
                        ],
                        icon: Icon(Icons.more_vert, color: Colors.deepOrangeAccent),
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
}

class UpdateTherapistScreen extends StatefulWidget {
  final DocumentSnapshot therapist;

  UpdateTherapistScreen({required this.therapist});

  @override
  _UpdateTherapistScreenState createState() => _UpdateTherapistScreenState();
}

class _UpdateTherapistScreenState extends State<UpdateTherapistScreen> {
  late TextEditingController _nameController;
  late TextEditingController _qualificationController;
  late TextEditingController _emailController;
  late TextEditingController _contactNumberController;
  late TextEditingController _feesController;

  @override
  void initState() {
    super.initState();
    var data = widget.therapist.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name']);
    _qualificationController = TextEditingController(text: data['qualification']);
    _emailController = TextEditingController(text: data['email']);
    _contactNumberController = TextEditingController(text: data['contactNumber']);
    _feesController = TextEditingController(text: data['fees']);
  }

  void _updateTherapist() {
    widget.therapist.reference.update({
      'name': _nameController.text,
      'qualification': _qualificationController.text,
      'email': _emailController.text,
      'contactNumber': _contactNumberController.text,
      'fees': double.tryParse(_feesController.text) ?? 0,
    });
    Navigator.pop(context);
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
              controller: _qualificationController,
              decoration: InputDecoration(labelText: 'Qualification'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _contactNumberController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _feesController,
              decoration: InputDecoration(labelText: 'Fee'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTherapist,
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
