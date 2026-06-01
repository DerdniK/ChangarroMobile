# Changarro de Sus - Aplicación de E-commerce

> Una aplicación móvil moderna construida con Flutter que revoluciona la forma de comprar productos personalizados. Changarro de Sus es una plataforma completa de e-commerce con soporte para administradores, catálogo dinámico, carrito inteligente y sistema de órdenes en tiempo real.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter) ![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart) ![Firebase](https://img.shields.io/badge/Firebase-Latest-yellow?logo=firebase) ![License](https://img.shields.io/badge/License-MIT-green)

---

## Características Principales

**■ Autenticación Segura**
- Sistema de login/registro con Firebase Authentication
- Gestión de roles (Admin/Usuario)
- Persistencia de sesión automática

**■ Catálogo Dinámico**
- Productos obtenidos en tiempo real desde Firestore
- Categorización por tipo (Pins, Stickers, Posters, Botones, Postales)
- Gestión de inventario en vivo
- Interfaz responsiva con GridView

**■ Carrito Inteligente**
- Gestión de estado con Provider
- Validación automática de stock
- Cálculo dinámico de totales
- Persistencia de datos del carrito

**■ Sistema de Órdenes**
- Creación de órdenes transaccionales
- Panel de control para administradores
- Estados de seguimiento (Pendiente/Completada/Entregada)
- Historial de compras por usuario

**■ Panel de Administrador**
- Agregar productos con imágenes personalizadas
- Actualizar stock en tiempo real
- Cambiar estado de órdenes
- Vista total de todas las órdenes

**■ Gestión de Imágenes**
- Captura desde cámara o galería
- Almacenamiento local con path_provider
- Previsualización en tiempo real

**■ Notificaciones Push**
- Firebase Cloud Messaging integrado
- Notificaciones en primer plano
- Manejo de notificaciones en segundo plano

**■ Diseño Moderno**
- Tema oscuro profesional (#121212)
- Paleta de colores vibrante (Amarillo #FFB300 + Naranja #FF5722)
- Animaciones suaves y transiciones

---

## Arquitectura de la Aplicación

```
lib/
├── main.dart                 # Punto de entrada, configuración Firebase
├── database/
│   └── firebase_service.dart # Lógica de consultas a Firestore
├── models/
│   ├── product_model.dart   # Modelo de productos
│   └── order_model.dart     # Modelo de órdenes
├── pages/
│   ├── login_page.dart              # Autenticación
│   ├── catalog_page.dart            # Catálogo principal
│   ├── product_detail_screen.dart   # Detalle de producto
│   ├── cart_page.dart               # Carrito de compras
│   ├── orders_page.dart             # Historial de órdenes
│   └── company_profile_page.dart    # Perfil de la empresa
└── providers/
    └── cart_provider.dart           # Estado global del carrito
```

### Flujo de Datos

```
Firebase Firestore
        ↓
FirebaseService (Consultas)
        ↓
Providers (State Management)
        ↓
Widgets (UI)
        ↓
Usuario
```

---

## Guía de Instalación

### Requisitos Previos
- Flutter 3.0+ ([Descargar](https://docs.flutter.dev/get-started/install))
- Dart 3.0+
- Android Studio o Xcode (según tu plataforma)
- Cuenta de Firebase configurada

### Pasos de Instalación

1. **Clona el repositorio**
```bash
git clone https://github.com/tuusuario/changarro_movile.git
cd changarro_movile
```

2. **Instala dependencias**
```bash
flutter pub get
```

3. **Configura Firebase**
```bash
# Si aún no has iniciado, ejecuta:
flutterfire configure
```

4. **Ejecuta en desarrollo**
```bash
# Android
flutter run

# iOS
flutter run -d macos
```

5. **Compilar APK para producción**
```bash
flutter build apk --release
```

---

## Dependencias Principales

```yaml
# Autenticación y Base de Datos
firebase_core: ^2.24.0          # Inicialización de Firebase
firebase_auth: ^4.13.0          # Autenticación de usuarios
cloud_firestore: ^4.13.0        # Base de datos NoSQL en tiempo real

# Gestión de Estado
provider: ^6.0.0                # State management reactivo

# Servicios de Notificaciones
firebase_messaging: ^14.6.0     # Push notifications

# Gestión de Archivos e Imágenes
image_picker: ^1.0.0            # Seleccionar imágenes
path_provider: ^2.0.0           # Acceso al sistema de archivos
path: ^1.8.0                    # Manipulación de rutas

# UI y Navegación
flutter_launcher_icons: ^0.13.0 # Iconos de aplicación
font_awesome_flutter: ^10.0.0   # Iconos adicionales
intl: ^0.19.0                   # Internacionalización y fechas

# Comunicación
url_launcher: ^6.0.0            # Abrir URLs y apps externas
```

---

## Sistema de Autenticación

### Firebase Authentication Integration

La autenticación se maneja completamente con **Firebase Auth**, proporcionando:

```dart
// Registro de nuevos usuarios
UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  email: email,
  password: password
);

// Almacenar datos del usuario en Firestore
await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
  'name': username,
  'role': 'user', // Por defecto clientes, 'admin' para administradores
});
```

**Características de seguridad:**
- Contraseñas encriptadas automáticamente
- Validación de correos
- Recuperación de contraseña integrada
- Sesión persistente con `authStateChanges()`

---

## Estructura de Base de Datos (Firestore)

### Colección: `users`
```json
{
  "uid": {
    "name": "Juan Pérez",
    "role": "user|admin",
    "email": "juan@example.com",
    "createdAt": "Timestamp"
  }
}
```

### Colección: `products`
```json
{
  "productId": {
    "name": "Pin Personalizado",
    "category": "Pin",
    "price": 15.99,
    "stock": 100,
    "imageUrl": "file://path/to/image.jpg",
    "createdAt": "Timestamp"
  }
}
```

### Colección: `orders`
```json
{
  "orderId": {
    "userId": "firebase-uid",
    "customerName": "Cliente Nombre",
    "dateTime": "Timestamp",
    "total": 45.99,
    "status": "Pendiente|Completada|Entregado",
    "items": [
      {
        "id": "productId",
        "name": "Nombre Producto",
        "quantity": 2,
        "price": 15.99,
        "category": "Pin",
        "imageUrl": "file://path"
      }
    ]
  }
}
```

---

## Funcionalidades Avanzadas de Firebase

### 1. Streams en Tiempo Real
```dart
Stream<List<Product>> getProducts() {
  return _db.collection('products').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList());
}
```
**NOTA:** Este patrón utiliza `snapshots()` que retorna un Stream de cambios en tiempo real. Cada vez que un producto se actualiza en Firestore, todos los listeners reciben la actualización automáticamente sin necesidad de hacer polling.

### 2. **Transacciones con WriteBatch**
```dart
WriteBatch batch = _db.batch();

// Agregar múltiples operaciones
_items.forEach((productId, cartItem) {
  DocumentReference realRef = _db.collection('products').doc(productId);
  int newStock = cartItem.product.stock - cartItem.quantity;
  batch.update(realRef, {'stock': newStock < 0 ? 0 : newStock});
});

// Crear orden
DocumentReference orderRef = _db.collection('orders').doc();
batch.set(orderRef, {...});

// Ejecutar todas las operaciones atomicamente
await batch.commit();
```
**NOTA:** `WriteBatch` agrupa múltiples escrituras en una operación atómica. Esto garantiza que si algo falla, ninguna operación se ejecuta (ACID compliance). Perfecta para evitar inconsistencias: si se crea una orden pero no se reduce el stock, sería un desastre.

### 3. Queries Avanzadas con where() y orderBy()
```dart
Stream<List<OrderModel>> getOrders({String? userId}) {
  Query query = _db.collection('orders').orderBy('dateTime', descending: true);
  
  if (userId != null && userId.isNotEmpty) {
    query = query.where('userId', isEqualTo: userId);
  }
  
  return query.snapshots().map(...);
}
```
**NOTA:** Esto es un query dinámico que:
- Ordena por fecha descendente (más recientes primero)
- Si hay userId, filtra solo órdenes de ese usuario
- Los índices de Firestore se crean automáticamente para estos queries

---

## Gestión de Estado con Provider

### CartProvider - Explicación Detallada

```dart
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  
  bool addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Validar stock antes de incrementar
      if (_items[product.id]!.quantity >= product.stock) {
        return false; 
      }
      _items.update(product.id, 
        (existing) => CartItem(
          product: existing.product, 
          quantity: existing.quantity + 1
        )
      );
    } else {
      if (product.stock <= 0) return false;
      _items.putIfAbsent(product.id, 
        () => CartItem(product: product)
      );
    }
    notifyListeners(); // Notifica a todos los widgets que escuchan
    return true;
  }
}
```

**¿Por qué Provider?**
- ■ Inyección de dependencias automática
- ■ Reactividad sin boilerplate
- ■ Memoria eficiente (solo rebuild widgets suscritos)
- ■ Fácil testing

---

## Widgets Avanzados Utilizados

### 1. StreamBuilder - Actualizaciones en Tiempo Real
```dart
StreamBuilder<List<Product>>(
  stream: _firebaseService.getProducts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('No hay productos'));
    }
    // Construir UI con snapshot.data
    return GridView.builder(...);
  },
)
```
**VENTAJA:** No necesita setState. Automáticamente reconstruye cuando hay nuevos datos del Stream.

### 2. Consumer - Estado Local del Provider
```dart
Consumer<CartProvider>(
  builder: (context, cart, child) {
    return Text('Items: ${cart.itemCount}');
  },
)
```
**VENTAJA:** Solo reconstruye este widget cuando el CartProvider cambia, no toda la página.

### 3. Hero Animation - Transiciones Suaves
```dart
Hero(
  tag: product.id,
  child: Image.file(File(product.imageUrl), ...)
)
```
**EFECTO:** La imagen "vuela" suavemente del catálogo al detalle del producto.

### 4. ExpansionTile - Órdenes Colapsables
```dart
ExpansionTile(
  title: Text(order.customerName),
  children: [
    ...order.items.map((itemData) => ListTile(...)),
  ],
)
```
**UX:** Los usuarios pueden expandir órdenes para ver detalles sin cargar todo a la vez.

### 5. StatefulBuilder - Estado Modal
```dart
showModalBottomSheet(
  builder: (context) => StatefulBuilder(
    builder: (context, setModalState) => Form(...)
  )
)
```
**USO:** Permite setState dentro de un modal/dialog sin afectar el estado de la página principal.

---

## Gestión de Imágenes

### Flujo de Captura y Almacenamiento

```dart
// 1. Seleccionar imagen
final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);

// 2. Obtener directorio de documentos (almacenamiento local)
final Directory appDocDir = await getApplicationDocumentsDirectory();

// 3. Copiar a ubicación persistente
File copiedImage = await image.copy('${appDocDir.path}/${fileName}.jpg');

// 4. Guardar ruta en Firestore
await _firebaseService.addProduct(Product(
  imageUrl: copiedImage.path, // Ruta local
  ...
));
```

**¿Por qué local y no Firebase Storage?**
- ■ Más rápido (sin latencia de red)
- ■ Offline-first (funciona sin internet)
- ■ Menor costo
- □ Requiere respaldar datos manualmente

---

## Notificaciones Push con Firebase Messaging

### Configuración en main.dart

```dart
// Manejador para mensajes en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notificación en segundo plano: ${message.notification?.title}");
}

// En main()
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

### Solicitar Permisos y Obtener Token

```dart
FirebaseMessaging messaging = FirebaseMessaging.instance;

// Pedir permiso (iOS requiere esto explícitamente)
await messaging.requestPermission(alert: true, badge: true, sound: true);

// Obtener token único para este dispositivo
String? token = await messaging.getToken();
print("FCM Token: $token"); // Guardar en Firestore si necesitas enviar notis específicas
```

### Escuchar Notificaciones

```dart
// En primer plano (app abierta)
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message.notification!.title ?? ''),
      content: Text(message.notification!.body ?? ''),
    ),
  );
});

// Cuando el usuario toca la notificación
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navegar a la página específica según el contenido
});
```

---

## Roles de Usuario

### Sistema Dual Admin/Usuario

**Usuario Normal (role: 'user')**
- Ver catálogo
- Agregar productos al carrito
- Crear órdenes
- Ver historial de compras

**Administrador (role: 'admin')**
- Todas las funciones de usuario normal
- Agregar nuevos productos
- Editar stock
- Ver todas las órdenes (no solo las suyas)
- Cambiar estado de órdenes

```dart
Future<String> getUserRole(String uid) async {
  DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
  return doc.get('role') ?? 'user';
}
```

---

## Construcción y Deployment

### Construcción de APK (Android)
```bash
# APK de debug (para testing)
flutter build apk --debug

# APK de release (optimizado)
flutter build apk --release
```

### Construcción para Google Play Store
```bash
# App Bundle (recomendado para Play Store)
flutter build appbundle --release
```

### Compilación para iOS
```bash
flutter build ios --release
```

---

## Mejores Prácticas Implementadas

**■ Manejo de Errores Robusto**
```dart
try {
  await FirebaseService().updateOrderStatus(orderId, status);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e'))
  );
}
```

**■ Validación de Entrada**
```dart
if (stock <= 0) {
  return false; // No agregar producto sin stock
}
```

**■ Optimización de Rendimiento**
- Uso de const Widgets donde es posible
- Images cacheadas automáticamente
- Lazy loading en GridView

**■ Seguridad**
- Reglas Firestore que validan roles
- Contraseñas encriptadas en Firebase
- UIDs únicos para cada usuario

---

## Estructura de Rutas

```
/                          → Login/Catalog (según sesión)
/catalog                   → Catálogo principal
/product/:id               → Detalle de producto
/cart                      → Carrito de compras
/orders                    → Historial de órdenes
/orders/admin              → Panel de control (admin)
/company-profile           → Información de empresa
```

---

## Troubleshooting Común

### Firebase no inicializa
```bash
flutterfire configure --reconfigure
flutter pub get
```

### Errores de permisos en Android
Asegúrate de tener en `android/app/build.gradle`:
```gradle
minSdkVersion 21
```

### Imágenes no se cargan
Verifica que `path_provider` está en pubspec.yaml y que tienes permisos en AndroidManifest.xml

---

## Autor

Desarrollado con dedicación para Changarro de Sus

---

## Licencia

MIT License - Ver LICENSE.md para más detalles

---

## Contribuciones

Las contribuciones son bienvenidas. Por favor, crea un Fork y envía un Pull Request.

---

**Última actualización:** Junio 2026 | **Version:** 1.0.0
