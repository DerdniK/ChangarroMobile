import 'dart:io';
import 'package:changarro_movile/database/firebase_service.dart';
import 'package:changarro_movile/models/product_model.dart';
import 'package:changarro_movile/pages/cart_page.dart';
import 'package:changarro_movile/pages/company_profile_page.dart';
import 'package:changarro_movile/pages/orders_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '/pages/product_detail_screen.dart';
import '/providers/cart_provider.dart';

class CatalogPage extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogPage> {
  final FirebaseService _firebaseService = FirebaseService();

  bool isAdmin = false;
  String nombreUsuario = 'Cargando...'; // <--- NUEVA VARIABLE

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Jalamos el mapa completo de datos del usuario
      var userData = await _firebaseService.getUserData(currentUser.uid);
      if (userData != null) {
        setState(() {
          isAdmin = (userData['role'] == 'admin');
          nombreUsuario = userData['name'] ?? 'Cliente'; // <--- CAPTURAMOS EL NOMBRE
        });
      } else {
        setState(() {
          nombreUsuario = 'Cliente'; // Si no hay datos, ponemos un nombre genérico
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo Negro Mate
      appBar: AppBar(
        title: const Text('CHANGARRO DE SUS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black)),
        backgroundColor: const Color(0xFFFFB300), // Amarillo Vibrante
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 5,
        actions: [
          // Icono rápido del carrito con contador flotante
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, size: 28),
                  onPressed: () => _openCartDrawer(context),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFFF5722), shape: BoxShape.circle), // Naranja
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text('${cart?.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: .center),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
      
      // MENÚ LATERAL (Drawer)
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E1E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF5722)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(radius: 35, backgroundColor: Colors.black, child: Icon(Icons.store, color: Color(0xFFFFB300), size: 35)),
                  const SizedBox(height: 10),
                  // MUESTRA EL NOMBRE DEL CLIENTE AQUÍ ABAJO:
                  Text('¡Hola, $nombreUsuario!', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFFFFB300)),
              title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Cierra el menú lateral
                // Abre la nueva pantalla corporativa
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CompanyProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Color(0xFFFF5722)),
              title: const Text('Ver Carrito', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _openCartDrawer(context);
              },
            ), 
           ListTile(
              leading: const Icon(Icons.receipt_long, color: Color(0xFFFFB300)),
              title: const Text('Mis Pedidos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  // FALSO: Vista de cliente normal (solo ve lo suyo)
                  MaterialPageRoute(builder: (context) => OrdersPage(isAdminView: false)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
              onTap: () async {
                // 1. Cerramos la sesión en Firebase
                await FirebaseAuth.instance.signOut();
                
                // 2. Cerramos el menú lateral
                if (context.mounted) Navigator.pop(context);
                
                // ¡Listo! El StreamBuilder del main.dart detectará el cierre
                // y te regresará en automático a la pantalla de Login.
              },
            ),

            // 2. BOTÓN EXCLUSIVO PARA ADMINS (Solo tú lo verás)
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.green),
                title: const Text('Pedidos Recibidos (Admin)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    // VERDADERO: Vista de administrador (ve todo y puede completar)
                    MaterialPageRoute(builder: (context) => OrdersPage(isAdminView: true)),
                  );
                },
              ),
          ],
        ),
      ),

      body: StreamBuilder<List<Product>>(
        stream: _firebaseService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay mercancía en el inventario.', style: TextStyle(color: Colors.white70)));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Hero(
                            tag: product.id,
                            child: product.imageUrl.isNotEmpty
                                ? Image.file(File(product.imageUrl), width: double.infinity, fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(color: const Color(0xFF2D2D2D), child: const Icon(Icons.broken_image, color: Color(0xFFFF5722), size: 40)))
                                : Container(color: const Color(0xFF2D2D2D), child: const Icon(Icons.image, color: Colors.grey, size: 40)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(product.category, style: const TextStyle(color: Color(0xFFFF5722), fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(color: product.stock > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text('Stk: ${product.stock}', style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFFFFB300),
            foregroundColor: Colors.black,
            child: const Icon(Icons.add_box_rounded, size: 28),
            onPressed: () => _showAddProductDialog(context),
          )
        : null,
    );
  }

  // FORMULARIO MODAL AVANZADO CON SELECCIÓN DE IMAGEN LOCAL Y CATEGORÍAS
  void _showAddProductDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    double price = 0.0;
    int stock = 0;
    String selectedCategory = 'Sticker'; // Por defecto
    String localImagePath = '';

    final List<String> categories = ['Sticker', 'Poster', 'Botón', 'Pin', 'Postal'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Registrar Mercancía', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFB300))),
                  const SizedBox(height: 15),
                  
                  // Selector de Imagen Local
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (pickedFile != null) {
                          // Copiar la imagen a la carpeta interna de la app para asegurar la persistencia permanente
                          final appDir = await getApplicationDocumentsDirectory();
                          final fileName = p.basename(pickedFile.path);
                          final File savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
                          
                          setModalState(() {
                            localImagePath = savedImage.path;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.5), style: BorderStyle.solid),
                        ),
                        child: localImagePath.isEmpty
                            ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: Colors.white54, size: 40), SizedBox(height: 8), Text('Añadir Foto del Teléfono', style: TextStyle(color: Colors.white54))])
                            : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(localImagePath), fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFB300)))),
                    validator: (v) => v!.isEmpty ? 'Ingresa un nombre' : null,
                    onSaved: (v) => name = v!,
                  ),
                  
                  // DROPDOWN MENÚ PARA CATEGORÍAS
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Categoría', labelStyle: TextStyle(color: Colors.white70)),
                    items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (v) => setModalState(() => selectedCategory = v!),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Precio (\$)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => (double.tryParse(v!) ?? 0) <= 0 ? 'Precio inválido' : null,
                          onSaved: (v) => price = double.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Stock Inicial'),
                          keyboardType: TextInputType.number,
                          validator: (v) => (int.tryParse(v!) ?? -1) < 0 ? 'Cantidad inválida' : null,
                          onSaved: (v) => stock = int.parse(v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Guardar en la Nube', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _firebaseService.addProduct(Product(
                            id: '', name: name, category: selectedCategory, price: price, stock: stock, imageUrl: localImagePath,
                          ));
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Vista rápida inferior del carrito
  void _openCartDrawer(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartPage()));
}
}