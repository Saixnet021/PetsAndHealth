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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Lista de Doctores'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Buscador por nombre
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
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
                      (esp) => DropdownMenuItem(value: esp, child: Text(esp)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      especialidadSeleccionada = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.white,
                    filled: true,
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay doctores registrados'),
                  );
                }

                final doctoresDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nombre = data['nombre']?.toString().toLowerCase() ?? '';
                  final especialidad =
                      data['especialidad']?.toString().toLowerCase() ?? '';
                  final filtroNombre = _searchController.text
                      .toLowerCase()
                      .trim();
                  final filtroEspecialidad = especialidadSeleccionada
                      ?.toLowerCase();

                  final coincideNombre = nombre.contains(filtroNombre);
                  final coincideEspecialidad =
                      filtroEspecialidad == null ||
                      filtroEspecialidad == especialidad;

                  return coincideNombre && coincideEspecialidad;
                }).toList();

                if (doctoresDocs.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron resultados'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: doctoresDocs.length,
                  itemBuilder: (context, index) {
                    final doctorDoc = doctoresDocs[index];
                    final doctorData = doctorDoc.data() as Map<String, dynamic>;

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
                              'Nombre: ${doctorData['nombre']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Especialidad: ${doctorData['especialidad']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Correo: ${doctorData['correo']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Teléfono: ${doctorData['telefono']}',
                              style: const TextStyle(fontSize: 16),
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
                                        builder: (context) =>
                                            EditarDoctorScreen(
                                              doctorId: doctorDoc.id,
                                              doctorData: doctorData,
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
                                    _confirmarEliminacion(
                                      context,
                                      doctorDoc.id,
                                    );
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarDoctorScreen(),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
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
