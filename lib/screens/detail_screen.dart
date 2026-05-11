import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:painting_app/models/cart_item.dart';
import 'package:painting_app/screens/cart_screen.dart';
import 'package:painting_app/screens/edit_painting_screen.dart';
import 'package:painting_app/screens/favourite_screen.dart';
import 'package:painting_app/screens/home_screen.dart';
import 'package:painting_app/screens/navigation_screen.dart';
import 'package:painting_app/screens/payment_screen.dart';
import '../models/painting.dart';
import '../models/review.dart';

class PaintingDetailScreen extends StatefulWidget {
  final Painting painting;
  const PaintingDetailScreen({super.key, required this.painting});

  @override
  State<PaintingDetailScreen> createState() => _PaintingDetailScreenState();
}

class _PaintingDetailScreenState extends State<PaintingDetailScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  double _reviewRating = 5.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isFavorite = false;

  late bool _isInCart;
  bool _isDescriptionExpanded = false;
  Future<void> _toggleCart(BuildContext context) async {
    final currentPainting = widget.painting;
    final cartItemsBox = Hive.box<CartItem>('cart_items');
    final paintingKey = currentPainting.key;
    final title = currentPainting.title;

    if (_isInCart) {
      CartItem? itemToRemove;
      try {
        itemToRemove = cartItemsBox.values.cast<CartItem>().firstWhere(
          (item) => item.paintingKey == paintingKey,
        );
      } catch (e) {}

      if (itemToRemove != null) {
        await itemToRemove.delete();
      }

      currentPainting.toggleCart();
      setState(() {
        _isInCart = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"$title" removed from cart.')));
    } else {
      final newCartItem = CartItem(paintingKey: paintingKey, quantity: 1);
      await cartItemsBox.add(newCartItem);

      currentPainting.toggleCart();
      setState(() {
        _isInCart = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"$title" added to cart!')));
    }
  }

  void _navigateToPayment(Painting book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen(book: book)),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();

    _isFavorite = widget.painting.isFavorite;
    _isInCart = widget.painting.isInCart;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_nameController.text.isEmpty || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill in your name and review.',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final newReview = Review(
      reviewerName: _nameController.text,
      comment: _reviewController.text,
      rating: _reviewRating,
    );

    widget.painting.addReview(newReview);

    _nameController.clear();
    _reviewController.clear();
    _reviewRating = 5.0;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _deletePainting() async {
    await widget.painting.delete();

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => NavigationScreen()),
    // );
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade50, Colors.purple.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Your Review',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildAnimatedTextField(
                          controller: _nameController,
                          label: 'Your Name',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildAnimatedTextField(
                          controller: _reviewController,
                          label: 'Your Review',
                          icon: Icons.comment,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Rating: ',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _reviewRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Slider(
                                  value: _reviewRating,
                                  min: 1.0,
                                  max: 5.0,
                                  divisions: 8,
                                  activeColor: Colors.amber,
                                  inactiveColor: Colors.amber.shade100,
                                  onChanged: (double value) {
                                    setState(() {
                                      _reviewRating = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '1.0',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '5.0',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: Colors.deepPurple.withOpacity(0.4),
                            ),
                            child: Text(
                              'Submit Review',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Montserrat'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Montserrat'),
          alignLabelWithHint: true,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.purple.shade100],
        ),
      ),
      child: const Icon(Icons.image, size: 60, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Painting>>(
      valueListenable: Hive.box<Painting>('paintings').listenable(),
      builder: (context, Box<Painting> box, _) {
        final currentPainting = box.get(widget.painting.key);
        if (currentPainting == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return Scaffold(

            body: Center(
              child: Text(
                'Painting not found.',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
          );
        }

        final cartBox = Hive.box<CartItem>('cart_items');

        return Scaffold(
                      floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(book: widget.painting),
                  ),
                );
              },
              child: Icon(Icons.payment, color: Colors.white,),
            ),
           
           
           
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              currentPainting.title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
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
          ),
          body: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Hero(
                    tag: 'painting-${currentPainting.key}',
                    child: Container(
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: currentPainting.imagePath.isNotEmpty
                            ? (currentPainting.imagePath.startsWith('assets/')
                                  ? Image.asset(
                                      currentPainting.imagePath,
                                      fit: BoxFit.fill,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildPlaceholder(),
                                    )
                                  : (File(
                                          currentPainting.imagePath,
                                        ).existsSync()
                                        ? Image.file(
                                            File(currentPainting.imagePath),
                                            fit: BoxFit.fill,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    _buildPlaceholder(),
                                          )
                                        : _buildPlaceholder()))
                            : _buildPlaceholder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildParameterCard(
                    title: 'Title',
                    value: currentPainting.title,
                    icon: Icons.title,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  _buildParameterCard(
                    title: 'Price',
                    value: '\$${currentPainting.price.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),

                  // Artist Card
                  _buildParameterCard(
                    title: 'Artist',
                    value: currentPainting.artistName,
                    icon: Icons.person,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),

                  // Medium Card
                  _buildParameterCard(
                    title: 'Medium',
                    value: currentPainting.medium,
                    icon: Icons.brush,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),

                  _buildParameterCard(
                    title: 'Date Created',
                    value: DateFormat(
                      'MMMM dd, yyyy',
                    ).format(currentPainting.creationDate),
                    icon: Icons.calendar_today,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),

                  _buildParameterCard(
                    title: 'Category',
                    value: currentPainting.category,
                    icon: Icons.category,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, color: Colors.deepPurple),
                              const SizedBox(width: 12),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState: _isDescriptionExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPainting.description,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (currentPainting.description.length > 150)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isDescriptionExpanded = true;
                                      });
                                    },
                                    child: Text(
                                      'Read More',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPainting.description,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isDescriptionExpanded = false;
                                    });
                                  },
                                  child: Text(
                                    'Read Less',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 45,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                            currentPainting.toggleFavorite();
                          },
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isFavorite
                                ? 'Remove from Favorites'
                                : 'Add to Favorites',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFavorite
                                ? Colors.red
                                : Colors.pink.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      // Cart Button
                      Container(
                        width: double.infinity,
                        height: 45,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _toggleCart(context);
                          },
                          icon: Icon(
                            _isInCart
                                ? Icons.shopping_cart
                                : Icons.add_shopping_cart,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isInCart ? 'Remove from Cart' : 'Add to Cart',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isInCart
                                ? Colors.green
                                : Colors.amber.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          margin: const EdgeInsets.only(right: 8),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPaintingScreen(
                                    painting: currentPainting,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Edit',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          height: 45,
                          margin: const EdgeInsets.only(left: 8),
                          child: ElevatedButton.icon(
                            onPressed: () => _showDeleteConfirmation(context),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating Section with Add Review Button
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentPainting.averageRating.toStringAsFixed(1)} Average Rating',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${currentPainting.reviews.length} Reviews',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showReviewDialog,
                            icon: const Icon(Icons.add_comment),
                            label: const Text(
                              'Add Review',
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reviews Expansion Tile
                  if (currentPainting.reviews.isNotEmpty)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.reviews,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(
                          'Customer Reviews (${currentPainting.reviews.length})',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        children: [
                          ...currentPainting.reviews.map(
                            (review) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: _buildReviewCard(review),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Previous Work Section
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 9,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.work_history,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Previous Work by Artist',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (currentPainting.previousWorkImagePaths.isNotEmpty)
                            _buildPreviousWorkGrid(
                              currentPainting.previousWorkImagePaths,
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'No previous work images available',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParameterCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final firstName = review.reviewerName.split(' ').first;
    final avatarText = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatarText,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.reviewerName,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              review.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reviewed on ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousWorkGrid(List<String> imagePaths) {
    return Column(
      children: [
        if (imagePaths.length >= 2)
          Row(
            children: [
              Expanded(
                child: _buildPreviousWorkImage(imagePaths[0], height: 180),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPreviousWorkImage(imagePaths[1], height: 180),
              ),
            ],
          )
        else if (imagePaths.length == 1)
          _buildPreviousWorkImage(imagePaths[0], height: 180),

        if (imagePaths.length > 2)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                ...imagePaths
                    .skip(2)
                    .take(3)
                    .map(
                      (path) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildPreviousWorkImage(path, height: 120),
                        ),
                      ),
                    ),
              ],
            ),
          ),
      ],
    );
  }

  // Widget _buildPreviousWorkImage(String path, {required double height}) {
  //   return Container(
  //     height: height,
  //     margin: const EdgeInsets.symmetric(vertical: 4),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.2),
  //           blurRadius: 8,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(12),
  //       child: path.isNotEmpty && File(path).existsSync()
  //           ? Image.file(File(path), fit: BoxFit.fill)
  //           : Container(
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   colors: [Colors.grey.shade300, Colors.grey.shade400],
  //                 ),
  //               ),
  //               child: const Center(
  //                 child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
  //               ),
  //             ),
  //     ),
  //   );
  // }

  Widget _buildPreviousWorkPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade400],
        ),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildPreviousWorkImage(String path, {required double height}) {
    Widget imageWidget;

    if (path.isEmpty) {
      imageWidget = _buildPreviousWorkPlaceholder();
    } else if (path.startsWith('assets/')) {
      imageWidget = Image.asset(
        path,
        fit: BoxFit.fill,

        errorBuilder: (context, error, stackTrace) =>
            _buildPreviousWorkPlaceholder(),
      );
    } else if (File(path).existsSync()) {
      imageWidget = Image.file(
        File(path),
        fit: BoxFit.fill,

        errorBuilder: (context, error, stackTrace) =>
            _buildPreviousWorkPlaceholder(),
      );
    } else {
      imageWidget = _buildPreviousWorkPlaceholder();
    }

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageWidget,
      ),
    );
  }

  void _handleCartAction(Painting currentPainting, Box<CartItem> cartBox) {
    if (currentPainting.isInCart) {
      final cartItemToRemove = cartBox.values.cast<CartItem>().firstWhere(
        (item) => item.paintingKey == currentPainting.key,
        orElse: () => null as CartItem,
      );
      cartItemToRemove?.delete();
      currentPainting.toggleCart();
    } else {
      final newCartItem = CartItem(
        paintingKey: currentPainting.key,
        quantity: 1,
      );
      cartBox.add(newCartItem);
      currentPainting.toggleCart();
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade50, Colors.orange.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Delete Painting',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to delete "${widget.painting.title}"?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _deletePainting();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
