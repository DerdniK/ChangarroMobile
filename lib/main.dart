import 'package:changarro_movile/pages/catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:changarro_movile/providers/cart_provider.dart'; 

// Manejador en SEGUNDO PLANO (Este sí debe quedarse afuera del main)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notificación recibida en segundo plano: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Solo inicializamos Firebase rápido, sin esperar tokens ni permisos
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Error inicializando Firebase: $e");
  }

  // ¡Lanzamos la app DE INMEDIATO para evitar la pantalla negra!
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Ejecutamos las notificaciones en el fondo mientras el usuario ya ve la app
    _configurarNotificaciones();
  }

  Future<void> _configurarNotificaciones() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // 1. Pedimos permisos
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // 2. Obtenemos el token
    String? token = await messaging.getToken();
    debugPrint("🔥 FCM Token de tu cel: $token");

    // 3. Escuchamos mensajes en PRIMER PLANO
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('¡Notificación recibida con la app abierta!');
      
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message.notification!.title ?? 'Alerta'),
            content: Text(message.notification!.body ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // AQUÍ ESTÁ LA MAGIA: Envolvemos la app en el MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CatalogPage(), 
      ),
    );
  }
}