import 'package:flutter/material.dart';
import 'package:painting_app/models/user.dart';
import 'package:painting_app/screens/ai_chatbot.dart';
import 'package:painting_app/screens/cart_screen.dart';
import 'package:painting_app/screens/dashboard.dart';
import 'package:painting_app/screens/favourite_screen.dart';
import 'package:painting_app/screens/home_screen.dart';
import 'package:painting_app/screens/upload_paintings.dart';
import 'package:painting_app/screens/user_profile_screen.dart';
import 'package:painting_app/widgets/bottom_nav_bar.dart';

User? _currentUser;
void Function(User?)? _onUserLoggedIn;

class NavigationScreen extends StatefulWidget {
  final int initialIndex;
  final User user;

  const NavigationScreen({Key? key, this.initialIndex = 0, required this.user})
    : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final List<String> _icons = [
    'assets/images/logo.png',
    'assets/images/hand.png',
    'assets/images/plus.png',
    'assets/images/chat_1.png',
    'assets/images/profile_1.png',
  ];

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(user: widget.user),
      HomeScreen(),
      UploadPaintingScreen(user: widget.user),
      JarvisHome(user: widget.user),
      UserProfileScreen(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: IndexedStack(index: selectedIndex, children: screens),

      bottomNavigationBar: CustomBottomNavBar(
        icons: _icons,
        selectedIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
