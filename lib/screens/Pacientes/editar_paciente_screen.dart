import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditarPacienteScreen extends StatefulWidget {
  final String pacienteId;
  final Map<String, dynamic> pacienteData;

  const EditarPacienteScreen({
    super.key,
    required this.pacienteId,
    required this.pacienteData,
  });

  @override
  State<EditarPacienteScreen> createState() => _EditarPacienteScreenState();
}

class _EditarPacienteScreenState extends State<EditarPacienteScreen> {
  String nombre = '';
  String especie = '';
  String raza = '';
  DateTime? fechaNacimiento;
  String? clienteId;

  List<DocumentSnapshot> clientes = [];

  Uint8List? imagenSeleccionada;
  XFile? pickedXFile;
  String? fotoUrlExistente;

  @override
  void initState() {
    super.initState();
    cargarDatosIniciales();
    cargarClientes();
  }

  void cargarDatosIniciales() {
    nombre = widget.pacienteData['nombre'] ?? '';
    especie = widget.pacienteData['especie'] ?? '';
    raza = widget.pacienteData['raza'] ?? '';
    clienteId = widget.pacienteData['clienteId'];
    fotoUrlExistente = widget.pacienteData['fotoUrl'];
    final timestamp = widget.pacienteData['fechaNacimiento'];
    if (timestamp is Timestamp) {
      fechaNacimiento = timestamp.toDate();
    }
  }

  Future<void> cargarClientes() async {
    final clientesSnap = await FirebaseFirestore.instance
        .collection('clientes')
        .get();
    setState(() {
      clientes = clientesSnap.docs;
    });
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imagenSeleccionada = bytes;
        pickedXFile = picked;
      });
    }
  }

  Future<String?> subirImagenAPostImages(Uint8List imagenBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.imgbb.com/1/upload?key=3639ea52757bc8f6b3e480be199d5cdf',
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imagenBytes,
        filename: 'imagen.jpg',
      ),
    );
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      return data['data']['url'];
    } else {
      print('Error al subir imagen: $responseBody');
      return null;
    }
  }

  Future<void> actualizarPaciente() async {
    if (nombre.isEmpty ||
        especie.isEmpty ||
        raza.isEmpty ||
        fechaNacimiento == null ||
        clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    String? nuevaUrl = fotoUrlExistente;
    if (imagenSeleccionada != null) {
      nuevaUrl = await subirImagenAPostImages(imagenSeleccionada!);
    }

    await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(widget.pacienteId)
        .update({
          'nombre': nombre,
          'especie': especie,
          'raza': raza,
          'fechaNacimiento': Timestamp.fromDate(fechaNacimiento!),
          'clienteId': clienteId,
          'fotoUrl': nuevaUrl ?? '',
        });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 600 ? 500.0 : double.infinity;

    return Scaffold(
      body: Stack(
        children: [
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
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Editar Paciente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: formWidth,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: seleccionarImagen,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imagenSeleccionada != null
                                  ? Image.memory(
                                      imagenSeleccionada!,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : (fotoUrlExistente != null &&
                                        fotoUrlExistente!.isNotEmpty)
                                  ? Image.network(
                                      fotoUrlExistente!,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Toca para seleccionar imagen',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: clienteId,
                            dropdownColor: Colors.grey[900],
                            style: const TextStyle(color: Colors.white),
                            decoration: _decoracionInput('Cliente'),
                            items: clientes.map((cliente) {
                              return DropdownMenuItem(
                                value: cliente.id,
                                child: Text(
                                  cliente['nombre'] ?? 'Nombre no disponible',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => clienteId = value),
                          ),
                          const SizedBox(height: 16),
                          _campoTexto('Nombre', nombre, (v) => nombre = v),
                          const SizedBox(height: 16),
                          _campoTexto('Especie', especie, (v) => especie = v),
                          const SizedBox(height: 16),
                          _campoTexto('Raza', raza, (v) => raza = v),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate: fechaNacimiento ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (fecha != null)
                                setState(() => fechaNacimiento = fecha);
                            },
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                            ),
                            label: Text(
                              fechaNacimiento == null
                                  ? 'Seleccionar Fecha de Nacimiento'
                                  : '${fechaNacimiento!.toLocal()}'.split(
                                      ' ',
                                    )[0],
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: actualizarPaciente,
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Colors.tealAccent, Colors.teal],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.tealAccent.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.save, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Actualizar Paciente',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _decoracionInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.tealAccent, width: 2),
      ),
    );
  }

  Widget _campoTexto(String label, String inicial, Function(String) onChanged) {
    return TextFormField(
      initialValue: inicial,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: _decoracionInput(label),
    );
  }
}
