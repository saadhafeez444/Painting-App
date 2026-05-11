import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painting_app/models/painting.dart';
import 'package:painting_app/widgets/PaintingCard.dart';


// class ModernPaintingCard extends StatelessWidget {
//   final Painting painting;
//   const ModernPaintingCard({super.key, required this.painting});

//   @override
//   Widget build(BuildContext context) {
//     // Reuses the image logic from the standard card
//     final standardCard = PaintingCard(painting: painting); 

//     return Card(
//       elevation: 8, // Higher elevation
//       color: Colors.blueGrey.shade50, 
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//               child: standardCard._buildImage(painting.imagePath), // Accessing internal helper
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   painting.title,
//                   style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.blueGrey),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text('Artist: ${painting.artistName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Text('\$${painting.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
//                     const Spacer(),
//                     const Icon(Icons.star, color: Colors.amber, size: 16),
//                     Text(painting.averageRating.toStringAsFixed(1)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
