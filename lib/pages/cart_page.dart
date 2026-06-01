import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('MI CARRITO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color(0xFFFFB300),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 80, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('Tu carrito está vacío.', style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
            )
          : Column(
              children: [
                // Lista detallada de productos que se va a llevar
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items.values.toList()[i];
                      final productId = cart.items.keys.toList()[i];

                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.product.imageUrl.isNotEmpty
                                ? Image.file(File(item.product.imageUrl), width: 50, height: 50, fit: BoxFit.cover)
                                : Container(width: 50, height: 50, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.white24)),
                          ),
                          title: Text(item.product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '\$${item.product.price.toStringAsFixed(2)} x ${item.quantity} = \$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Botón Restar
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                                onPressed: () => cart.removeSingleItem(productId),
                              ),
                              Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              // Botón Sumar (Valida stock)
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFB300)),
                                onPressed: () {
                                  bool success = cart.addItem(item.product);
                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('¡Límite alcanzado! No hay más stock disponible en Firebase.'), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // PANEL INFERIOR DE SUMA TOTAL Y ACCIÓN
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL A COBRAR:', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('\$${cart.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFFFB300), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5722), // Naranja
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            // Mostrar un círculo de carga mientras actualiza Firebase
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300))),
                            );

                            try {
                              await cart.placeOrder(); // Sube la orden y descuenta el stock
                              Navigator.pop(context); // Quita el círculo de carga
                              
                              // Feedback de éxito con Modal
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text('¡Orden Registrada!', style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold)),
                                  content: const Text('El stock ha sido actualizado en Firebase y la orden se guardó con éxito.', style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK', style: TextStyle(color: Color(0xFFFF5722))),
                                      onPressed: () {
                                        Navigator.pop(ctx); // Cierra el diálogo
                                        Navigator.pop(context); // Regresa al catálogo limpio
                                      },
                                    )
                                  ],
                                ),
                              );
                            } catch (e) {
                              Navigator.pop(context); // Cierra el indicador de carga
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al procesar: $e'), backgroundColor: Colors.red));
                            }
                          },
                          child: const Text('CONFIRMAR ORDEN / PAGAR', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}