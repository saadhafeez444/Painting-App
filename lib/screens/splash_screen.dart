import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:painting_app/screens/login_screen.dart';
import 'package:painting_app/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController titlectonrl = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
          OnboardingScreen()));
     
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
    );

    return Scaffold(
            extendBodyBehindAppBar:true,
      body: _getBody(context),
    );
  }
  Widget _getBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 7),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Column(
            children: [
              ScaleTransition(
                scale: _animation,
                child: FadeTransition(
                  opacity: _animation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,

                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 70),
              //   child: LinearProgressIndicator(
              //     minHeight: 4,
              //     borderRadius: BorderRadius.circular(20),
              //     color: Color(0xfff73c11),
              //   ),
              // ),
            ],
          ),
          Center(
            child: RichText(
  textAlign: TextAlign.center,
  text: TextSpan(
    children: [
      TextSpan(
        text: "ARTIFY",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        
          foreground: Paint()
            ..shader = const LinearGradient(
             
              colors: <Color>[
                Color(0xFF00FF00), 
                Color(0xFF0000FF), 
                Color(0xFFFF8C00), 
                Color(0xFFFF69B4), 
                Color(0xFFFFFF00), 
                Color(0xFF0000FF),
                Color(0xFFFF8C00),
              ],
             
              stops: <double>[0.0, 0.15, 0.30, 0.45, 0.60, 0.75, 1.0],
            ).createShader(
             
              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
            ),
        ),
      ),
    ],
  ),
),),
        ],
      ),
    );
  }
}

