// -----------------------------------------------------------------------------
// IMAGE UTILS (HELPER CLASS) - Place this outside your main widgets
// -----------------------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static Future<String?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        return pickedFile.path;
      }
    } catch (e) {
      // Log the error to console
      debugPrint("Image picking failed: $e"); 
    }
    return null;
  }

  static Future<String> saveImagePermanently(String imagePath) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String fileName = path.basename(imagePath);
    final File localImage = File(imagePath);
    
    // Create a unique filename using a timestamp to prevent clashes
    final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final String newPath = path.join(appDocDir.path, uniqueFileName);
    
    // Copy the file to the app's permanent storage directory
    final File newFile = await localImage.copy(newPath);
    return newFile.path;
  }
}