class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory Usuario.fromMap(Map<String, dynamic> data) {
    return Usuario(
      uid: data['uid'] ?? '',
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? '',
    );
  }
}
