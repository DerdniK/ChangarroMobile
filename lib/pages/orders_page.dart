import 'package:flutter/material.dart';
import '../database/firebase_service.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart'; 
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersPage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final bool isAdminView; 

  OrdersPage({super.key, required this.isAdminView});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'Invitado';
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(isAdminView ? 'PANEL DE CONTROL (ADMIN)' : 'MIS PEDIDOS'),
        backgroundColor: isAdminView ? const Color(0xFFFF5722) : const Color(0xFFFFB300),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _firebaseService.getOrders(
          userId: isAdminView ? null : userId
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay pedidos registrados.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              
              final dateFormated = DateFormat('dd/MM/yyyy HH:mm').format(order.date);

              Color statusColor = Colors.grey;
              if (order.status.toLowerCase() == 'pendiente') statusColor = const Color(0xFFFF5722);
              if (order.status.toLowerCase() == 'entregado' || order.status.toLowerCase() == 'completada') statusColor = Colors.green;

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile( 
                  iconColor: const Color(0xFFFFB300),
                  collapsedIconColor: Colors.white54,
                  title: Text(
                    order.customerName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    dateFormated,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(order.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  children: [
                    const Divider(color: Colors.white24, height: 1),
                    ...order.items.map<Widget>((itemData) {
                      
                      final String name = itemData['name'] ?? 'Producto sin nombre';
                      final int quantity = itemData['quantity'] ?? 1;
                      final double price = (itemData['price'] ?? 0.0).toDouble();
                      final String imageUrl = itemData['imageUrl'] ?? ''; 

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl.isNotEmpty
                              ? Image.file(
                                  File(imageUrl), 
                                  width: 50, 
                                  height: 50, 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 50, height: 50, color: const Color(0xFF2D2D2D),
                                    child: const Icon(Icons.broken_image, color: Colors.white54),
                                  ),
                                )
                              : Container(
                                  width: 50, height: 50, color: const Color(0xFF2D2D2D),
                                  child: const Icon(Icons.image, color: Colors.white54),
                                ),
                        ),
                        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('\$${price.toStringAsFixed(2)} c/u', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(
                            'x$quantity', 
                            style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                        ),
                      );
                    }).toList(), 
                    
                    const SizedBox(height: 10), 

                    if (isAdminView && order.status.toLowerCase() != 'completada' && order.status.toLowerCase() != 'entregado')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                            label: const Text(
                              'Marcar como Completada', 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                            onPressed: () {
                              _firebaseService.updateOrderStatus(order.id, 'Completada');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}