import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerName;
  final double totalAmount;
  final String status; 
  final DateTime date;
  final List<dynamic> items; 
  final String userId; 

  OrderModel({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.items,
    required this.userId,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      customerName: data['customerName'] ?? 'Cliente Desconocido',
      // el total lo deje porque hay datos viejos
      totalAmount: (data['totalAmount'] ?? data['total'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pendiente',
      date: data['dateTime'] != null ? data['dateTime'].toDate() : DateTime.now(),
      items: data['items'] ?? [],
      userId: data['userId'] ?? '', 
    );  
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId, 
      'customerName': customerName, 
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'dateTime': Timestamp.fromDate(date),
    };
  }
}