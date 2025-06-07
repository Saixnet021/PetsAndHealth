import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsandhealth/screens/Citas/EditarCitaScreen.dart';
import 'package:petsandhealth/screens/Citas/agregar_cita_screen.dart';

class CitasScreen extends StatelessWidget {
  const CitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Lista de Citas'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('citas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay citas registradas'));
          }

          final citasDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: citasDocs.length,
            itemBuilder: (context, index) {
              final citaDoc = citasDocs[index];
              final citaData = citaDoc.data() as Map<String, dynamic>;

              return FutureBuilder<Map<String, String>>(
                future: _obtenerDatosRelacionados(citaData),
                builder: (context, relatedSnapshot) {
                  if (!relatedSnapshot.hasData) {
                    return const ListTile(title: Text('Cargando datos...'));
                  }

                  final relacionados = relatedSnapshot.data!;

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
                            '${citaData['fecha']} a las ${citaData['hora']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Paciente: ${relacionados['paciente']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Cliente: ${relacionados['cliente']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Doctor: ${relacionados['doctor']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Motivo: ${citaData['motivo']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditarCitaScreen(
                                        citaId: citaDoc.id,
                                        citaData: citaData,
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
                                  _confirmarEliminacion(context, citaDoc.id);
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgregarCitaScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<Map<String, String>> _obtenerDatosRelacionados(
    Map<String, dynamic> data,
  ) async {
    final clienteSnap = await FirebaseFirestore.instance
        .collection('clientes')
        .doc(data['clienteId'])
        .get();
    final pacienteSnap = await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(data['pacienteId'])
        .get();
    final doctorSnap = await FirebaseFirestore.instance
        .collection('doctores')
        .doc(data['doctorId'])
        .get();

    return {
      'cliente': clienteSnap.data()?['nombre'] ?? 'Desconocido',
      'paciente': pacienteSnap.data()?['nombre'] ?? 'Desconocido',
      'doctor': doctorSnap.data()?['nombre'] ?? 'Desconocido',
    };
  }

  void _confirmarEliminacion(BuildContext context, String citaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cita'),
        content: const Text('¿Estás seguro de que deseas eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('citas')
                  .doc(citaId)
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
