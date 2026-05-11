import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painting_app/models/painting.dart';
import 'package:painting_app/screens/detail_screen.dart';
import 'package:painting_app/screens/edit_painting_screen.dart';

class ImpressionismPaintingCard extends StatelessWidget {
  final Painting painting;
  const ImpressionismPaintingCard({super.key, required this.painting});

  void _deletePainting() async {
    await painting.delete();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Painting'),
          content: Text('Are you sure you want to delete "${painting.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deletePainting();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImage(String path) {
    // Check if the path is an asset (initial data)
    if (path.startsWith('assets/')) {
      return Image.asset(
        width: 150,
        height: 164,
        path,
        fit: BoxFit.fill,

        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.palette_outlined, size: 40, color: Colors.grey),
        ),
      );
    }
    // Assume it's a local file path (user upload)
    else if (path.isNotEmpty) {
      return Image.file(
        width: 150,
        height: 164,
        File(path),
        fit: BoxFit.fill,

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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 7,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 7, right: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildImage(painting.imagePath),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        painting.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "Rs " +
                            NumberFormat("#,##0").format(painting.price) +
                            " PKR",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Artist',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        painting.artistName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        '${painting.averageRating.toStringAsFixed(1)} (${painting.reviews.length} reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditPaintingScreen(painting: painting),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/editlogo.png',
                        width: 30,
                        height: 45,
                      ),
                    ),
                    SizedBox(height: 50),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return Container(
                              child: AlertDialog(
                                backgroundColor: Colors.white,
                                title: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        "assets/images/app_logo.png",
                                        width: 70,
                                        height: 70,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Are you sure you want to delete this Painting?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff1E1A15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 38),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff979797),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _showDeleteConfirmation(context);
                                            ;
                                          },
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xffEA4235),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: Image.asset(
                        'assets/images/deletelogoicon.png',
                        width: 30,
                        height: 45,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),
            // Container(
            //   width: double.infinity,
            //   height: 52,
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [Colors.deepPurple.shade400, Colors.blue.shade400],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //     borderRadius: BorderRadius.circular(12),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.deepPurple.withOpacity(0.3),
            //         blurRadius: 8,
            //         offset: const Offset(0, 4),
            //       ),
            //     ],
            //   ),
            //   child: ElevatedButton.icon(
            //     onPressed: () => Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) =>
            //             PaintingDetailScreen(painting: painting),
            //       ),
            //     ),
            //     icon: const Icon(Icons.details, color: Colors.white, size: 20),
            //     label: const Text(
            //       'Check it',
            //       style: TextStyle(
            //         fontFamily: 'Montserrat',
            //         color: Colors.white,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.transparent,
            //       shadowColor: Colors.transparent,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),

            SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}
