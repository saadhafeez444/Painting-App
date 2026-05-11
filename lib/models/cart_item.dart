import 'package:hive/hive.dart';

part 'cart_item.g.dart';



@HiveType(typeId: 2) // 2. Type ID for the CartItem model
class CartItem extends HiveObject {
  @HiveField(0)
  // dynamic paintingKey; // 0: The key of the associated Painting in the 'paintings' box
Object? paintingKey;
  @HiveField(1)
  int quantity; 

  CartItem({
    required this.paintingKey,
    this.quantity = 1,
  });

  // Method to increment quantity and save
  void incrementQuantity() {
    quantity++;
    save();
  }

  // Method to decrement quantity and save
  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
      save();
    }
  }

  // Note: We don't store the painting itself, only its key.
  // The cart screen will look up the Painting object using this key.
}
