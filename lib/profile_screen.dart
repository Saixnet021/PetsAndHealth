import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("No hay usuario autenticado");
    }
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras carga
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Si hubo error
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Si no hay datos del usuario
            return const Center(
              child: Text('No se encontró información del usuario.'),
            );
          }

          final userData = snapshot.data!.data()!;
          final nombre = userData['nombre'] ?? 'Nombre no disponible';
          final apellido = userData['apellido'] ?? '';
          final email = userData['email'] ?? 'Correo no disponible';
          final telefono = userData['telefono'] ?? 'Teléfono no disponible';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del Usuario',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 50),
                    const SizedBox(width: 10),
                    Text(
                      '$nombre $apellido',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Correo Electrónico: $email',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Teléfono: $telefono',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Aquí puedes navegar a la pantalla de edición
                      print("Editar Perfil");
                    },
                    child: const Text('Editar Perfil'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
