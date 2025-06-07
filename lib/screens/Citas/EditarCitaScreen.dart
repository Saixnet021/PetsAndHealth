import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditarCitaScreen extends StatefulWidget {
  final String citaId;
  final Map<String, dynamic> citaData;

  const EditarCitaScreen({
    super.key,
    required this.citaId,
    required this.citaData,
  });

  @override
  State<EditarCitaScreen> createState() => _EditarCitaScreenState();
}

class _EditarCitaScreenState extends State<EditarCitaScreen> {
  String? clienteId;
  String? pacienteId;
  String? doctorId;
  String motivo = '';
  DateTime? fechaHora;

  List<DocumentSnapshot> clientes = [];
  List<DocumentSnapshot> pacientes = [];
  List<DocumentSnapshot> doctores = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
    cargarDatosIniciales();
  }

  void cargarDatosIniciales() {
    clienteId = widget.citaData['clienteId'];
    pacienteId = widget.citaData['pacienteId'];
    doctorId = widget.citaData['doctorId'];
    motivo = widget.citaData['motivo'];
    final fecha = DateTime.parse(widget.citaData['fecha']);
    final horaParts = widget.citaData['hora'].split(':');
    fechaHora = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(horaParts[0]),
      int.parse(horaParts[1]),
    );
  }

  Future<void> cargarDatos() async {
    final clientesSnap =
        await FirebaseFirestore.instance.collection('clientes').get();
    final doctoresSnap =
        await FirebaseFirestore.instance.collection('doctores').get();

    setState(() {
      clientes = clientesSnap.docs;
      doctores = doctoresSnap.docs;
    });

    if (clienteId != null) {
      await cargarPacientes(clienteId!);
    }
  }

  Future<void> cargarPacientes(String clienteId) async {
    final pacientesSnap =
        await FirebaseFirestore.instance
            .collection('pacientes')
            .where('clienteId', isEqualTo: clienteId)
            .get();

    setState(() {
      pacientes = pacientesSnap.docs;
    });
  }

  Future<void> actualizarCita() async {
    if (clienteId == null ||
        pacienteId == null ||
        doctorId == null ||
        fechaHora == null ||
        motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('citas').doc(widget.citaId).update({
      'clienteId': clienteId,
      'pacienteId': pacienteId,
      'doctorId': doctorId,
      'fecha': fechaHora!.toIso8601String().split('T')[0],
      'hora':
          '${fechaHora!.hour.toString().padLeft(2, '0')}:${fechaHora!.minute.toString().padLeft(2, '0')}',
      'motivo': motivo,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), // azul muy claro de fondo
      appBar: AppBar(
        title: const Text('Editar Cita'),
        backgroundColor: Colors.teal, // azul más fuerte
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
                onChanged: (value) {
                  setState(() {
                    clienteId = value;
                    pacienteId = null;
                    cargarPacientes(value!);
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: pacienteId,
                decoration: const InputDecoration(labelText: 'Paciente'),
                items:
                    pacientes.map((paciente) {
                      return DropdownMenuItem(
                        value: paciente.id,
                        child: Text(paciente['nombre']),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => pacienteId = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: doctorId,
                decoration: const InputDecoration(labelText: 'Doctor'),
                items:
                    doctores.map((doctor) {
                      return DropdownMenuItem(
                        value: doctor.id,
                        child: Text(doctor['nombre']),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => doctorId = value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: motivo,
                decoration: const InputDecoration(labelText: 'Motivo'),
                onChanged: (value) => motivo = value,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: fechaHora ?? DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (fecha != null) {
                    final hora = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        fechaHora ?? DateTime.now(),
                      ),
                    );
                    if (hora != null) {
                      setState(() {
                        fechaHora = DateTime(
                          fecha.year,
                          fecha.month,
                          fecha.day,
                          hora.hour,
                          hora.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(
                  fechaHora == null
                      ? 'Seleccionar Fecha y Hora'
                      : '${fechaHora!.toLocal()}'.split('.')[0],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28A745), // verde éxito
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: actualizarCita,
                child: const Text(
                  'Actualizar Cita',
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
