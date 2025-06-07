import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final email = user['email'] ?? 'Sin correo';
              final role = user['role'] ?? 'Sin rol';

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(email),
                subtitle: Text('Rol: $role'),
                trailing: Icon(
                  role == 'administrador'
                      ? Icons.shield
                      : Icons.medical_services,
                  color: role == 'administrador' ? Colors.red : Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
