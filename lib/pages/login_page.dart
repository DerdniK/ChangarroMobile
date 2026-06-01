import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController(); // Para validar confirmación
  
  String email = '';
  String password = '';
  String username = ''; // <--- NUEVO
  bool isLoading = false;
  bool isRegistering = false; 

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      if (isRegistering) {
        // 1. Crear usuario en Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        
        // 2. Guardar el Nombre de Usuario y Rol en Firestore usando su UID
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': username,
          'role': 'user', // Por defecto entran como clientes
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cuenta creada con éxito!'), backgroundColor: Colors.green),
        );
      } else {
        // Iniciar Sesión normal
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      }
    } on FirebaseAuthException catch (e) {
      String mensajeError = 'Ocurrió un error inesperado.';
      if (e.code == 'user-not-found') mensajeError = 'No existe ningún usuario con este correo.';
      if (e.code == 'wrong-password') mensajeError = 'Contraseña incorrecta.';
      if (e.code == 'email-already-in-use') mensajeError = 'Este correo ya está registrado.';
      if (e.code == 'weak-password') mensajeError = 'La contraseña es muy débil.';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeError), backgroundColor: const Color(0xFFFF5722)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.store, color: Color(0xFFFFB300), size: 50),
                ),
                const SizedBox(height: 24),
                Text(
                  isRegistering ? 'CREAR CUENTA' : 'INICIAR SESIÓN',
                  style: const TextStyle(color: Color(0xFFFFB300), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Campo Nombre de Usuario (SOLO EN REGISTRO)
                if (isRegistering) ...[
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nombre de Usuario',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFB300))),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Ingresa tu nombre o apodo' : null,
                    onSaved: (v) => username = v!.trim(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Campo Correo
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFB300))),
                  ),
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Ingresa un correo válido' : null,
                  onSaved: (v) => email = v!.trim(),
                ),
                const SizedBox(height: 20),

                // Campo Contraseña
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFB300))),
                  ),
                  validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  onSaved: (v) => password = v!.trim(),
                ),
                const SizedBox(height: 20),

                // Campo Confirmar Contraseña (SOLO EN REGISTRO)
                if (isRegistering) ...[
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFB300))),
                    ),
                    validator: (v) => v != _passwordController.text ? 'Las contraseñas no coinciden' : null,
                  ),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 20),

                // Botón Principal
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : _submitForm,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isRegistering ? 'Registrarse' : 'Entrar al Changarro',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    setState(() {
                      isRegistering = !isRegistering;
                    });
                  },
                  child: Text(
                    isRegistering ? '¿Ya tienes cuenta? Inicia Sesión' : '¿Eres nuevo cliente? Regístrate aquí',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}