import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgregarPacienteScreen extends StatefulWidget {
  const AgregarPacienteScreen({super.key});

  @override
  State<AgregarPacienteScreen> createState() => _AgregarPacienteScreenState();
}

class _AgregarPacienteScreenState extends State<AgregarPacienteScreen> {
  String? clienteId;
  String nombre = '';
  String especie = '';
  String raza = '';
  DateTime? fechaNacimiento;

  List<DocumentSnapshot> clientes = [];

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  // Función para cargar los clientes desde Firestore
  Future<void> cargarClientes() async {
    final clientesSnap =
        await FirebaseFirestore.instance.collection('clientes').get();
    setState(() {
      clientes = clientesSnap.docs;
    });
  }

  // Función para guardar el paciente
  Future<void> guardarPaciente() async {
    if (clienteId == null ||
        nombre.isEmpty ||
        especie.isEmpty ||
        raza.isEmpty ||
        fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    // Guardar la fecha como Timestamp
    await FirebaseFirestore.instance.collection('pacientes').add({
      'clienteId': clienteId,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'fechaNacimiento': Timestamp.fromDate(
        fechaNacimiento!,
      ), // Convertir a Timestamp
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Agregar Paciente'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Dropdown para seleccionar un cliente
            DropdownButtonFormField<String>(
              value: clienteId,
              hint: const Text('Selecciona un Cliente'),
              items:
                  clientes.map((cliente) {
                    // Verificar si el campo 'nombre' existe
                    final clienteNombre =
                        cliente['nombre'] ?? 'Nombre no disponible';
                    return DropdownMenuItem(
                      value: cliente.id,
                      child: Text(clienteNombre),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => clienteId = value),
            ),
            const SizedBox(height: 10),
            // Campo para nombre del paciente
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre del Paciente',
              ),
              onChanged: (value) => nombre = value,
            ),
            const SizedBox(height: 10),
            // Campo para especie
            TextFormField(
              decoration: const InputDecoration(labelText: 'Especie'),
              onChanged: (value) => especie = value,
            ),
            const SizedBox(height: 10),
            // Campo para raza
            TextFormField(
              decoration: const InputDecoration(labelText: 'Raza'),
              onChanged: (value) => raza = value,
            ),
            const SizedBox(height: 10),
            // Selector de fecha de nacimiento
            ElevatedButton.icon(
              onPressed: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                  setState(() {
                    fechaNacimiento = fecha;
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
            // Botón para guardar paciente
            ElevatedButton.icon(
              onPressed: guardarPaciente,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Paciente'),
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
