import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:painting_app/services/hive_services.dart';
import '../models/painting.dart';
import '../models/review.dart'; 


// class EditPaintingScreen extends StatefulWidget {
//   final Painting painting;

//   const EditPaintingScreen({super.key, required this.painting});

//   @override
//   State<EditPaintingScreen> createState() => _EditPaintingScreenState();
// }

// class _EditPaintingScreenState extends State<EditPaintingScreen> {
//   final _formKey = GlobalKey<FormState>();


//   late TextEditingController _titleController;
//   late TextEditingController _descController;
//   late TextEditingController _priceController;
//   late TextEditingController _artistController;
//   late TextEditingController _mediumController;

//  List<String> availableCategories = [
//   'Abstract',
//   'Impressionism',
//   'Portraiture',
//   'Landscape',
//   'Modern',
// ];
// late String _selectedCategory;
//   late String? _mainImagePath;
//   late List<String> _previousWorkImagePaths; 

//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     final p = widget.painting;
  
//     _titleController = TextEditingController(text: p.title);
//     _descController = TextEditingController(text: p.description);
//     _priceController = TextEditingController(text: p.price.toStringAsFixed(2));
//     _artistController = TextEditingController(text: p.artistName);
//     _mediumController = TextEditingController(text: p.medium);
   
//     _mainImagePath = p.imagePath;
//     _previousWorkImagePaths = List.from(p.previousWorkImagePaths);
//     _selectedCategory = p.category;
//   }

//   @override
//   void dispose() {

//     _titleController.dispose();
//     _descController.dispose();
//     _priceController.dispose();
//     _artistController.dispose();
//     _mediumController.dispose();
//     super.dispose();
//   }

// Future<void> _pickMainImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _mainImagePath = pickedFile.path;
//       });
//     }
//   }

//   Future<void> _pickPreviousWorkImages() async {
//     final List<XFile> pickedFiles = await _picker.pickMultiImage();
    
   
//     final int remainingSlots = 5 - _previousWorkImagePaths.length;

//     if (remainingSlots > 0 && pickedFiles.isNotEmpty) {
//       final List<String> newPaths = pickedFiles
//           .map((xfile) => xfile.path)
//           .take(remainingSlots)
//           .toList();
      
//       setState(() {
//         _previousWorkImagePaths.addAll(newPaths);
//       });
//     }
//   }
//   void _submitForm() async {
//     if (_formKey.currentState!.validate() && _mainImagePath != null) {
//       _formKey.currentState!.save();

//       final updatedPainting = Painting(
//         title: _titleController.text,
//         description: _descController.text,
//         imagePath: _mainImagePath!, 
//         price: double.tryParse(_priceController.text) ?? 0.0,
//         artistName: _artistController.text,
//         medium: _mediumController.text,
       
//         reviews: widget.painting.reviews, 
//         creationDate: widget.painting.creationDate,
//         previousWorkImagePaths: _previousWorkImagePaths, 
//      category: _selectedCategory,
//       );
      
//       await HiveService.updatePainting(widget.painting, updatedPainting);

//       if (mounted) {
//         Navigator.pop(context); 
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Painting Details'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: <Widget>[
//              Text('Main Painting Image:', style: Theme.of(context).textTheme.titleMedium),
//               Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
//                 child: _mainImagePath != null
//                     ? Image.file(File(_mainImagePath!), fit: BoxFit.fill)
//                     : const Center(child: Text('No Image Selected')),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton.icon(
//                 onPressed: _pickMainImage,
//                 icon: const Icon(Icons.photo_library),
//                 label: const Text('Change Painting Image'),
//               ),
//               const Divider(height: 40),

         
//               Text('Previous Work (Max 5 Images):', style: Theme.of(context).textTheme.titleMedium),
//               Wrap(
//                 spacing: 8.0,
//                 runSpacing: 8.0,
//                 children: _previousWorkImagePaths.map((path) {
//                   return Stack(
//                     children: [
//                       Container(
//                         height: 60,
//                         width: 60,
//                         decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey)),
//                         child: Image.file(File(path), fit: BoxFit.fill),
//                       ),
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _previousWorkImagePaths.remove(path); // REMOVE image
//                             });
//                           },
//                           child: const Icon(Icons.remove_circle, color: Colors.red, size: 18),
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
           
//            const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//               decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
//               value: _selectedCategory,
//               items: availableCategories.map((String category) {
//                 return DropdownMenuItem<String>(
//                   value: category,
//                   child: Text(category),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   if (newValue != null) {
//                     _selectedCategory = newValue;
//                   }
//                 });
//               },
//               validator: (value) => value == null ? 'Category is required' : null,
//             ),
            
//               const SizedBox(height: 8),
//               if (_previousWorkImagePaths.length < 5)
//                 ElevatedButton.icon(
//                   onPressed: _pickPreviousWorkImages,
//                   icon: const Icon(Icons.add_a_photo),
//                   label: Text('Add Previous Work Image (${_previousWorkImagePaths.length}/5)'),
//                 ),
//               const Divider(height: 40),
             

        
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: 'Title'),
//                 validator: (value) => value!.isEmpty ? 'Title is required' : null,
//               ),

          
//               TextFormField(
//                 controller: _descController,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 maxLines: 3,
//               ),

//               TextFormField(
//                 controller: _priceController,
//                 decoration: const InputDecoration(labelText: 'Price'),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Price is required';
//                   if (double.tryParse(value) == null) return 'Invalid price format';
//                   return null;
//                 },
//               ),

        
//               TextFormField(
//                 controller: _artistController,
//                 decoration: const InputDecoration(labelText: 'Artist Name'),
//                 validator: (value) => value!.isEmpty ? 'Artist Name is required' : null,
//               ),

           
//               TextFormField(
//                 controller: _mediumController,
//                 decoration: const InputDecoration(labelText: 'Medium (e.g., Oil on Canvas)'),
//               ),

//               const SizedBox(height: 30),
         
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
//                 child: const Text('Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditPaintingScreen extends StatefulWidget {
  final Painting painting;

  const EditPaintingScreen({super.key, required this.painting});

  @override
  State<EditPaintingScreen> createState() => _EditPaintingScreenState();
}

class _EditPaintingScreenState extends State<EditPaintingScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _artistController;
  late TextEditingController _mediumController;

  List<String> availableCategories = [
    'Abstract',
    'Impressionism',
    'Portraiture',
    'Landscape',
    'Modern',
  ];
  late String _selectedCategory;
  late String? _mainImagePath;
  late List<String> _previousWorkImagePaths;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.painting;

    _titleController = TextEditingController(text: p.title);
    _descController = TextEditingController(text: p.description);
    // Ensure the price is formatted correctly on load
    _priceController = TextEditingController(text: p.price.toStringAsFixed(2));
    _artistController = TextEditingController(text: p.artistName);
    _mediumController = TextEditingController(text: p.medium);

    _mainImagePath = p.imagePath;
    _previousWorkImagePaths = List.from(p.previousWorkImagePaths);
    _selectedCategory = p.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _artistController.dispose();
    _mediumController.dispose();
    super.dispose();
  }

  // --- Image Handling Logic (Unchanged but included for completeness) ---

  // Utility function to determine if the path is an asset or a file
  // and return the appropriate Image widget.
  Widget _buildImageWidget(String? path, {required BoxFit fit}) {
    if (path == null) {
      return const Center(child: Text('No Image Selected'));
    }
    // Check if the path is likely an asset (starts with 'assets/')
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit, errorBuilder: (context, error, stackTrace) {
        return const Center(child: Text('Asset not found'));
      });
    } else {
      // Treat as a file path (from gallery)
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('File not found/accessible'));
        },
      );
    }
  }
  
  Future<void> _pickMainImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mainImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickPreviousWorkImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    
    final int remainingSlots = 5 - _previousWorkImagePaths.length;

    if (remainingSlots > 0 && pickedFiles.isNotEmpty) {
      final List<String> newPaths = pickedFiles
          .map((xfile) => xfile.path)
          .take(remainingSlots)
          .toList();
      
      setState(() {
        _previousWorkImagePaths.addAll(newPaths);
      });
    }
  }
void _submitForm() async {
  if (_formKey.currentState!.validate() && _mainImagePath != null) {
    _formKey.currentState!.save();

    // --- START: The crucial changes ---

    // 1. Update the properties of the EXISTING Painting object (widget.painting)
    //    instead of creating a new one.
    widget.painting.title = _titleController.text;
    widget.painting.description = _descController.text;
    widget.painting.imagePath = _mainImagePath!;
    widget.painting.price = double.tryParse(_priceController.text) ?? 0.0;
    widget.painting.artistName = _artistController.text;
    widget.painting.medium = _mediumController.text;
    widget.painting.category = _selectedCategory;
    widget.painting.previousWorkImagePaths = _previousWorkImagePaths; 
    
    await widget.painting.save();
    
    
    
    if (mounted) {

      Navigator.pop(context, widget.painting); 
    }
  }
}


  // --- UI Building (Refactored for Aesthetics) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Edit Painting Details', ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Main Image Section
              _buildSectionTitle(context, '🖼️ Main Painting Image:'),
              const SizedBox(height: 8),
              _buildMainImageContainer(),
              const SizedBox(height: 12),
              _buildGradientButton(
                onPressed: _pickMainImage,
                icon: Icons.photo_library,
                label: 'Change Main Image',
              ),
              const Divider(height: 40, thickness: 1, color: Colors.grey),

              // Previous Work Images Section
              _buildSectionTitle(context, '✨ Previous Work (Max 5 Images):'),
              const SizedBox(height: 12),
              _buildPreviousWorkWrap(),
              const SizedBox(height: 16),
              if (_previousWorkImagePaths.length < 5)
                _buildGradientButton(
                  onPressed: _pickPreviousWorkImages,
                  icon: Icons.add_a_photo,
                  label: 'Add Previous Work Image (${_previousWorkImagePaths.length}/5)',
                ),
              const Divider(height: 40, thickness: 1, color: Colors.grey),

              // Category Dropdown
              _buildCategoryDropdown(),
              const SizedBox(height: 20),

              // Text Fields
              _buildTextFormField(controller: _titleController, label: 'Title', validator: (value) => value!.isEmpty ? 'Title is required' : null),
              _buildTextFormField(controller: _descController, label: 'Description', maxLines: 3),
              _buildTextFormField(
                controller: _priceController,
                label: 'Price',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) return 'Price is required';
                  if (double.tryParse(value) == null) return 'Invalid price format';
                  return null;
                },
              ),
              _buildTextFormField(controller: _artistController, label: 'Artist Name', validator: (value) => value!.isEmpty ? 'Artist Name is required' : null),
              _buildTextFormField(controller: _mediumController, label: 'Medium (e.g., Oil on Canvas)'),

              const SizedBox(height: 30),

              // Submit Button
              _buildGradientButton(
                onPressed: _submitForm,
                label: 'Save Changes',
                icon: Icons.save,
                isLarge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets for Professional Layout ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
  
  Widget _buildMainImageContainer() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2),
      ),
      clipBehavior: Clip.antiAlias, // Important for BorderRadius
      child: _buildImageWidget(_mainImagePath, fit: BoxFit.fill),
    );
  }

  Widget _buildPreviousWorkWrap() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        ..._previousWorkImagePaths.map((path) {
          return Stack(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.blue.shade300, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildImageWidget(path, fit: BoxFit.fill),
              ),
              Positioned(
                right: -5,
                top: -5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _previousWorkImagePaths.remove(path); // REMOVE image
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.deepPurple.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
      value: _selectedCategory,
      items: availableCategories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          if (newValue != null) {
            _selectedCategory = newValue;
          }
        });
      },
      validator: (value) => value == null ? 'Category is required' : null,
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.deepPurple.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 1.0),
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    bool isLarge = false,
  }) {
    return Container(
      width: isLarge ? double.infinity : null,
      height: isLarge ? 50 : 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.blue.shade400],
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
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Make button transparent to show gradient
          shadowColor: Colors.transparent, // Remove default shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
          ),
          padding: isLarge ? const EdgeInsets.symmetric(vertical: 10, horizontal: 20) : const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}





class ReviewTile extends StatelessWidget {
  final Review review;
  const ReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
    
        child: Text(review.reviewerName[0]),
      ),
      title: Text(review.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating.floor() ? Icons.star : 
                index < review.rating && review.rating % 1 != 0 ? Icons.star_half :
                Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          Text(review.comment),
        ],
      ),
    );
  }
}