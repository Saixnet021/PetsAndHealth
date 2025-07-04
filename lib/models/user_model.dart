// models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String role;

  const UserModel({required this.uid, required this.email, required this.role});

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
