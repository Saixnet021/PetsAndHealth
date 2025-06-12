import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditarDoctorScreen extends StatefulWidget {
  final String doctorId;
  final Map<String, dynamic> doctorData;

  const EditarDoctorScreen({
    super.key,
    required this.doctorId,
    required this.doctorData,
  });

  @override
  State<EditarDoctorScreen> createState() => _EditarDoctorScreenState();
}

class _EditarDoctorScreenState extends State<EditarDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  String? _especialidadSeleccionada;

  final List<String> especialidades = [
    'Veterinario General',
    'Cirujano Veterinario',
    'Dermatólogo Veterinario',
    'Cardiólogo Veterinario',
    'Oftalmólogo Veterinario',
    'Oncólogo Veterinario',
    'Especialista en Animales Exóticos',
    'Etólogo (Conductista Animal)',
    'Odontólogo Veterinario',
    'Zootecnista (Nutrición y Producción Animal)',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.doctorData['nombre'],
    );
    _correoController = TextEditingController(
      text: widget.doctorData['correo'],
    );
    _telefonoController = TextEditingController(
      text: widget.doctorData['telefono'],
    );
    _especialidadSeleccionada = widget.doctorData['especialidad'];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _actualizarDoctor() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('doctores')
            .doc(widget.doctorId)
            .update({
              'nombre': _nombreController.text.trim(),
              'especialidad': _especialidadSeleccionada,
              'correo': _correoController.text.trim(),
              'telefono': _telefonoController.text.trim(),
            });
        Navigator.pop(context);
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text('Hubo un problema al actualizar el doctor: $e'),
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _especialidadSeleccionada,
      dropdownColor: Colors.grey[850],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.medical_services, color: Colors.tealAccent),
        labelText: 'Especialidad',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
        ),
      ),
      items: especialidades.map((especialidad) {
        return DropdownMenuItem(value: especialidad, child: Text(especialidad));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _especialidadSeleccionada = value;
        });
      },
      validator: (value) => value == null || value.isEmpty
          ? 'Por favor selecciona una especialidad'
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 600 ? 500.0 : double.infinity;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
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

          // Contenido
          Column(
            children: [
              // AppBar personalizado
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Editar Doctor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.local_hospital_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              // Formulario
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: formWidth,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              'Actualizar Datos del Doctor',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _nombreController,
                              label: 'Nombre',
                              icon: Icons.person,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Ingrese un nombre'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _correoController,
                              label: 'Correo',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese un correo';
                                }
                                if (!RegExp(
                                  r"^[^@]+@[^@]+\.[^@]+",
                                ).hasMatch(value)) {
                                  return 'Correo no válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _telefonoController,
                              label: 'Teléfono',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Ingrese un teléfono'
                                  : null,
                            ),
                            const SizedBox(height: 30),
                            FilledButton.icon(
                              onPressed: _actualizarDoctor,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                'Guardar Cambios',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ),
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
