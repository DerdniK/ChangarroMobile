// lib/models/order_model.dart

class OrderModel {
  final String id;
  final String customerName;
  final double totalAmount;
  final String status; // Ej: 'Pendiente', 'Enviado', 'Entregado'
  final DateTime date;
  final List<dynamic> items; // Lista de productos (puedes estructurarlo mejor luego)

  OrderModel({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.items,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      customerName: data['customerName'] ?? 'Cliente Desconocido',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pendiente',
      // Firestore guarda las fechas como Timestamp
      date: data['dateTime'] != null ? data['dateTime'].toDate() : DateTime.now(),
      items: data['items'] ?? [],
    );
  }
}