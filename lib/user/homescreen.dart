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
        Uri.parse("https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=AIzaSyB2mKwjSjP2zeCLnXh6COx3RoxWMlaI2yY"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"request": "daily_health_quote"}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          dailyQuote = data["quote"];
        });
      } else {
        setState(() {
          dailyQuote = "Failed to load quote.";
        });
      }
    } catch (e) {
      setState(() {
        dailyQuote = "Error fetching quote.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 10),
            _buildSearchBar(),
            _buildQuoteCard(dailyQuote),
            _buildSectionHeader("Recommended Therapists"),
            _buildTherapistList(),
            _buildSectionHeader("Guided Meditations"),
            _buildGuidedMeditationList(),
            _buildSectionHeader("Daily Goals"),
            _buildDailyGoalsSection(),
            _buildSectionHeader("Mood Tracker"),
            _buildMoodTracker(),
            _buildSectionHeader("Resources"),
            _buildResourcesSection(),
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return Container(
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
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : AssetImage('assets/user_profile.jpg') as ImageProvider,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello, \$userName", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 5),
                  Text("Stay healthy and positive!", style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
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
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Search Doctor or Symptom",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 10),
        _buildQuoteCard(dailyQuote),
      ],
    );
  }
  Widget _buildQuoteCard(String quote) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding( 
        padding: EdgeInsets.all(16),
        child: Text(
          quote,
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/therapistsList');
          },
          child: Row(
            children: [
              Text("See All", style: TextStyle(fontSize: 16, color: Colors.blue)),
              Icon(Icons.arrow_forward, color: Colors.blue),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildTherapistList() {
    return StreamBuilder(
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
}
  Widget _buildGuidedMeditationList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('meditations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        var meditations = snapshot.data!.docs;
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: meditations.length,
            itemBuilder: (context, index) {
              var meditation = meditations[index].data() as Map<String, dynamic>;
              return _buildMeditationCard(meditation);
            },
          ),
        );
      },
    );
  }

  Widget _buildMeditationCard(Map<String, dynamic> meditation) {
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
              meditation['thumbnail'] ?? '',
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
                  meditation['title'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    return Column(
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
    );
  }
  Widget _buildMoodTracker() {
    return Column(
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
    );
  }
  Widget _buildResourcesSection() {
    return Column(
      children: [
        Text("Resources", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection('resources').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            var resources = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: resources.length,
              itemBuilder: (context, index) {
                var resource = resources[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(resource['title']),
                  subtitle: Text(resource['description']),
                );
              },
            );
          },
        ),
      ],
    );
  }

