// models/login_response.dart
import 'package:petsandhealth/models/user_model.dart';

class LoginResponse {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  const LoginResponse({required this.success, this.errorMessage, this.user});

  factory LoginResponse.success(UserModel user) {
    return LoginResponse(success: true, user: user);
  }

  factory LoginResponse.error(String message) {
    return LoginResponse(success: false, errorMessage: message);
  }
}
