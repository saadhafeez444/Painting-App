import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:painting_app/screens/category_painting_screen.dart';
import 'package:painting_app/screens/detail_screen.dart';
import 'package:painting_app/screens/upload_paintings.dart';
import 'package:painting_app/widgets/Impression_card.dart';
import 'package:painting_app/widgets/PaintingCard.dart';
import 'package:painting_app/widgets/abstract_card.dart';
import 'package:painting_app/widgets/landscape_card.dart';
import 'package:painting_app/widgets/portraiture_card.dart';
import 'dart:io';
import '../models/painting.dart';

const int maxPaintingsToShow = 6;
const List<String> availableCategories = [
  'Abstract',
  'Impressionism',
  'Portraiture',
  'Landscape',
  'Modern',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Painting>>(
      valueListenable: Hive.box<Painting>('paintings').listenable(),
      builder: (context, Box<Painting> box, _) {
        final allPaintings = box.values.toList();

        final filteredPaintings = allPaintings.where((painting) {
          return painting.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
        }).toList();

        final bool isSearching = _searchQuery.isNotEmpty;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade500, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            title: const Text(
              'Art Gallery',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),

            // bottom: PreferredSize(
            //   preferredSize: const Size.fromHeight(60.0),
            //   child: 
            //   Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: TextField(
            //       controller: _searchController,
            //       decoration: InputDecoration(
            //         hintText: 'Search by title...',
            //         prefixIcon: const Icon(Icons.search),
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(20),
            //           borderSide: BorderSide.none,
            //         ),
            //         filled: true,
            //         fillColor: Colors.white,
            //       ),
            //       onChanged: (value) {
            //         setState(() {
            //           _searchQuery = value;
            //         });
            //       },
            //     ),
            //   ),
            
            // ),
          ),
          body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by title...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    ),
    Expanded(
      child: _searchQuery.isNotEmpty
          ? _buildSearchGrid(
              allPaintings.where((painting) {
                final title = painting.title.toLowerCase();
                final query = _searchQuery.toLowerCase();
                return title.contains(query);
              }).toList(),
            )
          : _buildCategoryList(allPaintings),
    ),
  ],
),

        );
      },
    );
  }

  Widget _buildSearchGrid(List<Painting> paintings) {
    if (paintings.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(child: Text('No paintings found for this search.'));
    }
    if (paintings.isEmpty) {
      return const Center(child: Text('No paintings have been added yet.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.7,
      ),
      itemCount: paintings.length,
      itemBuilder: (context, index) {
        final painting = paintings[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaintingDetailScreen(painting: painting),
              ),
            );
          },
          child: PaintingCard(painting: painting),
        );
      },
    );
  }

  Widget _buildCategoryList(List<Painting> allPaintings) {
    if (allPaintings.isEmpty) {
      return const Center(child: Text('No paintings have been added yet.'));
    }

    final categoryRows = availableCategories.map((categoryName) {
      final categoryPaintings = allPaintings
          .where((p) => p.category == categoryName)
          .toList();
      
      if (categoryPaintings.isEmpty) {
        return const SizedBox.shrink();
      }


      switch (categoryName) {
        case 'Abstract':
          return AbstractCategoryRow(allPaintings: allPaintings);
        case 'Impressionism':
          return ImpressionismCategoryRow(allPaintings: allPaintings);
        case 'Portraiture':
          return PortraitureCategoryRow(allPaintings: allPaintings);
        case 'Landscape':
          return LandscapeCategoryRow(allPaintings: allPaintings);
        case 'Modern':
          return ModernCategoryRow(allPaintings: allPaintings);
        default:
          return const SizedBox.shrink();
      }
    }).toList();

    return ListView(children: categoryRows);
  }
}

abstract class CategoryRowBase extends StatelessWidget {
  final String category;
  final List<Painting> allPaintings;
  final double cardWidthFactor;
  final double rowHeight;
  const CategoryRowBase({
    super.key,
    required this.category,
    required this.allPaintings,
    required this.cardWidthFactor,
    required this.rowHeight,
  });

  
  Widget buildCategoryCard(Painting painting);

  @override
  Widget build(BuildContext context) {
    final categoryPaintings = allPaintings
        .where((p) => p.category == category)
        .toList();

    if (categoryPaintings.isEmpty) return const SizedBox.shrink();

    // Determine if we need to show the 'More' card
    final bool hasMore = categoryPaintings.length > maxPaintingsToShow;

    // The list of items to display (max 6 paintings + optional arrow)
    final List<Painting> slicedPaintings = categoryPaintings.sublist(
      0,
      categoryPaintings.length > maxPaintingsToShow
          ? maxPaintingsToShow
          : categoryPaintings.length,
    );

    // List of widgets to render in the horizontal list
    final List<Widget> rowItems = [];

    // 1. Add all sliced painting cards
    for (final painting in slicedPaintings) {
      rowItems.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * cardWidthFactor,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PaintingDetailScreen(painting: painting),
                  ),
                );
              },
              child: buildCategoryCard(
                painting,
              ), // Calls the specialized card builder
            ),
          ),
        ),
      );
    }

    
    if (hasMore) {
      rowItems.add(
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: MoreContentCard(
            category: category,
            paintings: categoryPaintings,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Category Name + See All Button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPaintingsScreen(
                          category: category,
                          paintings: categoryPaintings,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),

          // Horizontal Painting List
          SizedBox(
            height: rowHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 5.0),
              children: rowItems,
            ),
          ),
        ],
      ),
    );
  }
}

// 1. Abstract: ~3 cards per row (1/3.2)
class AbstractCategoryRow extends CategoryRowBase {
  const AbstractCategoryRow({super.key, required super.allPaintings})
    : super(category: 'Abstract', cardWidthFactor: 1 / 3.3, rowHeight: 210);

  @override
  Widget buildCategoryCard(Painting painting) {
    return AbstractCard(painting: painting); // Default Card
  }
}

class ImpressionismCategoryRow extends CategoryRowBase {
  const ImpressionismCategoryRow({super.key, required super.allPaintings})
    : super(
        category: 'Impressionism',
        cardWidthFactor: 1 / 1.05,
        rowHeight: 220,
      );

  @override
  Widget buildCategoryCard(Painting painting) {
    return ImpressionismPaintingCard(painting: painting); // Default Card
  }
}

// 3. Portraiture: ~2 cards per row (1/2.2)
class PortraitureCategoryRow extends CategoryRowBase {
  const PortraitureCategoryRow({super.key, required super.allPaintings})
    : super(category: 'Portraiture', cardWidthFactor: 1 / 2.2, rowHeight: 300);

  @override
  Widget buildCategoryCard(Painting painting) {
    return PortraitureCard(painting: painting); // Default Card
  }
}

// 4. Landscape: ~2.5 cards per row (1/2.7)
class LandscapeCategoryRow extends CategoryRowBase {
  const LandscapeCategoryRow({super.key, required super.allPaintings})
    : super(category: 'Landscape', cardWidthFactor: 1 / 2.7, rowHeight: 250);

  @override
  Widget buildCategoryCard(Painting painting) {
    return LandscapeCard(painting: painting); // Default Card
  }
}

// 5. Modern: Custom card design (~2 cards per row)
class ModernCategoryRow extends CategoryRowBase {
  const ModernCategoryRow({super.key, required super.allPaintings})
    : super(category: 'Modern', cardWidthFactor: 1 / 2.2, rowHeight: 250);

  @override
  Widget buildCategoryCard(Painting painting) {
    // Use the special Modern Card for this category
    return ModernPaintingCard(painting: painting);
  }
}

// --- Reusable Painting Card Widget (Handles assets/local files) ---

class PaintingCard extends StatelessWidget {
  final Painting painting;
  const PaintingCard({super.key, required this.painting});

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
        fit: BoxFit.cover,
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
    return Card(
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
                    Text(
                      '${painting.averageRating.toStringAsFixed(1)} (${painting.reviews.length} reviews)',
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
    );
  }
}

// --- Modern Category Card (Special Design) ---

class ModernPaintingCard extends StatelessWidget {
  final Painting painting;
  const ModernPaintingCard({super.key, required this.painting});

  @override
  Widget build(BuildContext context) {
    // Reuses the image logic from the standard card
    final standardCard = PaintingCard(painting: painting);

    return Card(
      elevation: 8, // Higher elevation
      color: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: standardCard._buildImage(
                painting.imagePath,
              ), // Accessing internal helper
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  painting.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.blueGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Artist: ${painting.artistName}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${painting.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(painting.averageRating.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- More Content Arrow Card ---
class MoreContentCard extends StatelessWidget {
  final String category;
  final List<Painting> paintings;

  const MoreContentCard({
    super.key,
    required this.category,
    required this.paintings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the See All screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPaintingsScreen(
              category: category,
              paintings: paintings,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 120, // Fixed width for the arrow card
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View All (${paintings.length})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 30,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
