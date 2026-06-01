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

  // AGREGAR VALIDANDO STOCK MÁXIMO
  bool addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Si añadir uno más supera el stock disponible, detenemos la acción
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

  // PROCESAR ORDEN: REDUCE STOCK Y CREA LA COLECCIÓN DE "ORDERS"
  Future<void> placeOrder() async {
    if (_items.isEmpty) return;

    final List<Map<String, dynamic>> orderItems = [];
    
    // Iniciar una transacción o batch para asegurar que todo se guarde bien de golpe
    WriteBatch batch = _db.batch();

    _items.forEach((productId, cartItem) {
      // 1. Estructurar el producto para el historial de la orden (¡AHORA CON IMAGEN!)
      orderItems.add({
        'id': productId,
        'name': cartItem.product.name,
        'quantity': cartItem.quantity,
        'price': cartItem.product.price,
        'category': cartItem.product.category,
        'imageUrl': cartItem.product.imageUrl, // <-- AQUÍ AGREGAMOS LA IMAGEN
      });

      // 2. Preparar la reducción del stock en la colección 'products'
      DocumentReference realRef = _db.collection('products').doc(productId);
      int newStock = cartItem.product.stock - cartItem.quantity;
      batch.update(realRef, {'stock': newStock < 0 ? 0 : newStock});
    });

    // 3. Crear el documento de la orden en la colección 'orders'
    DocumentReference orderRef = _db.collection('orders').doc();
    batch.set(orderRef, {
      'dateTime': Timestamp.now(),
      'totalAmount': totalAmount, // <-- AQUÍ LE PUSIMOS EL NOMBRE CORRECTO PARA TU MODELO
      'items': orderItems,
      'status': 'Pendiente', // Lo dejamos en Pendiente para que lo gestiones después
    });

    // 4. Ejecutar todas las operaciones en Firebase simultáneamente
    await batch.commit();

    // 5. Limpiar el carrito localmente
    clearCart();
  }
}
