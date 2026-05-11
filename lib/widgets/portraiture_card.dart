import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painting_app/models/painting.dart';

class PortraitureCard extends StatelessWidget {
  final Painting painting;
  const PortraitureCard({super.key, required this.painting});

  Widget _buildImage(String path) {
    // Check if the path is an asset (initial data)
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.fill,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.palette_outlined, size: 40, color: Colors.grey),
        ),
      );
    }
    // Assume it's a local file path (user upload)
    else if (path.isNotEmpty) {
      return Image.file(
        File(path),
        fit: BoxFit.fill,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported, size: 40, color: Colors.red),
        ),
      );
    }
    // Fallback for missing path
    return const Center(child: Text('No Image'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: _buildImage(painting.imagePath),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    painting.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    NumberFormat("#,##0").format(painting.price) + " PKR",
                    style: const TextStyle(color: Colors.green),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      // Text('${painting.averageRating.toStringAsFixed(1)} (${painting.reviews.length} reviews)',         maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,),
                      Text(
                        '${painting.averageRating.toStringAsFixed(1)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
