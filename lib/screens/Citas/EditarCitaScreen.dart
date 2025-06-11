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

    if (clienteId != null) {
      await cargarPacientes(clienteId!);
    }
  }

  Future<void> cargarPacientes(String clienteId) async {
    final pacientesSnap = await FirebaseFirestore.instance
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

    try {
      await FirebaseFirestore.instance
          .collection('citas')
          .doc(widget.citaId)
          .update({
            'clienteId': clienteId,
            'pacienteId': pacienteId,
            'doctorId': doctorId,
            'fecha': fechaHora!.toIso8601String().split('T')[0],
            'hora':
                '${fechaHora!.hour.toString().padLeft(2, '0')}:${fechaHora!.minute.toString().padLeft(2, '0')}',
            'motivo': motivo,
          });

      Navigator.pop(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Hubo un problema al actualizar la cita: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15), // Efecto glassmorphism
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.tealAccent, width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      dropdownColor: Colors.teal.shade700,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String label,
    required IconData icon,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15), // Efecto glassmorphism
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.tealAccent, width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 600 ? 500.0 : double.infinity;

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
                      'Editar Cita',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_calendar, color: Colors.white),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: formWidth,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
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
                      child: Column(
                        children: [
                          const Text(
                            'Actualizar Datos de la Cita',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildDropdownField(
                            value: clienteId,
                            label: 'Cliente',
                            icon: Icons.person,
                            items: clientes.map((cliente) {
                              return DropdownMenuItem(
                                value: cliente.id,
                                child: Text(
                                  cliente['nombre'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                clienteId = value;
                                pacienteId = null;
                                if (value != null) {
                                  cargarPacientes(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: pacienteId,
                            label: 'Paciente',
                            icon: Icons.pets,
                            items: pacientes.map((paciente) {
                              return DropdownMenuItem(
                                value: paciente.id,
                                child: Text(
                                  paciente['nombre'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => pacienteId = value),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: doctorId,
                            label: 'Doctor',
                            icon: Icons.medical_services,
                            items: doctores.map((doctor) {
                              return DropdownMenuItem(
                                value: doctor.id,
                                child: Text(
                                  doctor['nombre'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => doctorId = value),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            initialValue: motivo,
                            label: 'Motivo',
                            icon: Icons.note_alt,
                            onChanged: (value) => motivo = value,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () async {
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
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.tealAccent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      fechaHora == null
                                          ? 'Seleccionar Fecha y Hora'
                                          : '${fechaHora!.day}/${fechaHora!.month}/${fechaHora!.year} - ${fechaHora!.hour.toString().padLeft(2, '0')}:${fechaHora!.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: actualizarCita,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'Actualizar Cita',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
}
//✅