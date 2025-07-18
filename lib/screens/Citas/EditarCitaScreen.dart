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

  State<EditarCitaScreen> createState() => _EditarCitaScreenState();
}

class _EditarCitaScreenState extends State<EditarCitaScreen> {
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
        motivo == null) {
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

  Widget _buildDropdownFields({
    required String? value,
    required String hint,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    IconData? icon,
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
        dropdownColor: Colors.grey[900],
        iconEnabledColor: Colors.tealAccent,
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
          // Fondo con gradiente
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
          // Capa oscura
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          ),
          // Contenido
          Column(
            children: [
              // AppBar personalizado
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
              // Formulario
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
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Actualizar Datos de la Cita',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                          _buildDropdownFields(
                            value: motivo,
                            hint: 'Selecciona un Motivo',
                            label: 'Motivo',
                            icon: Icons.note_alt,
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

                          const SizedBox(height: 16),
                          GestureDetector(
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
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
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
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: actualizarCita,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.withOpacity(0.85),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: Colors.tealAccent.withOpacity(0.4),
                                elevation: 10,
                              ),
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                'Actualizar Cita',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
}
//✅