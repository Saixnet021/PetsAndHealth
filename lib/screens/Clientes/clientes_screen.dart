import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsandhealth/screens/Clientes/agregar_cliente_screen.dart';
import 'package:petsandhealth/screens/Clientes/editar_clientes_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                      'Clientes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.people_alt, color: Colors.white),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o DNI...',
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
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('clientes')
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
                                'No hay clientes registrados',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          final clientesDocs = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final nombre = data['nombre']?.toLowerCase() ?? '';
                            final dni = data['dni']?.toLowerCase() ?? '';
                            return nombre.contains(_searchText) ||
                                dni.contains(_searchText);
                          }).toList();

                          if (clientesDocs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No se encontraron resultados',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: clientesDocs.length,
                            itemBuilder: (context, index) {
                              final clienteDoc = clientesDocs[index];
                              final clienteData =
                                  clienteDoc.data() as Map<String, dynamic>;

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
                                              clienteData['nombre']?[0]
                                                      ?.toUpperCase() ??
                                                  '',
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
                                                  clienteData['nombre'] ??
                                                      'Sin nombre',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors
                                                        .white, // Texto blanco para contraste
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Wrap(
                                                  spacing: 30,
                                                  runSpacing: 8,
                                                  children: [
                                                    _infoItem(
                                                      Icons.badge,
                                                      'DNI: ${clienteData['dni'] ?? ''}',
                                                    ),
                                                    _infoItem(
                                                      Icons.email,
                                                      'Correo: ${clienteData['correo'] ?? ''}',
                                                    ),
                                                    _infoItem(
                                                      Icons.phone,
                                                      'Tel: ${clienteData['telefono'] ?? ''}',
                                                    ),
                                                    _infoItem(
                                                      Icons.location_on,
                                                      'Dir: ${clienteData['direccion'] ?? ''}',
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
                                                          EditarClienteScreen(
                                                            clienteId:
                                                                clienteDoc.id,
                                                            clienteData:
                                                                clienteData,
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
                                                    clienteDoc.id,
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
                                                  clienteData['nombre']?[0]
                                                          ?.toUpperCase() ??
                                                      '',
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
                                                  clienteData['nombre'] ??
                                                      'Sin nombre',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors
                                                        .white, // Texto blanco para contraste
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
                                                          EditarClienteScreen(
                                                            clienteId:
                                                                clienteDoc.id,
                                                            clienteData:
                                                                clienteData,
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
                                                    clienteDoc.id,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _infoItem(
                                            Icons.badge,
                                            'DNI: ${clienteData['dni'] ?? ''}',
                                          ),
                                          _infoItem(
                                            Icons.email,
                                            'Correo: ${clienteData['correo'] ?? ''}',
                                          ),
                                          _infoItem(
                                            Icons.phone,
                                            'Teléfono: ${clienteData['telefono'] ?? ''}',
                                          ),
                                          _infoItem(
                                            Icons.location_on,
                                            'Dirección: ${clienteData['direccion'] ?? ''}',
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
              builder: (context) => const AgregarClienteScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Agregar Cliente"),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.tealAccent,
          size: 20,
        ), // Cambié el color para mejor contraste
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
          ), // Texto blanco
        ),
      ],
    );
  }

  void _confirmarEliminacion(BuildContext context, String clienteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este cliente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('clientes')
                  .doc(clienteId)
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