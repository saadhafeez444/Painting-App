import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:painting_app/key_constants/key_constants.dart';
import 'package:painting_app/models/certificate.dart';
import 'package:painting_app/screens/product_del/product_data.dart';
import 'package:painting_app/screens/splash_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:painting_app/models/painting.dart';
import 'package:painting_app/models/review.dart';
import 'package:painting_app/models/cart_item.dart';
import 'package:painting_app/models/user.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 Stripe.publishableKey = publishable_key;
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Painting App',
      theme: ThemeData(primarySwatch: Colors.blueGrey, useMaterial3: false),

      home: const InitializationScreen(),
    
    );
  }
}

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  bool _isHiveInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ReviewAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PaintingAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CartItemAdapter());
      }

      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(UserAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(UserRoleAdapter());
      }

      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(CertificateAdapter());
      }

      final paintingsBox = await Hive.openBox<Painting>('paintings');
      await Hive.openBox<CartItem>('cart_items');

      final usersBox = await Hive.openBox<User>('users');

      if (paintingsBox.isEmpty) {
        await _addInitialPaintings(paintingsBox);
      }

      if (usersBox.isEmpty) {
        await _addInitialAdmin(usersBox);
      }

      if (mounted) {
        setState(() {
          _isHiveInitialized = true;
        });
      }
    } catch (e) {
      print('FATAL HIVE/INIT ERROR: $e');
    }
  }

  Future<void> _addInitialAdmin(Box<User> usersBox) async {
    final adminUser = User(
      name: 'System Admin',
      email: 'admin@app.com',
      password: 'adminpassword',
      role: UserRole.admin,
      bio: 'Administrator with full system privileges.',
      gender: 'Male',
      phoneNumber: '555-0100',
    );
    await usersBox.add(adminUser);
  }

  Future<void> _addInitialPaintings(Box<Painting> box) async {
    const String defaultImagePath = 'assets/images/default.jpg';


    final List<Painting> initialPaintings = [
      Painting(
        title: 'Starry Night',
        description: 'A famous oil on canvas painting by Vincent van Gogh.',
        //  imagePath: fileExists ? defaultImagePath : 'assets/images/default.jpg',
        imagePath: 'assets/images/bg_p.png',
        price: 1500.00,
        artistName: 'Van Gogh',
        creationDate: DateTime(1889),
        medium: 'Oil on Canvas',
        reviews: [
          Review(
            reviewerName: 'ArtLover1',
            comment: 'Stunning depth!',
            rating: 5.0,
          ),
          Review(reviewerName: 'CriticA', comment: 'Overrated.', rating: 3.0),
          Review(
            reviewerName: 'GalleryGoer',
            comment: 'Captivating!',
            rating: 4.5,
          ),
          Review(reviewerName: 'Newbie', comment: 'Looks cool.', rating: 4.0),
          Review(reviewerName: 'Pro', comment: 'Masterpiece.', rating: 5.0),
        ],
        previousWorkImagePaths: [
          'assets/images/default.jpg',
          'assets/images/default.jpg',
          'assets/images/default.jpg',
          'assets/images/default.jpg',
          'assets/images/default.jpg',
        ],
        category: 'Impressionism',
      ),
      Painting(
        title: 'Mona Lisa',
        description: 'Portrait by Leonardo da Vinci.',
        imagePath: 'assets/images/default.jpg',
        price: 5000.00,
        artistName: 'Da Vinci',
        creationDate: DateTime(1503),
        medium: 'Oil on poplar panel',
        reviews: [
          Review(reviewerName: 'Fan', comment: 'That smile!', rating: 5.0),
          Review(reviewerName: 'Hater', comment: 'Small size.', rating: 2.0),
          Review(
            reviewerName: 'Historian',
            comment: 'Iconic and influential.',
            rating: 5.0,
          ),
          Review(
            reviewerName: 'Tourist',
            comment: 'Worth the wait.',
            rating: 4.0,
          ),
          Review(
            reviewerName: 'Expert',
            comment: 'Sfumato is superb.',
            rating: 5.0,
          ),
        ],
        previousWorkImagePaths: [
          'assets/images/default.jpg',
          'assets/images/default.jpg',
          'assets/images/default.jpg',
          'assets/images/default.jpg',
          'assets/images/default.jpg',
        ],
        category: 'Portraiture',
      ),
    ];
    await box.addAll(initialPaintings);
  }

  @override
  Widget build(BuildContext context) {
    if (_isHiveInitialized) {
      // return const AuthScreens();
      return  SplashScreen();
    }

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing Hive Database...'),
          ],
        ),
      ),
    );
  }
}
