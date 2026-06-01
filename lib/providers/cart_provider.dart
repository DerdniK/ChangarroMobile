import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  // validacion de stock 
  bool addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // si se supera el stock se detiene
      if (_items[product.id]!.quantity >= product.stock) {
        return false; 
      }
      _items.update(product.id, (existing) => CartItem(product: existing.product, quantity: existing.quantity + 1));
    } else {
      if (product.stock <= 0) return false;
      _items.putIfAbsent(product.id, () => CartItem(product: product));
    }
    notifyListeners();
    return true;
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(productId, (existing) => CartItem(product: existing.product, quantity: existing.quantity - 1));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // reduce stock y crea la coleccion donde se guardan las ordenes
  Future<void> placeOrder(String currentUserId, String customerName) async { 
    if (_items.isEmpty) return;

    final List<Map<String, dynamic>> orderItems = [];
    
    // Iniciar una transacción o batch para asegurar que todo se guarde bien de golpe
    WriteBatch batch = _db.batch();

    _items.forEach((productId, cartItem) {
      // estructurar cada item para la orden
      orderItems.add({
        'id': productId,
        'name': cartItem.product.name,
        'quantity': cartItem.quantity,
        'price': cartItem.product.price,
        'category': cartItem.product.category,
        'imageUrl': cartItem.product.imageUrl, 
      });

      // reducir el stock en la base de datos
      DocumentReference realRef = _db.collection('products').doc(productId);
      int newStock = cartItem.product.stock - cartItem.quantity;
      batch.update(realRef, {'stock': newStock < 0 ? 0 : newStock});
    });

    // crear la orden en la colección 'orders'
    DocumentReference orderRef = _db.collection('orders').doc();
    batch.set(orderRef, {
      'userId': currentUserId,
      'customerName': customerName, 
      'dateTime': Timestamp.now(),
      'total': totalAmount, 
      'items': orderItems,
      'status': 'Pendiente', 
    });

    // ejecutar el batch
    await batch.commit();

    clearCart();
  }
}
