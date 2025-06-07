import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petsandhealth/screens/Pacientes/agregar_paciente_screen.dart';
import 'package:petsandhealth/screens/Pacientes/editar_paciente_screen.dart'; // Asegúrate de tener este archivo creado

class PacientesScreen extends StatelessWidget {
  const PacientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pacientes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay pacientes registrados'));
          }

          final pacientesDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pacientesDocs.length,
            itemBuilder: (context, index) {
              final pacienteDoc = pacientesDocs[index];
              final pacienteData = pacienteDoc.data() as Map<String, dynamic>;

              final fechaNacimiento =
                  pacienteData['fechaNacimiento'] is Timestamp
                  ? (pacienteData['fechaNacimiento'] as Timestamp).toDate()
                  : DateTime.now();
              final edad = calcularEdad(fechaNacimiento);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pacienteData['nombre'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Especie: ${pacienteData['especie']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Raza: ${pacienteData['raza']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text('Edad: $edad', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarPacienteScreen(
                                    pacienteId: pacienteDoc.id,
                                    pacienteData: pacienteData,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _confirmarEliminacion(context, pacienteDoc.id);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarPacienteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String calcularEdad(DateTime fechaNacimiento) {
    final ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento.year;
    int mes = ahora.month - fechaNacimiento.month;
    int dia = ahora.day - fechaNacimiento.day;

    if (mes < 0 || (mes == 0 && dia < 0)) {
      edad--;
      mes += 12;
    }

    if (dia < 0) {
      final ultimoDiaDelMes = DateTime(ahora.year, ahora.month, 0).day;
      dia += ultimoDiaDelMes;
      mes--;
    }

    return '$edad años, $mes meses, $dia días';
  }

  void _confirmarEliminacion(BuildContext context, String pacienteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar paciente'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este paciente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('pacientes')
                  .doc(pacienteId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
