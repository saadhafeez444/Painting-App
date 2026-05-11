import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:painting_app/models/onboarding_model.dart';
import 'package:painting_app/screens/auth_screen.dart';
import 'package:painting_app/screens/login_screen.dart';
import 'package:painting_app/widgets/onboarding_page_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';



class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  bool _isScrollingPaused = false;
  bool _isScrollingForward = true;

List<ModelClass> onBoardingData = [

  ModelClass(
    image: 'assets/images/onboarding_1.png',
    name: 'Dive into Your Digital Canvas!',
    description:
      'Unleash your creativity with our powerful and intuitive drawing tools. Whether you’re a beginner or a pro, discover the perfect brush, palette, and texture to bring your wildest artistic visions to life, right on your screen.',
  ),


  ModelClass(
    image: 'assets/images/onboarding_2.png',
    name: 'Master the Art of Layers & Blending',

    description:
      'Organize complex masterpieces effortlessly with our robust layering system. Experiment with different blending modes and opacity to achieve stunning, professional-grade depth and subtle color transitions in your artwork.'
  ),
  ModelClass(
    image: 'assets/images/onboarding_3.png',
    name: 'Instant Color Palettes & Inspiration',

    description:
      '''Find the perfect hue every time! Generate instant color palettes from photos, explore curated schemes, and track your brushstrokes in real-time. Enjoy a transparent, stress-free creative flow from a blank page to a finished piece.''',
  ),


  ModelClass(
    image: 'assets/images/onboarding_4.png',
    name: 'Secure Your Art & Share the Vision',

    description:
      '''Save your creations securely in the cloud and export them in high resolution across various formats. Our dedicated support team is available to assist with any creative questions, ensuring a smooth artistic process every step of the way.''',
  ),
];
  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currentIndex = pageController.page?.round() ?? 0;
      });
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_isScrollingPaused) {
        int nextPage;
        if (_isScrollingForward) {
          nextPage = _currentIndex + 1;
          if (nextPage >= onBoardingData.length) {
           
            nextPage = onBoardingData.length - 1;
            _isScrollingForward = false;
          }
        } else {
          nextPage = _currentIndex - 1;
          if (nextPage < 0) {
         
            nextPage = 0;
            _isScrollingForward = true;
          }
        }
        pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _pauseAutoScroll() {
    setState(() {
      _isScrollingPaused = true;
    });
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    setState(() {
      _isScrollingPaused = false;
    });
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    pageController.dispose();
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
  
      backgroundColor: Colors.white,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreens()),

                    );
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color : Colors.teal,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            )
          : AppBar(
            elevation: 0,
              backgroundColor: Colors.white,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreens()),
                    );
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
              leading: Padding(
                padding: EdgeInsets.only(left: 20),
                child: IconButton(
                  onPressed: () {
                    pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  icon: Icon(Icons.arrow_back, color:Colors.teal,),
                ),
              ),
            ),
      body: GestureDetector(
        onTap: () {
          if (_isScrollingPaused) {
            _resumeAutoScroll();
          } else {
            _pauseAutoScroll();
          }
        },
        child: _getBody(context),
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: onBoardingData.length,
            controller: pageController,
            itemBuilder: (context, index) {
              return ModelElements(modelClass: onBoardingData[index]);
            },
          ),
        ),
        SmoothPageIndicator(
          controller: pageController,
          count: onBoardingData.length,
          effect: ExpandingDotsEffect(
            dotHeight: 10,
            dotWidth: 10,
            dotColor: Colors.teal.shade200,
             activeDotColor: Colors.teal,
          ),
          onDotClicked: (index) {},
        ),
        _buildBottomButtons(),
      ],
    );
  }



  Widget _buildBottomButtons() {
    return Column(
      children: [
        Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: double.infinity,
                  height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthScreens()),
                      );
                    } else {
                      pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentIndex == onBoardingData.length - 1
                              ? 'FINISH'
                              : 'NEXT',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Color(0xffFFFFFF),
                          ),
                        ),
                        SizedBox(width: 15),

                        Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            _currentIndex == onBoardingData.length - 1
                                ? Icons.arrow_forward
                                : Icons.arrow_forward,
                            size: 24,
                            color: Color(0xffFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.teal,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ],
    );
  }
}
