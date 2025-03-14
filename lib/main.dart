import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/admin/admin%20home%20page.dart';
import 'package:mindmend/choosenscreen.dart';
import 'package:mindmend/firebase_options.dart';
import 'package:mindmend/splash.dart';
import 'package:mindmend/therapist/therapist%20home%20page.dart';
import 'package:mindmend/therapist/therapist%20signup.dart';
import 'package:mindmend/user/user_%20signup_screen.dart';
import 'package:mindmend/user/user_home.dart';
import 'package:mindmend/user/user_profile_screen.dart';

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
            seedColor: Colors.deepOrange), 
        useMaterial3: true,
      ),
      home: SplashScreen(), 
    );
  }
}
