import 'package:hive/hive.dart';

part 'certificate.g.dart'; // You will need to run build_runner after this!

@HiveType(typeId: 5) // Use a new unique Type ID
class Certificate extends HiveObject {
  @HiveField(0)
  String name; // Certificate Name
  
  @HiveField(1)
  String organization; // Organization/Institution
  
  @HiveField(2)
  DateTime dateIssued; // Date of Certificate
  
  @HiveField(3)
  String filePath; // Path to local PDF or image file
  
  Certificate({
    required this.name,
    required this.organization,
    required this.dateIssued,
    this.filePath = '',
  });
}