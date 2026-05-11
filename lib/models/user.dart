import 'package:hive/hive.dart';
import 'package:painting_app/models/certificate.dart';

part 'user.g.dart';

@HiveType(typeId: 4) // Assign a new type ID for the Role Enum
enum UserRole {
  @HiveField(0)
  user,
  @HiveField(1)
  admin,
  @HiveField(2)
  artist,
}

@HiveType(typeId: 3) // Assign a new type ID for the User Model
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password; // Stored directly for demo purposes (use hashing in production)

  @HiveField(3)
  UserRole role;

  // Profile fields
  @HiveField(4)
  String imagePath; // Path to local file for profile picture

  @HiveField(5)
  String bio;

  @HiveField(6)
  List<String> interests; // Used with ChoiceChips

  @HiveField(7)
  String gender;

  @HiveField(8)
  String phoneNumber;

  @HiveField(9)
  DateTime? dateOfBirth;

  // Artist-specific fields
  @HiveField(10)
  List<Certificate> certificates; 

  @HiveField(11)
  double experienceYears;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.imagePath = '',
    this.bio = '',
    List<String>? interests,
    this.gender = '',
    this.phoneNumber = '',
    this.dateOfBirth,
   List<Certificate>? certificates,
    this.experienceYears = 0.0,
  }) : interests = interests ?? [],
  certificates = certificates ?? [];
  

  // Method to update and save the profile
  void updateProfile({
    String? name,
    String? bio,
    List<String>? interests,
    String? gender,
    String? phoneNumber,
    DateTime? dateOfBirth,
    List<Certificate>? certificates,
    double? experienceYears,
    String? imagePath,
  }) {
    this.name = name ?? this.name;
    this.bio = bio ?? this.bio;
    this.interests = interests ?? this.interests;
    this.gender = gender ?? this.gender;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.dateOfBirth = dateOfBirth ?? this.dateOfBirth;
    this.certificates = certificates ?? this.certificates;
    this.experienceYears = experienceYears ?? this.experienceYears;
    this.imagePath = imagePath ?? this.imagePath;

    save();
  }
}
