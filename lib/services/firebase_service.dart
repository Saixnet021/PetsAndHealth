import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';

Future<List<Usuario>> obtenerVeterinarios() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('usuarios')
      .where('rol', isEqualTo: 'veterinario')
      .get();

  return snapshot.docs
      .map((doc) => Usuario.fromMap(doc.data()))
      .toList();
}
