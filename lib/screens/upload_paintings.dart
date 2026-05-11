import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:painting_app/models/user.dart';
import 'package:painting_app/screens/navigation_screen.dart';
import 'package:painting_app/services/hive_services.dart';
import '../models/painting.dart';
import '../models/review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

User? _currentUser;
void Function(User?)? _onUserLoggedIn;

class UploadPaintingScreen extends StatefulWidget {
  final User user;
  const UploadPaintingScreen({super.key, required this.user});

  @override
  State<UploadPaintingScreen> createState() => _UploadPaintingScreenState();
}

class _UploadPaintingScreenState extends State<UploadPaintingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _artistController = TextEditingController();
  final _mediumController = TextEditingController();
  String? _selectedCategory;

  final List<String> availableCategories = const [
    'Abstract',
    'Impressionism',
    'Portraiture',
    'Landscape',
    'Modern',
  ];

  String? _mainImagePath;
  List<String> _previousWorkImagePaths = [];

  final ImagePicker _picker = ImagePicker();

  Future<String> _saveImagePermanently(String temporaryPath) async {
    try {
      if (temporaryPath.startsWith('assets/')) {
        return temporaryPath;
      }

      final File sourceFile = File(temporaryPath);
      if (!await sourceFile.exists()) {
        debugPrint("Source image file does not exist at: $temporaryPath");
        return '';
      }

      final appDir = await getApplicationDocumentsDirectory();

      final String fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${p.basename(temporaryPath)}';
      final String newPath = p.join(appDir.path, fileName);

      await sourceFile.copy(newPath);
      return newPath;
    } catch (e) {
      debugPrint('Error saving file permanently: $e');
      return '';
    }
  }

  Future<void> _pickMainImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _mainImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickPreviousWorkImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();

    final List<String> newPaths = pickedFiles
        .map((xfile) => xfile.path)
        .toList();
    setState(() {
      _previousWorkImagePaths.addAll(newPaths);
      // Enforce max limit of 5 images
      if (_previousWorkImagePaths.length > 5) {
        _previousWorkImagePaths = _previousWorkImagePaths.sublist(0, 5);
      }
    });
  }

  void _submitForm() async {
    // 1. Validation Check
    if (!_formKey.currentState!.validate() ||
        _mainImagePath == null ||
        _selectedCategory == null) {
      String message = '';
      if (_mainImagePath == null) {
        message += 'Please select a main painting image. ';
      }
      if (_selectedCategory == null) {
        message += 'Please select a category.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    _formKey.currentState!.save();

    // 2. Persist Main Image
    final String permanentMainImagePath = await _saveImagePermanently(
      _mainImagePath!,
    );
    if (permanentMainImagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save main image permanently. Upload aborted.',
          ),
        ),
      );
      return;
    }

    // 3. Persist Previous Work Images
    final List<String> permanentPreviousPaths = [];
    for (final tempPath in _previousWorkImagePaths) {
      final permanentPath = await _saveImagePermanently(tempPath);
      if (permanentPath.isNotEmpty) {
        permanentPreviousPaths.add(permanentPath);
      }
    }

    // 4. Create Painting object using permanent paths and all fields
    final newPainting = Painting(
      title: _titleController.text,
      description: _descController.text,
      imagePath: permanentMainImagePath, // Store permanent path
      price: double.tryParse(_priceController.text) ?? 0.0,
      artistName: _artistController.text,
      creationDate: DateTime.now(), // Auto-generate current date
      medium: _mediumController.text,
      reviews: [
        // FIX: Changed 'rating: 5' to 'rating: 5.0' to match the double type in Review model
        Review(
          reviewerName: 'Admin',
          comment: 'A newly uploaded piece.',
          rating: 5.0,
        ),
        Review(
          reviewerName: 'Curator',
          comment: 'Excellent addition.',
          rating: 5.0,
        ),
        Review(reviewerName: 'Fan', comment: 'Amazing!', rating: 5.0),
      ],
      previousWorkImagePaths: permanentPreviousPaths, // Store permanent paths
      category: _selectedCategory!,
    );

    // 5. Save to Hive and Navigate
    await HiveService.addPainting(newPainting);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(user: widget.user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload New Painting',
          style: TextStyle(fontFamily: 'Montserrat'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Main Painting Image:',
                style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: _mainImagePath != null
                      ? Image.file(
                          File(_mainImagePath!),
                          fit: BoxFit.fill,
                          errorBuilder: (ctx, e, s) =>
                              const Center(child: Text('Error loading image')),
                        )
                      : const Center(child: Text('No Image Selected')),
                ),
              ),

              //      Container(
              //   height: 200,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.grey),
              //     borderRadius: BorderRadius.circular(8.0),
              //   ),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(8.0),
              //     child: _mainImagePath != null
              //         ? Image.file(
              //             File(_mainImagePath!),
              //             fit: BoxFit.fill,
              //             width: double.infinity,
              //           )
              //         : Image.asset(
              //             'assets/images/bg_p.png',
              //             fit: BoxFit.fill,
              //             width: double.infinity,
              //           ),
              //   ),
              // ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickMainImage,
                icon: const Icon(Icons.photo_library),
                label: const Text(
                  'Select Painting Image',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // --- Category Dropdown ---
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                hint: const Text(
                  'Select a Category',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                items: availableCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 24),

              // --- Previous Work Images Selector ---
              Text(
                'Previous Work (Max 5 Images):',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ..._previousWorkImagePaths.map((path) {
                    return Stack(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, e, s) =>
                                  const Center(child: Icon(Icons.error)),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _previousWorkImagePaths.remove(path);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),

                  if (_previousWorkImagePaths.length < 5)
                    GestureDetector(
                      onTap: _pickPreviousWorkImages,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade400,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, color: Colors.blueGrey),
                              Text(
                                '${_previousWorkImagePaths.length}/5',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 40),

              // --- Text Form Fields ---
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Image.asset(
                      'assets/images/title.png',
                      width: 20,
                      height: 20,
                    ),
                  ),

                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(13.0),

                    child: Image.asset(
                      'assets/images/description.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(fontFamily: 'Montserrat'),
                  prefixText: 'Rs',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(13.0),

                    child: Image.asset(
                      'assets/images/price.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    (value!.isEmpty || double.tryParse(value) == null)
                    ? 'Invalid price format'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _artistController,
                decoration: InputDecoration(
                  labelText: 'Artist Name',
                  labelStyle: TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Image.asset(
                      'assets/images/artist.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Artist Name is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _mediumController,
                decoration: InputDecoration(
                  labelText: 'Medium (e.g., Oil on Canvas)',
                  labelStyle: TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Image.asset(
                      'assets/images/medium.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Upload Painting',
                  style: TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
