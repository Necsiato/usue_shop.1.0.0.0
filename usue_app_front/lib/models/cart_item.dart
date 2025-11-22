import 'product_model.dart';

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final ProductModel product;
  int quantity;

  double get subtotal => quantity * product.price;
}
