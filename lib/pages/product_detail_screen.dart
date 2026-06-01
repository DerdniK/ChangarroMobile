import 'dart:io';
import 'package:changarro_movile/pages/cart_page.dart';
import 'package:changarro_movile/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '/providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(product.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFB300),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: product.id,
              child: product.imageUrl.isNotEmpty
                  ? Image.file(File(product.imageUrl), width: double.infinity, height: 380, fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(width: double.infinity, height: 380, color: const Color(0xFF2D2D2D), child: const Icon(Icons.broken_image, size: 80, color: Color(0xFFFF5722))))
                  : Container(width: double.infinity, height: 380, color: const Color(0xFF2D2D2D), child: const Icon(Icons.image, size: 80, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFF5722).withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
                    child: Text(product.category.toUpperCase(), style: const TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 16),
                  Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFFFB300))),
                  const SizedBox(height: 16),
                  Text('Disponibles para venta: ${product.stock} pzas', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 40),

                  // BOTONES DE ACCIÓN DINÁMICOS (Lógica del Carrito)
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      final isInCart = cart.items.containsKey(product.id);

                      if (!isInCart) {
                        // Estado Inicial: El producto no ha sido añadido
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
                            label: const Text('Agregar al Carrito', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                            onPressed: () => _addToCart(context, cart),
                          ),
                        );
                      } else {
                        // Estado Activo: Ya se añadió, dividimos el layout en dos botones coordinados
                        final currentQty = cart.items[product.id]!.quantity;
                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 55,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFFB300), width: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () => _addToCart(context, cart),
                                  child: Text('Añadir otro ($currentQty)', style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 55,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  icon: const Icon(Icons.shopping_bag, color: Colors.white),
                                  label: const Text('Ver Carrito', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartPage()));
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, CartProvider cart) {
    if (product.stock > 0) {
      cart.addItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡${product.name} agregado al carrito!'),
          backgroundColor: const Color(0xFFFF5722),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}