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
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;

    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo-huellas.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pacientes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.pets, color: Colors.white),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre de mascota o dueño...',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pacientes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay pacientes registrados',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
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
                      return const Center(
                        child: Text(
                          'No se encontraron pacientes',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: pacientesDocs.length,
                      itemBuilder: (context, index) {
                        final pacienteDoc = pacientesDocs[index];
                        final pacienteData =
                            pacienteDoc.data() as Map<String, dynamic>;
                        final clienteNombre =
                            clienteNombres[pacienteData['clienteId']] ??
                            'Desconocido';
                        final fechaNacimiento =
                            pacienteData['fechaNacimiento'] is Timestamp
                            ? (pacienteData['fechaNacimiento'] as Timestamp)
                                  .toDate()
                            : DateTime.now();
                        final edad = calcularEdad(fechaNacimiento);

                        return _buildPacienteCard(
                          pacienteDoc,
                          pacienteData,
                          clienteNombre,
                          edad,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarPacienteScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Agregar Paciente"),
      ),
    );
  }

  Widget _buildPacienteCard(
    QueryDocumentSnapshot pacienteDoc,
    Map<String, dynamic> pacienteData,
    String clienteNombre,
    String edad,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Clave para evitar expansión vertical
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child:
                pacienteData['fotoUrl'] != null &&
                    (pacienteData['fotoUrl'] as String).isNotEmpty
                ? Image.network(
                    pacienteData['fotoUrl'],
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.teal[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.pets, size: 70, color: Colors.teal),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            pacienteData['nombre'] ?? 'Sin nombre',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          _infoItem(
            Icons.category,
            'Especie: ${pacienteData['especie'] ?? ''}',
          ),
          _infoItem(Icons.pets, 'Raza: ${pacienteData['raza'] ?? ''}'),
          _infoItem(Icons.cake, 'Edad: $edad'),
          _infoItem(Icons.person, 'Dueño: $clienteNombre'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
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
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _confirmarEliminacion(context, pacienteDoc.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.tealAccent, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
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
