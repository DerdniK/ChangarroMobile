import 'package:changarro_movile/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener productos en tiempo real
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList());
  }

  // Agregar nuevo producto incluyendo la URL de texto
  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  // Actualizar Stock
  Future<void> updateStock(String id, int newStock) async {
    await _db.collection('products').doc(id).update({'stock': newStock});
  }

  // Obtener todos los pedidos en tiempo real, ordenados por fecha (los más recientes primero)
  Stream<List<OrderModel>> getOrders() {
    // Asumimos que guardas los pedidos en una colección llamada 'orders'
    return _db.collection('orders')
        .orderBy('dateTime', descending: true) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Actualizar el estado de un pedido
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error al actualizar el estado: $e');
    }
  }
}