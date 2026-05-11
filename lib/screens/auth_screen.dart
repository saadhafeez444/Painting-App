import 'package:flutter/material.dart';
import 'package:painting_app/models/user.dart';
import 'package:painting_app/screens/login_screen.dart';


class AuthScreens extends StatelessWidget {
  const AuthScreens({super.key});

  @override
  Widget build(BuildContext context) {
  
    return const LoginScreen();
  }
}

User? _currentUser;

void Function(User?)? _onUserLoggedIn;
