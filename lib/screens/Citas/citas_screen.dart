import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsandhealth/screens/Citas/EditarCitaScreen.dart';
import 'package:petsandhealth/screens/Citas/agregar_cita_screen.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtro = 'cliente'; // cliente, doctor o fecha

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Dark Overlay
          // Removed to match background with other sections
          // Container(
          //   decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
          // ),
          // Main Content
          Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cita',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AgregarCitaScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.tealAccent),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text("Crear"),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre o DNI...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.tealAccent,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButton<String>(
                              dropdownColor: Colors.black87,
                              style: const TextStyle(color: Colors.white),
                              iconEnabledColor: Colors.tealAccent,
                              value: _filtro,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                  value: 'cliente',
                                  child: Text('Cliente'),
                                ),
                                DropdownMenuItem(
                                  value: 'doctor',
                                  child: Text('Doctor'),
                                ),
                                DropdownMenuItem(
                                  value: 'fecha',
                                  child: Text('Fecha'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _filtro = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('citas')
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
                                'No hay citas registradas',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          final citasDocs = snapshot.data!.docs;

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: citasDocs.length,
                            itemBuilder: (context, index) {
                              final citaDoc = citasDocs[index];
                              final citaData =
                                  citaDoc.data() as Map<String, dynamic>;

                              return FutureBuilder<Map<String, String>>(
                                future: _obtenerDatosRelacionados(citaData),
                                builder: (context, relatedSnapshot) {
                                  if (!relatedSnapshot.hasData) {
                                    return const SizedBox();
                                  }

                                  final relacionados = relatedSnapshot.data!;
                                  final searchText = _searchController.text
                                      .toLowerCase()
                                      .trim();

                                  // FILTRO
                                  bool coincide = true;
                                  if (searchText.isNotEmpty) {
                                    switch (_filtro) {
                                      case 'cliente':
                                        coincide = relacionados['cliente']!
                                            .toLowerCase()
                                            .contains(searchText);
                                        break;
                                      case 'doctor':
                                        coincide = relacionados['doctor']!
                                            .toLowerCase()
                                            .contains(searchText);
                                        break;
                                      case 'fecha':
                                        coincide = (citaData['fecha'] ?? '')
                                            .toLowerCase()
                                            .contains(searchText);
                                        break;
                                    }
                                  }

                                  if (!coincide) return const SizedBox();

                                  return _buildCitaCard(
                                    context,
                                    citaDoc,
                                    citaData,
                                    relacionados,
                                    isWide,
                                  );
                                },
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
    );
  }

  Widget _buildCitaCard(
    BuildContext context,
    QueryDocumentSnapshot citaDoc,
    Map<String, dynamic> citaData,
    Map<String, String> relacionados,
    bool isWide,
  ) {
    return StatefulBuilder(
      builder: (context, setStateCard) {
        String estadoSeleccionado = citaData['estado'] ?? 'Pendiente';

        // Determinar color del estado
        Color estadoColor = Colors.orange;
        if (estadoSeleccionado == 'Confirmada') {
          estadoColor = Colors.green;
        } else if (estadoSeleccionado == 'Cancelada') {
          estadoColor = Colors.red;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.15), // Efecto glassmorphism
            border: Border.all(
              color: Colors.white.withOpacity(0.3), // Borde semi-transparente
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.teal[100],
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.teal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${citaData['fecha']} a las ${citaData['hora']}',
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
                                Icons.pets,
                                'Paciente: ${relacionados['paciente']}',
                              ),
                              _infoItem(
                                Icons.person,
                                'Cliente: ${relacionados['cliente']}',
                              ),
                              _infoItem(
                                Icons.medical_services,
                                'Doctor: ${relacionados['doctor']}',
                              ),
                              _infoItem(
                                Icons.description,
                                'Motivo: ${citaData['motivo']}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: estadoColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: estadoColor),
                                ),
                                child: Text(
                                  'Estado: $estadoSeleccionado',
                                  style: TextStyle(
                                    color: estadoColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.black87,
                                  style: const TextStyle(color: Colors.white),
                                  iconEnabledColor: Colors.tealAccent,
                                  value: estadoSeleccionado,
                                  underline: const SizedBox(),
                                  items:
                                      ['Pendiente', 'Confirmada', 'Cancelada']
                                          .map(
                                            (estado) => DropdownMenuItem(
                                              value: estado,
                                              child: Text(estado),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (nuevoEstado) async {
                                    if (nuevoEstado != null) {
                                      setStateCard(() {
                                        estadoSeleccionado = nuevoEstado;
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('citas')
                                          .doc(citaDoc.id)
                                          .update({'estado': nuevoEstado});

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Estado actualizado a "$nuevoEstado"',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
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
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmarEliminacion(context, citaDoc.id);
                          },
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal[100],
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.teal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${citaData['fecha']} - ${citaData['hora']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
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
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmarEliminacion(context, citaDoc.id);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoItem(
                      Icons.pets,
                      'Paciente: ${relacionados['paciente']}',
                    ),
                    _infoItem(
                      Icons.person,
                      'Cliente: ${relacionados['cliente']}',
                    ),
                    _infoItem(
                      Icons.medical_services,
                      'Doctor: ${relacionados['doctor']}',
                    ),
                    _infoItem(
                      Icons.description,
                      'Motivo: ${citaData['motivo']}',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: estadoColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: estadoColor),
                          ),
                          child: Text(
                            estadoSeleccionado,
                            style: TextStyle(
                              color: estadoColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: estadoSeleccionado,
                            underline: const SizedBox(),
                            items: ['Pendiente', 'Confirmada', 'Cancelada']
                                .map(
                                  (estado) => DropdownMenuItem(
                                    value: estado,
                                    child: Text(estado),
                                  ),
                                )
                                .toList(),
                            onChanged: (nuevoEstado) async {
                              if (nuevoEstado != null) {
                                setStateCard(() {
                                  estadoSeleccionado = nuevoEstado;
                                });

                                await FirebaseFirestore.instance
                                    .collection('citas')
                                    .doc(citaDoc.id)
                                    .update({'estado': nuevoEstado});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Estado actualizado a "$nuevoEstado"',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
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
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Eliminar cita',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta cita?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel, color: Colors.grey),
            label: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('citas')
                  .doc(citaId)
                  .delete();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
//✅