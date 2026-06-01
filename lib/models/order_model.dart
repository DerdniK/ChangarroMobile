import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerName;
  final double totalAmount; // Homologado a totalAmount
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
      // Blindaje: Busca 'totalAmount' o 'total' por si hay datos viejos
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
      'totalAmount': totalAmount, // Homologado a totalAmount al subir a Firebase
      'status': status,
      'dateTime': Timestamp.fromDate(date),
    };
  }
}