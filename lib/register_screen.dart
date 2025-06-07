import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String _selectedRole = 'veterinario';
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al registrar: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            ...List.generate(8, (index) {
              return Positioned(
                top: (index * 120.0) % size.height,
                left: (index * 180.0) % size.width,
                child:
                    Container(
                          width: 60 + (index * 20.0),
                          height: 60 + (index * 20.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.tealAccent.withOpacity(0.1),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          duration: Duration(seconds: 4 + index),
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.5, 1.5),
                        )
                        .then()
                        .scale(
                          duration: Duration(seconds: 4 + index),
                          begin: const Offset(1.5, 1.5),
                          end: const Offset(0.5, 0.5),
                        ),
              );
            }),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 450 : double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Colors.tealAccent, Colors.teal],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.tealAccent.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.pets,
                              size: 60,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(
                            begin: const Offset(0.3, 0.3),
                            end: const Offset(1.0, 1.0),
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 24),
                      const Text(
                            'Registro\nPets & Health',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 8,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 800.ms)
                          .slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 50),
                      Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Crear cuenta',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                buildTextField(
                                  _nombreController,
                                  'Nombre',
                                  Icons.person,
                                  TextInputType.text,
                                ),
                                const SizedBox(height: 20),
                                buildTextField(
                                  _apellidoController,
                                  'Apellido',
                                  Icons.person_outline,
                                  TextInputType.text,
                                ),
                                const SizedBox(height: 20),
                                buildTextField(
                                  _telefonoController,
                                  'Número de teléfono',
                                  Icons.phone,
                                  TextInputType.phone,
                                ),
                                const SizedBox(height: 20),
                                buildTextField(
                                  _emailController,
                                  'Correo electrónico',
                                  Icons.email_outlined,
                                  TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                buildPasswordField(),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Rol',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedRole,
                                          dropdownColor: Colors.teal[800],
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.white,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                          isExpanded: true,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'veterinario',
                                              child: Text('Veterinario'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'administrador',
                                              child: Text('Administrador'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRole = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),
                                ElevatedButton(
                                  onPressed: _loading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.tealAccent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 48,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _loading
                                      ? const CircularProgressIndicator(
                                          color: Colors.black,
                                        )
                                      : const Text(
                                          'Registrarse',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 800.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    TextInputType keyboardType,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: Colors.tealAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Contraseña',
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.tealAccent),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
