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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('Editar Paciente'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Imagen
            GestureDetector(
              onTap: seleccionarImagen,
              child: imagenSeleccionada != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imagenSeleccionada!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : fotoUrlExistente != null && fotoUrlExistente!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        fotoUrlExistente!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Toca para seleccionar imagen'),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: clienteId,
              decoration: const InputDecoration(labelText: 'Cliente'),
              items: clientes.map((cliente) {
                return DropdownMenuItem(
                  value: cliente.id,
                  child: Text(cliente['nombre']),
                );
              }).toList(),
              onChanged: (value) => setState(() => clienteId = value),
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
              onChanged: (value) => nombre = value,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: especie,
              decoration: const InputDecoration(labelText: 'Especie'),
              onChanged: (value) => especie = value,
            ),
            const SizedBox(height: 10),

            TextFormField(
              initialValue: raza,
              decoration: const InputDecoration(labelText: 'Raza'),
              onChanged: (value) => raza = value,
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: fechaNacimiento ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    fechaNacimiento = picked;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                fechaNacimiento == null
                    ? 'Seleccionar Fecha de Nacimiento'
                    : '${fechaNacimiento!.toLocal()}'.split(' ')[0],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: actualizarPaciente,
              icon: const Icon(Icons.save),
              label: const Text('Actualizar Paciente'),
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
          ],
        ),
      ),
    );
  }
}
