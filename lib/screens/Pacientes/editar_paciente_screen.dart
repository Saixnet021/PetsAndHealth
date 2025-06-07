import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    final timestamp = widget.pacienteData['fechaNacimiento'];
    if (timestamp is Timestamp) {
      fechaNacimiento = timestamp.toDate();
    }
  }

  Future<void> cargarClientes() async {
    final clientesSnap =
        await FirebaseFirestore.instance.collection('clientes').get();
    setState(() {
      clientes = clientesSnap.docs;
    });
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

    await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(widget.pacienteId)
        .update({
          'nombre': nombre,
          'especie': especie,
          'raza': raza,
          'fechaNacimiento': Timestamp.fromDate(fechaNacimiento!),
          'clienteId': clienteId,
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            children: [
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
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: fechaNacimiento ?? DateTime(2015),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      fechaNacimiento = picked;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  fechaNacimiento == null
                      ? 'Seleccionar Fecha de Nacimiento'
                      : 'Fecha de Nacimiento: ${fechaNacimiento!.toLocal()}'
                          .split(' ')[0],
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: clienteId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items:
                    clientes.map((cliente) {
                      return DropdownMenuItem(
                        value: cliente.id,
                        child: Text(cliente['nombre']),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => clienteId = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: actualizarPaciente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28A745),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Actualizar Paciente',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
