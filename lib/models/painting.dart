import 'package:hive/hive.dart';
import 'review.dart'; 
part 'painting.g.dart';

@HiveType(typeId: 1) // 1. Type ID for the Painting model
class Painting extends HiveObject {
  // NOTE: All fields must be mutable (non-final) for HiveObject.save() to persist changes.

  @HiveField(0)
  String title; // 0: title

  @HiveField(1)
  String artistName; // 1: artistName

  @HiveField(2)
  String imagePath; // 2: RESTORED: Stores the permanent local file path for the image.

  @HiveField(3)
  double price; // 3: price (Index shifted from 2 to 3)

  @HiveField(4)
  String medium; // 4: medium

  @HiveField(5)
  DateTime creationDate; // 5: creationDate

  @HiveField(6)
  String description; // 6: description

  @HiveField(7)
  String category; // 7: category

  @HiveField(8)
  List<Review> reviews; // 8: reviews

  @HiveField(9)
  List<String> previousWorkImagePaths; // 9: previousWorkImagePaths

  @HiveField(10)
  bool isFavorite; // 10: NEW: isFavorite

  @HiveField(11)
  bool isInCart; // 11: NEW: isInCart


  Painting({
    required this.title,
    required this.artistName,
    required this.imagePath, // RESTORED in constructor
    required this.price,
    required this.medium,
    required this.creationDate,
    required this.description,
    required this.category,
    List<Review>? reviews,
    this.previousWorkImagePaths = const [],
    this.isFavorite = false,
    this.isInCart = false,
  }) : reviews = reviews ?? [];

  // Getter - does NOT require a @HiveField annotation
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.map((r) => r.rating).reduce((a, b) => a + b);
    return total / reviews.length;
  }
  
  // Method to add a review and save the HiveObject
  void addReview(Review review) {
    reviews.add(review);
    save(); 
  }

  // Method to toggle favorite status and save
  void toggleFavorite() {
    isFavorite = !isFavorite;
    save();
  }

  // Method to toggle cart status and save
  void toggleCart() {
    isInCart = !isInCart;
    save();
  }
}
