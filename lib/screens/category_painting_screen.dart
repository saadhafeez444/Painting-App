// lib/screens/category_paintings_screen.dart

import 'package:flutter/material.dart';
import 'package:painting_app/screens/detail_screen.dart';
import 'package:painting_app/screens/home_screen.dart';
import '../models/painting.dart';
// Import to navigate to details
// Import your PaintingCard widget

class CategoryPaintingsScreen extends StatelessWidget {
  final String category;
  final List<Painting> paintings;

  const CategoryPaintingsScreen({
    super.key,
    required this.category,
    required this.paintings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: paintings.isEmpty
          ? Center(child: Text('No paintings found in the $category category.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two cards per row
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7, // Same aspect ratio as the home screen grid
              ),
              itemCount: paintings.length,
              itemBuilder: (context, index) {
                final painting = paintings[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to detail screen when card is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaintingDetailScreen(painting: painting),
                      ),
                    );
                  },
                  // Use the same PaintingCard design
                  child: PaintingCard(painting: painting),
                );
              },
            ),
    );
  }
}