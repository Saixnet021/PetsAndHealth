import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'agregar_paciente_screen.dart';
import 'editar_paciente_screen.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  String searchQuery = '';
  Map<String, String> clienteNombres = {};

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('clientes')
        .get();
    final Map<String, String> mapa = {};
    for (var doc in snapshot.docs) {
      mapa[doc.id] = doc['nombre'] ?? '';
    }
    setState(() {
      clienteNombres = mapa;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre de mascota o dueño...',
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
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

          final pacientesDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final nombreMascota =
                data['nombre']?.toString().toLowerCase() ?? '';
            final clienteId = data['clienteId'];
            final nombreCliente =
                clienteNombres[clienteId]?.toLowerCase() ?? '';
            return nombreMascota.contains(searchQuery) ||
                nombreCliente.contains(searchQuery);
          }).toList();

          if (pacientesDocs.isEmpty) {
            return const Center(child: Text('No se encontraron pacientes'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pacientesDocs.length,
            itemBuilder: (context, index) {
              final pacienteDoc = pacientesDocs[index];
              final pacienteData = pacienteDoc.data() as Map<String, dynamic>;
              final clienteNombre =
                  clienteNombres[pacienteData['clienteId']] ?? 'Desconocido';
              final fechaNacimiento =
                  pacienteData['fechaNacimiento'] is Timestamp
                  ? (pacienteData['fechaNacimiento'] as Timestamp).toDate()
                  : DateTime.now();
              final edad = calcularEdad(fechaNacimiento);

              // Dentro del itemBuilder, en el ListView.builder:
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
                      Row(
                        children: [
                          // Imagen del paciente
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                pacienteData['fotoUrl'] != null &&
                                    (pacienteData['fotoUrl'] as String)
                                        .isNotEmpty
                                ? Image.network(
                                    pacienteData['fotoUrl'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.pets,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // Nombre y especie
                          Expanded(
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
                                const SizedBox(height: 4),
                                Text(
                                  'Especie: ${pacienteData['especie']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Raza: ${pacienteData['raza']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Edad: $edad', style: const TextStyle(fontSize: 16)),
                      Text(
                        'Dueño: $clienteNombre',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
                            onPressed: () =>
                                _confirmarEliminacion(context, pacienteDoc.id),
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
