import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/admin/admin%20home%20page.dart';
import 'package:mindmend/firebase_options.dart';
import 'package:mindmend/therapist/therapist%20home%20page.dart';
import 'package:mindmend/therapist/therapist%20meditation.dart';
import 'package:mindmend/user/user%20home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Mend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange), // Updated theme color
        useMaterial3: true,
      ),
      home: UserHomePage(), // Replace with your actual home screen
    );
  }
}
