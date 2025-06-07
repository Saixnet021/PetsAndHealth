import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petsandhealth/home_screen.dart';
import 'package:petsandhealth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final role = userDoc['role'];

      if (role == 'administrador' || role == 'veterinario') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(role: role)),
        );
      } else {
        throw Exception('Rol no definido.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
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

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 450 : double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo section
                      Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
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

                      // Title
                      const Text(
                            'Veterinaria\nPets & Health',
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

                      // Login form container with glassmorphism effect
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
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Email field
                                Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white.withOpacity(0.15),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _emailController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Correo electrónico',
                                          labelStyle: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            color: Colors.tealAccent,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(
                                            20,
                                          ),
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 600.ms, duration: 600.ms)
                                    .slideX(begin: -0.3, end: 0),

                                const SizedBox(height: 20),

                                // Password field
                                Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white.withOpacity(0.15),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Contraseña',
                                          labelStyle: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            color: Colors.tealAccent,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(
                                            20,
                                          ),
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 700.ms, duration: 600.ms)
                                    .slideX(begin: 0.3, end: 0),

                                const SizedBox(height: 32),

                                // Login button
                                Container(
                                      width: double.infinity,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.tealAccent,
                                            Colors.teal,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.tealAccent
                                                .withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.login,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Iniciar Sesión',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 800.ms, duration: 600.ms)
                                    .slideY(begin: 0.3, end: 0),

                                const SizedBox(height: 24),

                                // Register link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "¿No tienes cuenta? ",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Regístrate",
                                        style: TextStyle(
                                          color: Colors.tealAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.tealAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(
                                  delay: 900.ms,
                                  duration: 600.ms,
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 800.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
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
}
