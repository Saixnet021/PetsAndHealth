import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // Usando EmailJS para envío de emails desde Flutter Web
  static const String _serviceId = 'service_pets_health';
  static const String _templateId = 'template_new_user';
  static const String _publicKey =
      'YOUR_EMAILJS_PUBLIC_KEY'; // Necesitarás configurar esto

  static Future<bool> sendNewUserNotification({
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': 'fernandezanderson562@gmail.com',
            'user_name': userName,
            'user_email': userEmail,
            'user_role': userRole,
            'created_date': DateTime.now().toString(),
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error enviando email: $e');
      return false;
    }
  }

  // Método alternativo usando un servicio backend propio
  static Future<bool> sendEmailViaBackend({
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    try {
      // Este sería tu endpoint backend que maneja el envío de emails
      final response = await http.post(
        Uri.parse('https://your-backend-api.com/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': 'fernandezanderson562@gmail.com',
          'subject': 'Nuevo Usuario Registrado - Pets & Health',
          'body':
              '''
Hola,

Se ha registrado un nuevo usuario en el sistema Pets & Health:

Nombre: $userName
Email: $userEmail
Rol: $userRole
Fecha de registro: ${DateTime.now().toString()}

Saludos,
Sistema Pets & Health
          ''',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error enviando email via backend: $e');
      return false;
    }
  }

  // Método usando Firebase Functions (recomendado)
  static Future<bool> sendEmailViaFirebaseFunctions({
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    try {
      // Llamar a una Cloud Function de Firebase
      final response = await http.post(
        Uri.parse(
          'https://us-central1-veterinaria-app-31769.cloudfunctions.net/sendNewUserNotification',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userName': userName,
          'userEmail': userEmail,
          'userRole': userRole,
          'adminEmail': 'fernandezanderson562@gmail.com',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error enviando email via Firebase Functions: $e');
      return false;
    }
  }
}
