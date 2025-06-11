import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsandhealth/screens/Doctores/agregar_doctor_screen.dart';
import 'package:petsandhealth/screens/Doctores/editar_doctor_screen.dart';

class DoctoresScreen extends StatefulWidget {
  const DoctoresScreen({super.key});

  @override
  State<DoctoresScreen> createState() => _DoctoresScreenState();
}

class _DoctoresScreenState extends State<DoctoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? especialidadSeleccionada;

  final List<String> especialidades = [
    'Veterinario General',
    'Cirujano Veterinario',
    'Dermatólogo Veterinario',
    'Cardiólogo Veterinario',
    'Oftalmólogo Veterinario',
    'Oncólogo Veterinario',
    'Especialista en Animales Exóticos',
    'Etólogo (Conductista Animal)',
    'Odontólogo Veterinario',
    'Zootecnista (Nutrición y Producción Animal)',
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo-huellas.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
          ),
          // Main Content
          Column(
            children: [
              // AppBar
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
                      'Doctores',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.medical_services, color: Colors.white),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          // Buscador por nombre
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar por nombre...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.teal,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          // Filtro por especialidad
                          DropdownButtonFormField<String>(
                            value: especialidadSeleccionada,
                            hint: const Text('Filtrar por especialidad'),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Todas las especialidades'),
                              ),
                              ...especialidades.map(
                                (esp) => DropdownMenuItem(
                                  value: esp,
                                  child: Text(esp),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                especialidadSeleccionada = value;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('doctores')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No hay doctores registrados',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          final doctoresDocs = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final nombre =
                                data['nombre']?.toString().toLowerCase() ?? '';
                            final especialidad =
                                data['especialidad']
                                    ?.toString()
                                    .toLowerCase() ??
                                '';
                            final filtroNombre = _searchController.text
                                .toLowerCase()
                                .trim();
                            final filtroEspecialidad = especialidadSeleccionada
                                ?.toLowerCase();

                            final coincideNombre = nombre.contains(
                              filtroNombre,
                            );
                            final coincideEspecialidad =
                                filtroEspecialidad == null ||
                                filtroEspecialidad == especialidad;

                            return coincideNombre && coincideEspecialidad;
                          }).toList();

                          if (doctoresDocs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No se encontraron resultados',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: doctoresDocs.length,
                            itemBuilder: (context, index) {
                              final doctorDoc = doctoresDocs[index];
                              final doctorData =
                                  doctorDoc.data() as Map<String, dynamic>;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white.withOpacity(
                                    0.15,
                                  ), // Efecto glassmorphism
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                      0.3,
                                    ), // Borde semi-transparente
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: isWide
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 35,
                                            backgroundColor: Colors.teal[100],
                                            child: Text(
                                              doctorData['nombre']?[0]
                                                      ?.toUpperCase() ??
                                                  'D',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                color: Colors.teal,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  doctorData['nombre'] ??
                                                      'Sin nombre',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Wrap(
                                                  spacing: 30,
                                                  runSpacing: 8,
                                                  children: [
                                                    _infoItem(
                                                      Icons.medical_services,
                                                      'Especialidad: ${doctorData['especialidad'] ?? ''}',
                                                    ),
                                                    _infoItem(
                                                      Icons.email,
                                                      'Correo: ${doctorData['correo'] ?? ''}',
                                                    ),
                                                    _infoItem(
                                                      Icons.phone,
                                                      'Tel: ${doctorData['telefono'] ?? ''}',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.orange,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditarDoctorScreen(
                                                            doctorId:
                                                                doctorDoc.id,
                                                            doctorData:
                                                                doctorData,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  _confirmarEliminacion(
                                                    context,
                                                    doctorDoc.id,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.teal[100],
                                                child: Text(
                                                  doctorData['nombre']?[0]
                                                          ?.toUpperCase() ??
                                                      'D',
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    color: Colors.teal,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  doctorData['nombre'] ??
                                                      'Sin nombre',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.orange,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditarDoctorScreen(
                                                            doctorId:
                                                                doctorDoc.id,
                                                            doctorData:
                                                                doctorData,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  _confirmarEliminacion(
                                                    context,
                                                    doctorDoc.id,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _infoItem(
                                            Icons.medical_services,
                                            'Especialidad: ${doctorData['especialidad'] ?? ''}',
                                          ),
                                          _infoItem(
                                            Icons.email,
                                            'Correo: ${doctorData['correo'] ?? ''}',
                                          ),
                                          _infoItem(
                                            Icons.phone,
                                            'Teléfono: ${doctorData['telefono'] ?? ''}',
                                          ),
                                        ],
                                      ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
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
              builder: (context) => const AgregarDoctorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Agregar Doctor"),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.tealAccent, size: 20),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 15, color: Colors.white)),
      ],
    );
  }

  void _confirmarEliminacion(BuildContext context, String doctorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Doctor'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este doctor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('doctores')
                  .doc(doctorId)
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
//✅