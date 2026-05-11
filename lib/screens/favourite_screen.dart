import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:painting_app/models/painting.dart';
import 'package:painting_app/screens/detail_screen.dart';
import 'package:painting_app/widgets/image_placeholder.dart';
// import 'painting.dart'; // Import your Painting model

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Helper function to remove a painting from favorites
  void _removeFromFavorites(Painting painting) {
    painting.toggleFavorite(); // Already handles save() inside the model
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Favorites ❤️',
          style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
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
      body: ValueListenableBuilder<Box<Painting>>(
        valueListenable: Hive.box<Painting>('paintings').listenable(),
        builder: (context, box, _) {
          final favoritePaintings = box.values
              .where((p) => p.isFavorite)
              .toList()
              .cast<Painting>();

          if (favoritePaintings.isEmpty) {
            return const Center(
              child: Text(
                'No paintings added to favorites yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
            child: ListView.builder(
              itemCount: favoritePaintings.length,
              itemBuilder: (context, index) {
                final painting = favoritePaintings[index];
                return Dismissible(
                  key: Key(
                    painting.key.toString(),
                  ), // Unique key for Dismissible
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    // Perform the removal logic
                    _removeFromFavorites(painting);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${painting.title} removed from favorites.',
                        ),
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    color: Colors.white,

                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: painting.imagePath.startsWith('assets/')
                              ? DecorationImage(
                                  image: AssetImage(painting.imagePath),
                                  fit: BoxFit.fill,
                                )
                              : (File(painting.imagePath).existsSync()
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(painting.imagePath),
                                        ),
                                        fit: BoxFit.fill,
                                      )
                                    : null),
                        ),

                        child:
                            !painting.imagePath.startsWith('assets/') &&
                                !File(painting.imagePath).existsSync()
                            ? ImagePlaceholder()
                            : null,
                      ),

                      title: Text(
                        painting.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        painting.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '\$${painting.price.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaintingDetailScreen(painting: painting),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
