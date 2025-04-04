import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String dailyQuote = "Loading...";
  String userName = '';
  String profileImage = "";
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];


  @override
  void initState() {
    super.initState();
    fetchUserData();
    generateMindFreshQuote();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? "User";
            profileImage = userDoc['profileImage'] ?? "";
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: \$e");
    }
  }
Future<void> generateMindFreshQuote() async {
  try {
    final response = await http.post(
      Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyCZ2bF7cajKLhaNMhxf48JAZ5FSkL9FXUc"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Give me a short motivational quote about mental wellness or mental health."}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final quote = data['candidates'][0]['content']['parts'][0]['text'];
      setState(() {
        dailyQuote = quote;
      });
    } else {
      print("API Error: ${response.body}");
      setState(() {
        dailyQuote = "Failed to load quote.";
      });
    }
  } catch (e) {
    print("Exception: $e");
    setState(() {
      dailyQuote = "Error fetching quote.";
    });
  }
}


void searchTherapists(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    var snapshot = await FirebaseFirestore.instance
        .collection('therapists')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    setState(() {
      searchResults = snapshot.docs;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 10),
            _buildSearchBar(),
             _buildSectionHeader(context, "Reboot your Mind", "", ''),
            _buildQuoteCard(dailyQuote),
            _buildSectionHeader(context, "Recommended Therapists", "See All", '/therapistList'),
            _buildTherapistList(),
            _buildSearchResults(),
            _buildSectionHeader(context, "Daily Goals", "Set Goals", '/dailyGoals'),
            _buildDailyGoalsSection(),
            _buildSectionHeader(context, "Today's Mood", "Track Mood", '/moodTracker'),
            _buildMoodTracker(),
         
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return Container(
    
width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : AssetImage('') as ImageProvider,
              ),
              SizedBox(height: 15),
             
                  Text("Hello ,  $userName", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text("Stay healthy and positive!", style: TextStyle(fontSize: 16, color: Colors.white)),
              
            ],
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notification button click
            },
          ),
        ],
      ),
    );
  }

    Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search Therapist",
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.blue.shade300,
                    width: 2,
                  ),
                  
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.blue.shade900,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.blue.shade300,
                    width: 2,
                  ),
                ),
              ),
            
            onChanged: searchTherapists,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
  Widget _buildSearchResults() {
    return Padding(
    padding: const EdgeInsets.all(16.0),
      child: Column(
        children: searchResults.map((doc) {
          var therapist = doc.data() as Map<String, dynamic>;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: therapist['profileImage'] != null
                  ? NetworkImage(therapist['profileImage'])
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            title: Text(therapist['name'] ?? "Unknown"),
            subtitle: Text(therapist['specialization'] ?? ""),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bookAppointment', arguments: therapist);
              },
              child: Text("Book"),
            ),
          );
        }).toList(),
      ),
    );
  }
}

  Widget _buildQuoteCard(String quote) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding( 
          padding: EdgeInsets.all(16),
          child: Text(
            quote,
            style: TextStyle(fontSize: 25, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  Widget _buildSectionHeader(BuildContext context, String title, String title2, String route) {
    return Padding(
       padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          TextButton(
            onPressed: () {
             Navigator.pushNamed(context, route);

            },
            child: Row(
              children: [
                Text(title2, style: TextStyle(fontSize: 16, color: Colors.blue)),
                Icon(Icons.arrow_forward, color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTherapistList() {
    return Padding(
  padding: const EdgeInsets.all(16.0),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('therapists').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var therapists = snapshot.data!.docs;
          return SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: therapists.length,
              itemBuilder: (context, index) {
                var therapist = therapists[index].data() as Map<String, dynamic>;
                return _buildTherapistCard(therapist);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTherapistCard(Map<String, dynamic> therapist) {
    return Container(
        width: 140,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                therapist['profileImage'] ?? '',
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    therapist['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    therapist['qualification'],
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

 
 

  Widget _buildDailyGoalsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Set your daily goal...",
              prefixIcon: Icon(Icons.check_circle_outline, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (goal) {
              FirebaseFirestore.instance.collection('daily_goals').add({
                'user': FirebaseAuth.instance.currentUser?.uid,
                'goal': goal,
                'timestamp': Timestamp.now(),
              });
            },
          ),
          SizedBox(height: 10),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('daily_goals').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              var goals = snapshot.data!.docs;
              return Column(
                children: goals.map((doc) => ListTile(
                  title: Text(doc['goal']),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildMoodTracker() {
    return Padding(
   padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("How are you feeling today?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
                onPressed: () {
                  // Handle mood selection
                },
              ),
              IconButton(
                icon: Icon(Icons.sentiment_neutral, color: Colors.yellow),
                onPressed: () {
                  // Handle mood selection
                },
              ),
              IconButton(
                icon: Icon(Icons.sentiment_satisfied, color: Colors.green),
                onPressed: () {
                  // Handle mood selection
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  

