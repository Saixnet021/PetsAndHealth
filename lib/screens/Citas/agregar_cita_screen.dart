import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgregarCitaScreen extends StatefulWidget {
  const AgregarCitaScreen({super.key});

  @override
  State<AgregarCitaScreen> createState() => _AgregarCitaScreenState();
}

class _AgregarCitaScreenState extends State<AgregarCitaScreen> {
  String? clienteId;
  String? pacienteId;
  String? doctorId;
  String? motivo;
  DateTime? fechaHora;

  List<DocumentSnapshot> clientes = [];
  List<DocumentSnapshot> pacientes = [];
  List<DocumentSnapshot> doctores = [];

  final List<String> motivosPredefinidos = [
    'Vacunación',
    'Chequeo general',
    'Desparasitación',
    'Cirugía',
    'Consulta de emergencia',
    'Consulta dental',
    'Otro',
  ];

  bool cargandoPacientes = false;

  @override
  void initState() {
    super.initState();
    cargarClientesYDoctores();
  }

  Future<void> cargarClientesYDoctores() async {
    try {
      final clientesSnap = await FirebaseFirestore.instance
          .collection('clientes')
          .get();
      final doctoresSnap = await FirebaseFirestore.instance
          .collection('doctores')
          .get();

      setState(() {
        clientes = clientesSnap.docs;
        doctores = doctoresSnap.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando clientes o doctores: $e')),
      );
    }
  }

  Future<void> cargarPacientes(String clienteId) async {
    setState(() {
      cargandoPacientes = true;
      pacientes = [];
      pacienteId = null;
    });

    try {
      final pacientesSnap = await FirebaseFirestore.instance
          .collection('pacientes')
          .where('clienteId', isEqualTo: clienteId)
          .get();

      setState(() {
        pacientes = pacientesSnap.docs;
        cargandoPacientes = false;
      });

      if (pacientes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este cliente no tiene mascotas registradas'),
          ),
        );
      }
    } catch (e) {
      setState(() => cargandoPacientes = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando mascotas: $e')));
    }
  }

  bool get todosCamposValidos {
    return clienteId != null &&
        pacienteId != null &&
        doctorId != null &&
        motivo != null &&
        motivo!.isNotEmpty &&
        fechaHora != null &&
        fechaHora!.isAfter(DateTime.now());
  }

  Future<void> guardarCita() async {
    if (!todosCamposValidos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos correctamente'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('citas').add({
        'clienteId': clienteId,
        'pacienteId': pacienteId,
        'doctorId': doctorId,
        'fecha': fechaHora!.toIso8601String().split('T')[0],
        'hora':
            '${fechaHora!.hour.toString().padLeft(2, '0')}:${fechaHora!.minute.toString().padLeft(2, '0')}',
        'motivo': motivo,
        'estado': 'Pendiente', // Podrías manejar estados de cita
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita guardada exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error guardando cita: $e')));
    }
  }

  Future<void> seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (fecha == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora == null) return;

    final fechaHoraSeleccionada = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );

    if (fechaHoraSeleccionada.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha y hora no pueden ser en el pasado'),
        ),
      );
      return;
    }

    setState(() {
      fechaHora = fechaHoraSeleccionada;
    });
  }

  String get fechaHoraTexto {
    if (fechaHora == null) return 'Seleccionar Fecha y Hora';
    return '${fechaHora!.day.toString().padLeft(2, '0')}/${fechaHora!.month.toString().padLeft(2, '0')}/${fechaHora!.year} ${fechaHora!.hour.toString().padLeft(2, '0')}:${fechaHora!.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Agregar Cita'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: clienteId,
              hint: const Text('Selecciona un Cliente'),
              items: clientes
                  .map(
                    (cliente) => DropdownMenuItem(
                      value: cliente.id,
                      child: Text(cliente['nombre']),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  clienteId = value;
                  pacienteId = null;
                  pacientes = [];
                });
                if (value != null) {
                  cargarPacientes(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            cargandoPacientes
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: pacienteId,
                    hint: const Text('Selecciona un Paciente'),
                    items: pacientes
                        .map(
                          (paciente) => DropdownMenuItem(
                            value: paciente.id,
                            child: Text(paciente['nombre']),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => pacienteId = value),
                    decoration: const InputDecoration(
                      labelText: 'Paciente',
                      border: OutlineInputBorder(),
                    ),
                    disabledHint: const Text('Selecciona un cliente primero'),
                    isExpanded: true,
                    // Deshabilitar si no hay pacientes cargados
                    onTap: pacientes.isEmpty ? null : () {},
                    validator: (value) =>
                        value == null ? 'Debe seleccionar un paciente' : null,
                  ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: doctorId,
              hint: const Text('Selecciona un Doctor'),
              items: doctores
                  .map(
                    (doctor) => DropdownMenuItem(
                      value: doctor.id,
                      child: Text(doctor['nombre']),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => doctorId = value),
              decoration: const InputDecoration(
                labelText: 'Doctor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: motivo,
              hint: const Text('Selecciona un Motivo'),
              items: motivosPredefinidos
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (value) => setState(() => motivo = value),
              decoration: const InputDecoration(
                labelText: 'Motivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: seleccionarFechaHora,
              icon: const Icon(Icons.calendar_today),
              label: Text(fechaHoraTexto),
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
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: todosCamposValidos ? guardarCita : null,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: todosCamposValidos
                    ? Colors.orange
                    : Colors.orange.withOpacity(0.5),
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
