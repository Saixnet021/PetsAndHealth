import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDOukCzQfFayauGLBRa_ehHcjQ9w1GpGhU",
      authDomain: "veterinaria-app-31769.firebaseapp.com",
      projectId: "veterinaria-app-31769",
      storageBucket: "veterinaria-app-31769.firebasestorage.app",
      messagingSenderId: "1071520821858",
      appId: "1:1071520821858:web:97e6200a068be48de8973b",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> getUserRole() async {
    // Verifica si el usuario está autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      // Obtiene el rol del usuario desde Firestore
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userDoc['role']; // Retorna el rol (ejemplo: 'administrador', 'veterinario')
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veterinaria Pets & Health',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute:
          FirebaseAuth.instance.currentUser != null
              ? '/home'
              : '/login', // Verifica si el usuario ya está autenticado
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) {
          return FutureBuilder<String?>(
            future: getUserRole(), // Obtiene el rol del usuario
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                final role = snapshot.data;
                return HomeScreen(
                  role: role ?? 'cliente',
                ); // Pasa el rol al HomeScreen
              } else {
                return const Center(child: Text('Error al obtener el rol'));
              }
            },
          );
        },
      },
    );
  }
}
