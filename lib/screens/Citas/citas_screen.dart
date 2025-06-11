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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Lista de Citas'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filtro,
                  items: const [
                    DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                    DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                    DropdownMenuItem(value: 'fecha', child: Text('Fecha')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _filtro = value;
                      });
                    }
                  },
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

  Widget _buildCitaCard(
    BuildContext context,
    QueryDocumentSnapshot citaDoc,
    Map<String, dynamic> citaData,
    Map<String, String> relacionados,
  ) {
    return StatefulBuilder(
      builder: (context, setStateCard) {
        String estadoSeleccionado = citaData['estado'] ?? 'Pendiente';

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Estado:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: estadoSeleccionado,
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
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('citas')
                            .doc(citaDoc.id)
                            .update({'estado': estadoSeleccionado});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Estado actualizado correctamente'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text('Actualizar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
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
