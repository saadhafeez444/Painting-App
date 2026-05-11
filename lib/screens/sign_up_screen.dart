import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:painting_app/models/user.dart';
import 'package:painting_app/screens/login_screen.dart';
import 'package:painting_app/screens/user_profile_screen.dart';
import 'package:painting_app/widgets/SignUpBackgroundPainter.dart';

import 'package:shimmer/shimmer.dart';

User? _currentUser;

void Function(User?)? _onUserLoggedIn;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserRole? _selectedRole = UserRole.user;
  bool _isSigningUp = false;

 Future<void> _signUp() async {
    // Keep original validation logic exactly:
    if (!_formKey.currentState!.validate() || _selectedRole == null) return;

    // show shimmer/button disabled
    setState(() {
      _isSigningUp = true;
    });

    try {
      final usersBox = Hive.box<User>('users');

      // keep duplicate email check logic unchanged:
      if (usersBox.values.any((user) => user.email == _emailController.text)) {
        // hide shimmer and show snackbar
        if (mounted) {
          setState(() => _isSigningUp = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This email is already registered.')),
          );
        }
        return;
      }

      final newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole!,

        // keep other fields as in your original code:
        imagePath: 'assets/images/default_profile.png',
        bio: '',
        interests: [],
        gender: '',
        phoneNumber: '',
        dateOfBirth: null,
        certificates: [],
        experienceYears: 0.0,
      );

      // persist user (same as original)
      await usersBox.add(newUser);

      // set global/local current user (same as original)
      _currentUser = newUser;

      // show the snack bar (kept) and then show the success dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign Up Successful! Redirecting to Profile.'),
          ),
        );

        // show dialog — user will tap "Login" (or Next) to navigate to profile
        _showSuccessDialog(context, 'Your account has been created successfully.');
      }
    } catch (e) {
      // optional: show error — doesn't change core logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating account: ${e.toString()}')),
        );
      }
    } finally {
      // always hide shimmer when done (success or failure)
      if (mounted) setState(() => _isSigningUp = false);
    }
  }

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10.0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 16.0),
                Text(
                  _emailController.text,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Congratulations, ${_nameController.text}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: primaryBlue),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        // close the dialog first
                        Navigator.of(dialogContext).pop();

                        // Navigate to the newly created user's profile.
                        // We use pushReplacement so the user can't go back to sign-up.
                        if (_currentUser != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => UserProfileScreen(user: _currentUser!),
                            ),
                          );
                        } else {
                          // fallback: if somehow current user is null, just pop
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Unable to open profile.')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Complete Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SignUpBackgroundPainter(
                mainWaveColor: Color(0xFF4C66C3),
                circleColor: Color(0xFF6B8BCC),
                lightColor: Color(0xFFEAEAEA),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(color: primaryBlue),
                      ),
                      const SizedBox(height: 32.0),
                      _buildTextFormField(
                        context: context,
                        controller: _nameController,
                        labelText: 'Full Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextFormField(
                        context: context,
                        controller: _emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextFormField(
                        context: context,
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildRoleDropdown(context),

          
                      const SizedBox(height: 16.0),
                      _buildTermsCheckbox(context),
                      const SizedBox(height: 24.0),

                      _buildSignUpButton(context),
                      const SizedBox(height: 24.0),

                      Text(
                        'Sign up with',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16.0),
                      _buildSocialIcons(context),
                      const SizedBox(height: 24.0),
                      _buildSignInText(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Enter $labelText',
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2.0,
          ),
        ),
      ),
      validator: validator,
    );
  }

 Widget _buildRoleDropdown(BuildContext context) {
    return DropdownButtonFormField<UserRole>(
      value: _selectedRole,
      style: Theme.of(context).textTheme.bodyLarge,
      dropdownColor: Theme.of(context).cardColor,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2.0,
          ),
        ),
      ),
      items: UserRole.values.map((UserRole role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Text(
            role.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }).toList(),
      onChanged: (UserRole? newValue) {
        setState(() {
          _selectedRole = newValue;
        });
      },
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (bool? newValue) {
            setState(() {
              _agreedToTerms = newValue!;
            });
          },
          activeColor: primaryBlue,
        ),
        Text.rich(
          TextSpan(
            text: 'I agree to the processing of ',
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'Personal data',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerButton() {
    return Shimmer.fromColors(
      baseColor: primaryBlue.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.1),
      child: ElevatedButton(
        onPressed: null,
        style: _buttonStyle(),
        child: const Text(
          'Signing Up...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

 Widget _buildSignUpButton(BuildContext context) {
    // When signing up, show the shimmer-disabled button; otherwise normal button
    if (_isSigningUp) return _buildShimmerButton();

    return ElevatedButton(
      onPressed: _signUp,
      style: _buttonStyle(),
      child: const Text(
        'Sign up',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryBlue,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      elevation: 5,
    );
  }

  Widget _buildSocialIcons(BuildContext context) {
    final iconColor = Theme.of(context).textTheme.bodyLarge!.color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
          Icon(Icons.facebook, color: Colors.blue, size: 40),
          context,
        ),
        _buildSocialIcon(
          Icon(Icons.apple, color: iconColor, size: 40),
          context,
        ),
        _buildSocialIcon(
          Icon(Icons.g_mobiledata, color: Colors.red, size: 40),
          context,
        ),
        _buildSocialIcon(
          Icon(Icons.flutter_dash, color: Colors.lightBlue, size: 40),
          context,
        ), // Twitter icon placeholder
      ],
    );
  }

  Widget _buildSocialIcon(Widget icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }

  Widget _buildSignInText(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Text.rich(
        TextSpan(
          text: 'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: 'Sign in',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
