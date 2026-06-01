class Product {
  final String id;
  final String name;
  final String category; // 'Pin', 'Sticker', 'Poster'
  final double price;
  final int stock;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  // Convertir de Firebase a Objeto
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Convertir de Objeto a Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }
}