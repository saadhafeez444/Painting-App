import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:painting_app/models/cart_item.dart';
import 'package:painting_app/models/painting.dart';
import 'package:painting_app/screens/detail_screen.dart';
import 'package:painting_app/widgets/image_placeholder.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _removeItemFromCart(BuildContext context, CartItem cartItem) async {
    final paintingsBox = Hive.box<Painting>('paintings');
    final painting = paintingsBox.get(cartItem.paintingKey);

    if (painting != null) {
      painting.toggleCart();
    }

    final title = painting?.title ?? 'Item';
    await cartItem.delete();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title removed from cart.')));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<CartItem>>(
      valueListenable: Hive.box<CartItem>('cart_items').listenable(),
      builder: (context, cartBox, _) {
        // final cartItems = cartBox.values.toList().cast<CartItem>();
        // final paintingsBox = Hive.box<Painting>('paintings');

        // double totalPrice = 0.0;
        // for (var item in cartItems) {
        //   final painting = paintingsBox.get(item.paintingKey);
        //   if (painting != null) {
        //     totalPrice += painting.price * item.quantity;
        //   }
        // }
        final cartItems = cartBox.values.toList(); // REMOVE .cast<CartItem>()
  final paintingsBox = Hive.box<Painting>('paintings');

  double totalPrice = 0.0;
  for (var item in cartItems) {
    // You should use item.paintingKey which is already the correct type (Object?)
    final painting = paintingsBox.get(item.paintingKey); 
    if (painting != null) {
      totalPrice += painting.price * item.quantity;
    }
  }

        if (cartItems.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Cart 🛒')),
            body: const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Cart 🛒',
              style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
            ),
            centerTitle: true,
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      final painting = paintingsBox.get(cartItem.paintingKey);

                      if (painting == null) {
                        cartItem.delete();
                        return const SizedBox.shrink();
                      }

                      return Dismissible(
                        key: Key(cartItem.key.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) =>
                            _removeItemFromCart(context, cartItem),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          color: Colors.white,
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: painting.imagePath.startsWith('assets/')
                                    ? DecorationImage(
                                        image: AssetImage(painting.imagePath),
                                        fit: BoxFit.fill,
                                      )
                                    : (File(painting.imagePath).existsSync()
                                          ? DecorationImage(
                                              image: FileImage(
                                                File(painting.imagePath),
                                              ),
                                              fit: BoxFit.fill,
                                            )
                                          : null),
                              ),

                              child:
                                  !painting.imagePath.startsWith('assets/') &&
                                      !File(painting.imagePath).existsSync()
                                  ? ImagePlaceholder()
                                  : null,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PaintingDetailScreen(painting: painting),
                                ),
                              );
                            },
                            title: Text(painting.title , 
                            maxLines: 1, 
  overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                                                          maxLines: 1, 
  overflow: TextOverflow.ellipsis,
                              'Price: \$${painting.price.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: cartItem.quantity > 1
                                      ? cartItem.decrementQuantity
                                      : null,
                                  color: Colors.blue,
                                ),
                                Text('${cartItem.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: cartItem.incrementQuantity,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Total Price Footer
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ).copyWith(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement checkout logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proceeding to Checkout!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
