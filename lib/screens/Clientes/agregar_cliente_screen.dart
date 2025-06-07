import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AgregarClienteScreen extends StatefulWidget {
  const AgregarClienteScreen({super.key});

  @override
  _AgregarClienteScreenState createState() => _AgregarClienteScreenState();
}

class _AgregarClienteScreenState extends State<AgregarClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _cargando = false;

  Future<void> _buscarPorDNI() async {
    final dni = _dniController.text.trim();
    if (dni.length != 8) {
      _mostrarError('Ingrese un DNI válido de 8 dígitos.');
      return;
    }

    setState(() => _cargando = true);

    final url = Uri.parse('https://backend-dni.vercel.app/dni/$dni');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('nombres')) {
          final nombreCompleto =
              '${data["nombres"]} ${data["apellidoPaterno"]} ${data["apellidoMaterno"]}';
          setState(() {
            _nombreController.text = nombreCompleto;
          });
        } else {
          _mostrarError('No se encontraron datos para el DNI ingresado.');
        }
      } else {
        _mostrarError(
          'Error en la respuesta del servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      _mostrarError('Error al consultar DNI: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _guardarCliente() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('clientes').add({
          'dni': _dniController.text.trim(),
          'nombre': _nombreController.text.trim(),
          'correo': _correoController.text.trim(),
          'telefono': _telefonoController.text.trim(),
        });

        Navigator.pop(context);
      } catch (e) {
        _mostrarError('Hubo un problema al agregar el cliente: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Cliente'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dniController,
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  suffixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el DNI';
                  }
                  if (value.length != 8) {
                    return 'El DNI debe tener 8 dígitos';
                  }
                  return null;
                },
              ),
              ElevatedButton.icon(
                onPressed: _cargando ? null : _buscarPorDNI,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                icon: _cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search),
                label: const Text('Buscar por DNI'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un correo';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Correo no válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un número de teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCliente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Guardar Cliente',
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
