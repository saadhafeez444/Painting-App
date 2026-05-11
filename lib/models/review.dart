import 'package:hive/hive.dart';

part 'review.g.dart';

@HiveType(typeId: 0)
class Review extends HiveObject {
  @HiveField(0)
  final String reviewerName;
  
  @HiveField(1)
  final String comment; 
  
  @HiveField(2)
  // Reverted to double to support granular ratings (e.g., 4.5, 3.2)
  final double rating; 
  
  @HiveField(3)
  final String? reviewerImgUrl; 

  Review({
    required this.reviewerName,
    required this.comment, 
    // Type is double
    required this.rating, 
    this.reviewerImgUrl,
  });
}
