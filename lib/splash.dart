import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mindmend/choosenscreen.dart';
import 'package:mindmend/user/user_home.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the animation controller when done
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Adjust the background color if necessary
      body: Center(
        child: Lottie.asset(
          'asset/Animation - 1741588462616.json', // Replace this with your animation file
          controller: _controller,
          onLoaded: (composition) {
            // Set up the animation duration and play the animation
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() {
                // Navigate to the home screen once animation completes
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()), // Replace with your desired screen
                );
              });
          },
        ),
      ),
    );
  }
}
