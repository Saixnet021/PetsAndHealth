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
        'estado': 'Pendiente',
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

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    String? disabledHint,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: Colors.white70)),
        items: items,
        onChanged: isEnabled ? onChanged : null,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.tealAccent)
              : null,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: false,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.tealAccent, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        dropdownColor: Colors.teal.shade800,
        disabledHint: disabledHint != null
            ? Text(disabledHint, style: const TextStyle(color: Colors.white54))
            : null,
        isExpanded: true,
      ),
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
                      'Agregar Cita',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'opcion1',
                          child: Text('Opción 1'),
                        ),
                        const PopupMenuItem(
                          value: 'opcion2',
                          child: Text('Opción 2'),
                        ),
                      ],
                      onSelected: (value) {
                        // Aquí puedes manejar las opciones
                      },
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: Container(
                      width: formWidth,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
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
                            'Agendar Nueva Cita',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildDropdownField(
                            value: clienteId,
                            hint: 'Selecciona un Cliente',
                            label: 'Cliente',
                            icon: Icons.person,
                            items: clientes
                                .map(
                                  (cliente) => DropdownMenuItem(
                                    value: cliente.id,
                                    child: Text(
                                      cliente['nombre'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
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
                          ),
                          const SizedBox(height: 16),
                          cargandoPacientes
                              ? Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withOpacity(0.15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.tealAccent,
                                    ),
                                  ),
                                )
                              : _buildDropdownField(
                                  value: pacienteId,
                                  hint: 'Selecciona un Paciente',
                                  label: 'Paciente',
                                  icon: Icons.pets,
                                  items: pacientes
                                      .map(
                                        (paciente) => DropdownMenuItem(
                                          value: paciente.id,
                                          child: Text(
                                            paciente['nombre'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => pacienteId = value),
                                  isEnabled: pacientes.isNotEmpty,
                                  disabledHint: 'Selecciona un cliente primero',
                                ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: doctorId,
                            hint: 'Selecciona un Doctor',
                            label: 'Doctor',
                            icon: Icons.medical_services,
                            items: doctores
                                .map(
                                  (doctor) => DropdownMenuItem(
                                    value: doctor.id,
                                    child: Text(
                                      doctor['nombre'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => doctorId = value),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: motivo,
                            hint: 'Selecciona un Motivo',
                            label: 'Motivo',
                            icon: Icons.assignment,
                            items: motivosPredefinidos
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                      m,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => motivo = value),
                          ),
                          const SizedBox(height: 20),
                          // Botón de fecha y hora
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: seleccionarFechaHora,
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                              ),
                              label: Text(
                                fechaHoraTexto,
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: todosCamposValidos
                                  ? guardarCita
                                  : null,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                'Guardar Cita',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: todosCamposValidos
                                    ? Colors.orange
                                    : Colors.orange.withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 30,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(160, 45),
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