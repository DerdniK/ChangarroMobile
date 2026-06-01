import 'package:changarro_movile/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener productos
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList());
  }

  // Agregar nuevo producto
  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  // Actualizar Stock
  Future<void> updateStock(String id, int newStock) async {
    await _db.collection('products').doc(id).update({'stock': newStock});
  }

  // Obtener pedidos
  Stream<List<OrderModel>> getOrders({String? userId}) {
    CollectionReference ordersRef = _db.collection('orders');
    Query query = ordersRef.orderBy('dateTime', descending: true);

    // Si hay userid filtramos por ese usuario, si no es admin
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Actualizar el estado de pedido
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error al actualizar el estado: $e');
    }
  }

  // Obtener el rol desde Firestore
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.get('role') ?? 'user';
      }
      // Si no existe el documento, por seguridad es 'user' normal
      return 'user';
    } catch (e) {
      return 'user';
    }
  }

  // Actualizar un producto existente
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.collection('products').doc(id).update(data);
  }

  // Eliminar un producto del catqlogo
  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // Obtener los datos completos del usuario desde db
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}