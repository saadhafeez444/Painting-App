import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/painting.dart';
import '../models/review.dart';

class HiveService {
  static const String _paintingBoxName = 'paintings';

  static Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
   
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PaintingAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReviewAdapter());
    }

    await Hive.openBox<Painting>(_paintingBoxName);
  
    if (getPaintings().isEmpty) {
      _addInitialPaintings();
    }
  }


  static List<Painting> getPaintings() {
    final box = Hive.box<Painting>(_paintingBoxName);
    return box.values.toList();
  }


  static Future<void> addPainting(Painting painting) async {
    final box = Hive.box<Painting>(_paintingBoxName);
    await box.add(painting); 
  }


  static Future<void> updatePainting(Painting oldPainting, Painting newPainting) async {
    final box = Hive.box<Painting>(_paintingBoxName);

    if (oldPainting.isInBox) {
      await box.put(oldPainting.key, newPainting);
    }
  }


  static Future<void> deletePainting(Painting painting) async {
  
    await painting.delete();
  }


  static void _addInitialPaintings() {

    final box = Hive.box<Painting>(_paintingBoxName);

    const String defaultImagePath = 'assets/placeholder.png'; 

    final List<Painting> initialPaintings = [
      Painting(
      
        title: 'Starry Night',
        description: 'A famous oil on canvas painting by Vincent van Gogh.',
        imagePath: defaultImagePath,
        price: 1500.00,
        artistName: 'Van Gogh',
        creationDate: DateTime(1889),
        medium: 'Oil on Canvas',
        reviews: [
          Review(reviewerName: 'ArtLover1', comment: 'Stunning depth!', rating: 5.0),
          Review(reviewerName: 'CriticA', comment: 'Overrated.', rating: 3.0),
          Review(reviewerName: 'GalleryGoer', comment: 'Captivating!', rating: 4.5),
          Review(reviewerName: 'Newbie', comment: 'Looks cool.', rating: 4.0),
          Review(reviewerName: 'Pro', comment: 'Masterpiece.', rating: 5.0),
        ],
          previousWorkImagePaths: [
      'assets/images/img1.jpg',
      'assets/images/img2.jpg',
      'assets/images/img3.jpg',
      'assets/images/img4.jpg',
      'assets/images/img5.jpg',
    ],
            category: 'Impressionism',
      ),
  
      Painting(
      
        title: 'Mona Lisa',
        description: 'Portrait by Leonardo da Vinci.',
        imagePath: defaultImagePath,
        price: 5000.00,
        artistName: 'Da Vinci',
        creationDate: DateTime(1503),
        medium: 'Oil on poplar panel',
        reviews: [
          Review(reviewerName: 'Fan', comment: 'That smile!', rating: 5.0),
          Review(reviewerName: 'Hater', comment: 'Small size.', rating: 2.0),
          Review(reviewerName: 'Historian', comment: 'Iconic and influential.', rating: 5.0),
          Review(reviewerName: 'Tourist', comment: 'Worth the wait.', rating: 4.0),
          Review(reviewerName: 'Expert', comment: 'Sfumato is superb.', rating: 5.0),
        ],
          previousWorkImagePaths: [
      'assets/images/img1.jpg',
      'assets/images/img2.jpg',
      'assets/images/img3.jpg',
      'assets/images/img4.jpg',
      'assets/images/img5.jpg',
    ],
     category: 'Renaissance',
      ),

    ];

    box.addAll(initialPaintings);
  }


}