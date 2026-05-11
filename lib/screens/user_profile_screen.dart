import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:painting_app/models/certificate.dart';
import 'package:painting_app/models/user.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:painting_app/screens/edit_profile_screen.dart';
import 'package:painting_app/utils/ImageUtils.dart';
import 'package:path/path.dart' as path; 

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog(BuildContext context, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change Profile Photo',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera, color: Colors.blue),
                          ),
                          title: const Text('Take a Photo', style: TextStyle(fontFamily: 'Montserrat')),
                          onTap: () async {
                            Navigator.of(dialogContext).pop();
                            await _pickAndSaveImage(context, currentUser, ImageSource.camera);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.photo_library, color: Colors.purple),
                          ),
                          title: const Text('Select from Gallery', style: TextStyle(fontFamily: 'Montserrat')),
                          onTap: () async {
                            Navigator.of(dialogContext).pop();
                            await _pickAndSaveImage(context, currentUser, ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndSaveImage(BuildContext context, User user, ImageSource source) async {
    final String? tempPath = await ImageUtils.pickImage(source);
    if (tempPath == null) return;

    try {
      final String permanentPath = await ImageUtils.saveImagePermanently(tempPath);

      if (user.imagePath.isNotEmpty && File(user.imagePath).existsSync()) {
        final oldFile = File(user.imagePath);
        await oldFile.delete();
      }

      user.updateProfile(imagePath: permanentPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile image updated! 🖼️', style: TextStyle(fontFamily: 'Montserrat')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error saving and updating profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update profile image.', style: TextStyle(fontFamily: 'Montserrat')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.red,
        ),
      );
    }
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

    return ValueListenableBuilder<Box<User>>(
      valueListenable: Hive.box<User>('users').listenable(),
      builder: (context, box, _) {
        final currentUser = box.get(widget.user.key);

        if (currentUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
          return Scaffold(
            appBar: AppBar(title: const Text('Error', style: TextStyle(fontFamily: 'Montserrat'))),
            body: const Center(child: Text('User profile not found. Logging out...', style: TextStyle(fontFamily: 'Montserrat'))),
          );
        }

        return Scaffold(
           extendBodyBehindAppBar: true,
          backgroundColor: Colors.grey.shade50,


          body: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
              
                  _buildAnimatedHeader(context, currentUser),
                  
              
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(color: Colors.white,
                  borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical:  18.0, horizontal: 13),
                      child: Column(
                        children: [
                       
                          _buildUserInfoCard(currentUser),
                          const SizedBox(height: 20),
                        _buildUserInfoSection(currentUser),
                                const SizedBox(height: 20),
                      
                          _buildPersonalDetailsCard(currentUser),
                          const SizedBox(height: 20),
                          
                        
                          _buildReviewsRatingSection(currentUser),
                          const SizedBox(height: 20),
                          
              
                          _buildActionButtons(context, currentUser),
                          const SizedBox(height: 20),
                          
                      
                          if (currentUser.role == UserRole.artist)
                            _buildArtistSection(currentUser),
                          
                          if (currentUser.role == UserRole.admin)
                            _buildAdminSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildUserInfoSection(User user) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // _buildStatItem('Joined', DateFormat('MMM yyyy').format(user.joinDate), Icons.calendar_month),
                _buildStatItem('Paintings', '12', Icons.brush), // You can make this dynamic
                _buildStatItem('Reviews', '45', Icons.star), // You can make this dynamic
              ],
            ),
          ],
        ),
      ),
    );
  }


 Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedHeader(BuildContext context, User user) {
    final bool hasImage = user.imagePath.isNotEmpty && File(user.imagePath).existsSync();
    
    return SizedBox(
      height: 300, 
      child: Stack(
        children: [
          
          Container(
            height: 230, 
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: DecorationImage(image: AssetImage('assets/images/banner_profile.png'),
              fit: BoxFit.fill),
              
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.3),
              //     blurRadius: 15,
              //     offset: const Offset(0, 8),
              //   ),
              // ],
            ),
            child: Stack(
              children: [
               
                Positioned(
                  right: 20,
                  top: 20,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.person, size: 80, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          // Profile Image positioned to show half in and half out
          Positioned(
            bottom: 0, // Positioned at the bottom of the 250px container
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showImageSourceDialog(context, user),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: hasImage
                              ? FileImage(File(user.imagePath)) as ImageProvider
                              : const AssetImage('assets/images/default_profile.png'),
                          child: !hasImage
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        // Camera Edit Icon
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space for content below image
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(User user) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
           
            Text(
              '${user.role.name.toUpperCase()} NAME',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.name,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
          
            Text(
              'BIO',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.bio.isNotEmpty ? user.bio : 'No bio provided.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.grey.shade700,
                fontStyle: user.bio.isEmpty ? FontStyle.italic : FontStyle.normal,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: user.role == UserRole.admin 
                      ? [Colors.red.shade400, Colors.orange.shade400]
                      : user.role == UserRole.artist
                          ? [Colors.blue.shade400, Colors.purple.shade400]
                          : [Colors.green.shade400, Colors.teal.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${user.role.name.toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsCard(User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.deepPurple),
                const SizedBox(width: 12),
                Text(
                  'Personal Details',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Email', user.email, Icons.email, Colors.blue),
            _buildDetailRow('Phone', user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Not provided', Icons.phone, Colors.green),
            _buildDetailRow('Gender', user.gender.isNotEmpty ? user.gender : 'Not specified', Icons.male, Colors.orange),
            _buildDetailRow(
              'Date of Birth', 
              user.dateOfBirth != null ? DateFormat('MMMM dd, yyyy').format(user.dateOfBirth!) : 'Not provided', 
              Icons.cake, 
              Colors.pink
            ),
            const SizedBox(height: 16),
         
            // Row(
            //   children: [
            //     const Icon(Icons.interests, color: Colors.deepPurple),
            //     const SizedBox(width: 12),
            //     Text(
            //       'Interests',
            //       style: TextStyle(
            //         fontFamily: 'Montserrat',
            //         fontSize: 18,
            //         fontWeight: FontWeight.w600,
            //         color: Colors.grey.shade800,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12),
            // _buildBeautifulInterestsSection(user.interests),
           Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             child: ExpansionTile(
                leading: const Icon(Icons.interests, color: Colors.deepPurple),
                title: Text('Interests', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildBeautifulInterestsSection(user.interests),
                  ),
                ],
              ),
           ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsRatingSection(User user) {
    // You can replace these with actual user review data
    final averageRating = 4.5;
    final totalReviews = 23;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.amber, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$averageRating Average Rating',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$totalReviews Reviews',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeautifulInterestsSection(List<String> interests) {
    final gradientColors = [
      [Colors.deepPurple.shade400, Colors.blue.shade400],
      [Colors.pink.shade400, Colors.purple.shade400],
      [Colors.orange.shade400, Colors.red.shade400],
      [Colors.teal.shade400, Colors.green.shade400],
      [Colors.blue.shade400, Colors.indigo.shade400],
    ];

    return interests.isEmpty
        ? Card(
            color: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Text(
                    'No interests specified',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: interests.asMap().entries.map((entry) {
              final index = entry.key % gradientColors.length;
              final interest = entry.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors[index],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[index][0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors[index],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          interest,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: gradientColors[index][0],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
  }

  Widget _buildActionButtons(BuildContext context, User user) {
    return Row(
      children: [
       
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
              ),
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
       
       
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildArtistSection(User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.brush, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Artist Profile',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
     
            _buildDetailRow('Experience', '${user.experienceYears.toStringAsFixed(1)} years', Icons.work_history, Colors.blue),
            
    
            ExpansionTile(
              leading: const Icon(Icons.badge, color: Colors.blue),
              title: Text(
                'Certificates (${user.certificates.length})',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
              ),
              children: [
                if (user.certificates.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No certificates added',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...user.certificates.map((cert) => _buildCertificateCard(cert)).toList(),
              ],
            ),
            
            const SizedBox(height: 16),
            
          
            ExpansionTile(
              leading: const Icon(Icons.verified_user, color: Colors.green),
              title: Text('Artist Privileges', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      _buildPrivilegeItem('Upload and manage own paintings'),
                      _buildPrivilegeItem('Receive customer reviews and ratings'),
                      _buildPrivilegeItem('Update previous work portfolio'),
                      _buildPrivilegeItem('Showcase artist certificates'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(Certificate cert) {
    final bool hasFile = cert.filePath.isNotEmpty && File(cert.filePath).existsSync();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.name,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Issued by: ${cert.organization}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(cert.dateIssued),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (hasFile) ...[
              const SizedBox(height: 12),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(cert.filePath),
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        'Unable to load image',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.red),
                const SizedBox(width: 12),
                Text(
                  'Admin Privileges',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              leading: const Icon(Icons.security, color: Colors.red),
              title: Text('System Access', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      _buildPrivilegeItem('Full access to all user and painting data'),
                      _buildPrivilegeItem('Manage and moderate all reviews'),
                      _buildPrivilegeItem('Delete or modify any painting or user profile'),
                      _buildPrivilegeItem('System-wide configuration access'),
                      _buildPrivilegeItem('User role management and permissions'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPrivilegeItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


