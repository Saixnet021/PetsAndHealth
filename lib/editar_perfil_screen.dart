import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    _telefonoController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nombreController.text = data['nombre'] ?? '';
        _apellidoController.text = data['apellido'] ?? '';
        _telefonoController.text = data['telefono'] ?? '';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'telefono': _telefonoController.text.trim(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Capa oscura
          Container(color: Colors.black.withOpacity(0.5)),
          Column(
            children: [
              // AppBar estilo iOS
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Editar Perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, color: Colors.white),
                    ],
                  ),
                ),
              ),
              // Contenido centrado
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Actualizar Información',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _nombreController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  'Nombre',
                                  Icons.person,
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Campo requerido'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _apellidoController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  'Apellido',
                                  Icons.person_outline,
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Campo requerido'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _telefonoController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  'Teléfono',
                                  Icons.phone,
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Campo requerido'
                                    : null,
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _saveChanges,
                                  icon: const Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Guardar Cambios',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.tealAccent),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.tealAccent.withOpacity(0.8)),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
