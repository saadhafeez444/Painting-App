import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:painting_app/models/certificate.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:painting_app/models/certificate.dart';
import 'package:painting_app/models/user.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:painting_app/utils/ImageUtils.dart';
import 'package:path/path.dart' as path; 

import 'package:painting_app/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --- State Variables (Unchanged Logic) ---
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _experienceController;
  late String _selectedGender;
  late List<String> _selectedInterests;
  DateTime? _selectedDateOfBirth;
  String _fullPhoneNumber = ''; 
  late List<Certificate> _certificates;
  String _initialPhoneNumber = ''; // Not actively used in save/load logic, but kept for context

  final List<String> availableInterests = [
    'Abstract', 'Realism', 'Digital Art', 'Sculpture', 'Photography', 
    'Oil Painting', 'Water Color', 'Modern', 'Classical'
  ];
  
  // --- Init/Dispose (Unchanged Logic) ---
  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.name);
    _bioController = TextEditingController(text: u.bio);
    _certificates = List.from(u.certificates);
    _experienceController = TextEditingController(text: u.experienceYears.toString());
    _selectedGender = u.gender;
    _selectedInterests = List.from(u.interests);
    _selectedDateOfBirth = u.dateOfBirth;
    _fullPhoneNumber = u.phoneNumber;
    _initialPhoneNumber = ''; 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }


  
  Future<void> _pickAndSaveCertificateFile(Certificate certificate) async {
   
  }

  void _showCertificateDialog({Certificate? certificate, int? index}) {

    final bool isEditing = certificate != null;
    Certificate currentCert = certificate ?? Certificate(
      name: '', 
      organization: '', 
      dateIssued: DateTime.now(),
      filePath: '',
    );

    final nameController = TextEditingController(text: currentCert.name);
    final orgController = TextEditingController(text: currentCert.organization);
    DateTime selectedDate = currentCert.dateIssued;
    String? currentFilePath = currentCert.filePath;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEditing ? 'Edit Certificate' : 'Add New Certificate', 
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextFormField(controller: nameController, label: 'Certificate Name'),
                    const SizedBox(height: 10),
                    _buildTextFormField(controller: orgController, label: 'Organization'),
                    const SizedBox(height: 10),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade300)),
                      title: Text('Date Issued: ${DateFormat('MM/dd/yyyy').format(selectedDate)}', style: const TextStyle(fontFamily: 'Montserrat')),
                      trailing: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setStateSB(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildGradientButton(
                      icon: Icons.upload_file,
                      label: currentFilePath!.isNotEmpty ? 'File Selected' : 'Upload File',
                      onPressed: () async {
                        final String? tempPath = await ImageUtils.pickImage(ImageSource.gallery);
                        if (tempPath != null) {
                          final permanentPath = await ImageUtils.saveImagePermanently(tempPath);
                          setStateSB(() => currentFilePath = permanentPath); // Update 
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('File prepared for saving.', style: TextStyle(fontFamily: 'Montserrat'))),
                          );
                        }
                      },
                      isSmall: true,
                    ),
                    if (currentFilePath!.isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          path.basename(currentFilePath!), 
                          style: const TextStyle(fontSize: 12, color: Colors.green, fontFamily: 'Montserrat'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(fontFamily: 'Montserrat', color: Colors.red)),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                _buildGradientButton(
                  label: isEditing ? 'Save' : 'Add',
                  onPressed: () {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Certificate name is required.', style: TextStyle(fontFamily: 'Montserrat'))),
                      );
                      return;
                    }

                    final newCert = Certificate(
                      name: nameController.text,
                      organization: orgController.text,
                      dateIssued: selectedDate,
                      filePath: currentFilePath ?? '',
                    );

                    setState(() { 
                      if (isEditing && index != null) {
                        _certificates[index] = newCert;
                      } else {
                        _certificates.add(newCert);
                      }
                    });
                    Navigator.of(dialogContext).pop();
                  },
                  isSmall: true,
                  icon: isEditing ? Icons.save : Icons.add_circle,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple.shade400,
            colorScheme: ColorScheme.light(primary: Colors.deepPurple.shade400),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            textTheme: const TextTheme(bodyLarge: TextStyle(fontFamily: 'Montserrat')),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _saveProfile() {
 
    widget.user.updateProfile(
      name: _nameController.text,
      bio: _bioController.text,
      phoneNumber: _fullPhoneNumber,
      gender: _selectedGender,
      dateOfBirth: _selectedDateOfBirth,
      interests: _selectedInterests,
      certificates: _certificates,
      experienceYears: double.tryParse(_experienceController.text) ?? 0.0,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!', style: TextStyle(fontFamily: 'Montserrat'))),
    );
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit ${widget.user.role.name.toUpperCase()} Profile 📝',
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white),
        ),
      flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade500, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  
                  end: Alignment.bottomRight,
                ),
              ),
            ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.deepPurple.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
      
            _buildTextFormField(controller: _nameController, label: 'Name'),
            _buildTextFormField(controller: _bioController, label: 'Bio', maxLines: 3),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: IntlPhoneField(
                initialValue: _fullPhoneNumber.startsWith('+') ? _fullPhoneNumber : '',
                initialCountryCode: widget.user.phoneNumber.isNotEmpty ? null : 'US',
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.deepPurple.shade700, fontFamily: 'Montserrat'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.blue, width: 2.0)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 1.0)),
                ),
                onChanged: (phone) {
                  _fullPhoneNumber = phone.completeNumber;
                },
                style: const TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
            
     
            _buildGenderDropdown(),

           
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.deepPurple.shade300, width: 1.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: Text(
                  'Date of Birth: ${_selectedDateOfBirth != null ? DateFormat('MM/dd/yyyy').format(_selectedDateOfBirth!) : 'Select Date'}',
                  style: const TextStyle(fontFamily: 'Montserrat', color: Colors.black87),
                ),
                trailing: const Icon(Icons.calendar_month, color: Colors.blue),
                onTap: () => _selectDate(context),
              ),
            ),
            
       
            _buildInterestsSection(),
            const SizedBox(height: 24),
            
            
            if (widget.user.role == UserRole.artist) ...[
              const Divider(thickness: 2, color: Colors.deepPurple),
              Text('Artist Information 🧑‍🎨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700, fontFamily: 'Montserrat')),
              const SizedBox(height: 16),
              
              _buildCertificateManagementSection(),
              
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _experienceController,
                label: 'Experience (Years)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
            ],
            
           
            if (widget.user.role == UserRole.admin) ...[
              const Text('Admin role has special permissions.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey, fontFamily: 'Montserrat')),
              const SizedBox(height: 24),
            ],

            // Save Button (Gradient)
            _buildGradientButton(
              onPressed: _saveProfile,
              label: 'Save Profile',
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontFamily: 'Montserrat'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.deepPurple.shade700, fontFamily: 'Montserrat'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 1.0),
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender.isNotEmpty ? _selectedGender : null,
        hint: const Text('Select Gender', style: TextStyle(fontFamily: 'Montserrat')),
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: TextStyle(color: Colors.deepPurple.shade700, fontFamily: 'Montserrat'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.blue, width: 2.0)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 1.0)),
        ),
        items: ['Male', 'Female', 'Other'].map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender, style: const TextStyle(fontFamily: 'Montserrat', 
            color: Colors.black)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue ?? '';
          });
        },
        style: const TextStyle(fontFamily: 'Montserrat'),
      ),
    );
  }
  
  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interests (Select relevant art styles):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700, fontFamily: 'Montserrat')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: availableInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return ChoiceChip(
              label: Text(interest, style: TextStyle(fontFamily: 'Montserrat', color: isSelected ? Colors.white : Colors.deepPurple)),
              selected: isSelected,
              selectedColor: Colors.deepPurple.shade400,
              backgroundColor: Colors.deepPurple.shade50,
              side: BorderSide(color: Colors.deepPurple.shade200),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCertificateManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Certificates:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700, fontFamily: 'Montserrat')),
            _buildGradientButton(
              icon: Icons.add_circle,
              label: 'Add',
              onPressed: () => _showCertificateDialog(),
              isSmall: true,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_certificates.isEmpty) 
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('No certificates added yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontFamily: 'Montserrat')),
          ),
        ..._certificates.asMap().entries.map((entry) {
          final index = entry.key;
          final certificate = entry.value;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.badge, color: Colors.blueGrey),
              title: Text(certificate.name, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Montserrat', color: Colors.black87)),
              subtitle: Text(certificate.organization, style: const TextStyle(fontFamily: 'Montserrat', color: Colors.grey)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade400),
                    onPressed: () => _showCertificateDialog(certificate: certificate, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        _certificates.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    bool isSmall = false,
  }) {
    return Container(
      width: isSmall ? null : double.infinity,
      height: isSmall ? 40 : 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.blue.shade400], // Your specified gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade200.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: isSmall ? 18 : 24),
        label: Text(
          label, 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: isSmall ? FontWeight.w500 : FontWeight.bold,
            fontSize: isSmall ? 14 : 18,
            fontFamily: 'Montserrat',
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, 
          shadowColor: Colors.transparent, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
          ),
          padding: isSmall ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}