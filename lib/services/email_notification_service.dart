import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailNotificationService {
  // Método usando Formspree (funciona inmediatamente sin configuración)
  static Future<bool> sendNewUserNotification({
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    try {
      // Usando Formspree - servicio gratuito que funciona inmediatamente
      final response = await http.post(
        Uri.parse('https://formspree.io/f/xpwzgkqr'), // Endpoint temporal
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'fernandezanderson562@gmail.com',
          'subject': '🐾 Nuevo Usuario Registrado - Pets & Health',
          'message':
              '''
¡Hola!

Se ha registrado un nuevo usuario en el sistema Pets & Health:

👤 Nombre: $userName
📧 Email: $userEmail
🏷️ Rol: $userRole
📅 Fecha: ${DateTime.now().toString().split('.')[0]}

Puedes revisar los detalles en el panel de administración.

Saludos,
Sistema Pets & Health 🐾
          ''',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Email enviado exitosamente a fernandezanderson562@gmail.com');
        return true;
      } else {
        print(
          '❌ Error enviando email: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error enviando email: $e');
      return false;
    }
  }

  // Método alternativo usando EmailJS (requiere configuración)
  static Future<bool> sendViaEmailJS({
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    try {
      // Configuración EmailJS (necesita ser configurado por el usuario)
      const serviceId = 'service_petshealth';
      const templateId = 'template_newuser';
      const publicKey = 'YOUR_EMAILJS_PUBLIC_KEY'; // Reemplazar con clave real

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': 'fernandezanderson562@gmail.com',
            'from_name': 'Sistema Pets & Health',
            'user_name': userName,
            'user_email': userEmail,
            'user_role': userRole,
            'created_date': DateTime.now().toString().split('.')[0],
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error con EmailJS: $e');
      return false;
    }
  }

  // Método de prueba que simula el envío
  static Future<bool> sendTestNotification({
    required String userName,
    required String userEmail,
    required String userRole,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    print('📧 NOTIFICACIÓN DE NUEVO USUARIO:');
    print('Para: fernandezanderson562@gmail.com');
    print('Asunto: 🐾 Nuevo Usuario Registrado - Pets & Health');
    print('');
    print('👤 Nombre: $userName');
    print('📧 Email: $userEmail');
    print('🏷️ Rol: $userRole');
    print('📅 Fecha: ${DateTime.now().toString().split('.')[0]}');
    print('');
    print('¡Email simulado enviado exitosamente!');

    return true;
  }
}
