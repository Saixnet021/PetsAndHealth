// controllers/login_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class LoginController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  LoginController({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      // Autenticar usuario
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: request.email.trim(),
            password: request.password.trim(),
          );

      // Obtener datos del usuario desde Firestore
      final uid = userCredential.user!.uid;
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return LoginResponse.error(
          'Usuario no encontrado en la base de datos.',
        );
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final user = UserModel.fromFirestore(userData, uid);

      // Validar rol
      if (user.role != 'administrador' && user.role != 'veterinario') {
        return LoginResponse.error('Rol no definido.');
      }

      return LoginResponse.success(user);
    } on FirebaseAuthException catch (e) {
      return LoginResponse.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      return LoginResponse.error(
        'Ocurrió un error inesperado: ${e.toString()}',
      );
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'Correo inválido.';
      case 'user-disabled':
        return 'Usuario deshabilitado.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';
      default:
        return 'Error de autenticación: $code';
    }
  }

  // Opcional: método para logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Opcional: obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Opcional: stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
