import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'views/login_screen.dart';
import 'home_screen.dart';
import 'core/theme/app_theme.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return userDoc['role'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pets & Health',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? '/home'
          : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) {
          return FutureBuilder<String?>(
            future: getUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                final role = snapshot.data;
                return HomeScreen(role: role ?? 'cliente');
              } else {
                return const Scaffold(
                  body: Center(child: Text('Error al obtener el rol')),
                );
              }
            },
          );
        },
      },
    );
  }
}
