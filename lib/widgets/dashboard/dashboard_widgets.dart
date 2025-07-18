import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsandhealth/screens/Citas/agregar_cita_screen.dart';
import 'package:petsandhealth/screens/Pacientes/agregar_paciente_screen.dart';
import 'package:petsandhealth/screens/Clientes/agregar_cliente_screen.dart';
import 'package:petsandhealth/screens/Doctores/agregar_doctor_screen.dart';
import 'dart:async';

class DashboardStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isMobile ? 24 : 28,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardStatsGrid extends StatelessWidget {
  final String userRole;

  const DashboardStatsGrid({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QuerySnapshot>>(
      stream: _getCombinedStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid(context);
        }

        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        final data = snapshot.data;
        if (data == null || data.length < 4) {
          return _buildErrorWidget();
        }

        final citasCount = data[0].docs.length;
        final pacientesCount = data[1].docs.length;
        final doctoresCount = data[2].docs.length;
        final clientesCount = data[3].docs.length;
        final usuariosCount = data.length > 4 ? data[4].docs.length : 0;

        // Calcular citas de hoy
        final today = DateTime.now();
        final todayString =
            '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
        final citasHoy = data[0].docs.where((doc) {
          final citaData = doc.data() as Map<String, dynamic>;
          return citaData['fecha'] == todayString;
        }).length;

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 3;
            }

            final stats = _buildStatsList(
              citasCount,
              pacientesCount,
              doctoresCount,
              clientesCount,
              usuariosCount,
              citasHoy,
            );

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) => stats[index],
            );
          },
        );
      },
    );
  }

  Stream<List<QuerySnapshot>> _getCombinedStream() {
    final citasStream = FirebaseFirestore.instance
        .collection('citas')
        .snapshots();
    final pacientesStream = FirebaseFirestore.instance
        .collection('pacientes')
        .snapshots();
    final doctoresStream = FirebaseFirestore.instance
        .collection('doctores')
        .snapshots();
    final clientesStream = FirebaseFirestore.instance
        .collection('clientes')
        .snapshots();

    if (userRole == 'administrador') {
      final usuariosStream = FirebaseFirestore.instance
          .collection('users')
          .snapshots();

      return StreamZip.combineLatest5(
        citasStream,
        pacientesStream,
        doctoresStream,
        clientesStream,
        usuariosStream,
        (citas, pacientes, doctores, clientes, usuarios) => [
          citas,
          pacientes,
          doctores,
          clientes,
          usuarios,
        ],
      );
    } else {
      return StreamZip.combineLatest4(
        citasStream,
        pacientesStream,
        doctoresStream,
        clientesStream,
        (citas, pacientes, doctores, clientes) => [
          citas,
          pacientes,
          doctores,
          clientes,
        ],
      );
    }
  }

  List<DashboardStatsCard> _buildStatsList(
    int citasCount,
    int pacientesCount,
    int doctoresCount,
    int clientesCount,
    int usuariosCount,
    int citasHoy,
  ) {
    final stats = [
      DashboardStatsCard(
        title: 'Citas Totales',
        value: citasCount.toString(),
        icon: Icons.calendar_today,
        color: const Color(0xFF3B82F6),
        subtitle: '$citasHoy citas hoy',
      ),
      DashboardStatsCard(
        title: 'Pacientes',
        value: pacientesCount.toString(),
        icon: Icons.pets,
        color: const Color(0xFF10B981),
        subtitle: 'Mascotas registradas',
      ),
      DashboardStatsCard(
        title: 'Doctores',
        value: doctoresCount.toString(),
        icon: Icons.medical_services,
        color: const Color(0xFF8B5CF6),
        subtitle: 'Veterinarios activos',
      ),
      DashboardStatsCard(
        title: 'Clientes',
        value: clientesCount.toString(),
        icon: Icons.people,
        color: const Color(0xFFF59E0B),
        subtitle: 'Propietarios registrados',
      ),
    ];

    if (userRole == 'administrador') {
      stats.add(
        DashboardStatsCard(
          title: 'Usuarios',
          value: usuariosCount.toString(),
          icon: Icons.supervised_user_circle,
          color: const Color(0xFFEF4444),
          subtitle: 'Usuarios del sistema',
        ),
      );
    }

    return stats;
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: userRole == 'administrador' ? 5 : 4,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            'Error al cargar estadísticas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No se pudieron obtener los datos del dashboard',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Helper class para combinar streams
class StreamZip {
  static Stream<R> combineLatest4<T1, T2, T3, T4, R>(
    Stream<T1> stream1,
    Stream<T2> stream2,
    Stream<T3> stream3,
    Stream<T4> stream4,
    R Function(T1, T2, T3, T4) combiner,
  ) {
    late StreamController<R> controller;
    late StreamSubscription sub1, sub2, sub3, sub4;

    T1? value1;
    T2? value2;
    T3? value3;
    T4? value4;

    bool hasValue1 = false,
        hasValue2 = false,
        hasValue3 = false,
        hasValue4 = false;

    void tryEmit() {
      if (hasValue1 && hasValue2 && hasValue3 && hasValue4) {
        controller.add(combiner(value1!, value2!, value3!, value4!));
      }
    }

    controller = StreamController<R>(
      onListen: () {
        sub1 = stream1.listen((v) {
          value1 = v;
          hasValue1 = true;
          tryEmit();
        });
        sub2 = stream2.listen((v) {
          value2 = v;
          hasValue2 = true;
          tryEmit();
        });
        sub3 = stream3.listen((v) {
          value3 = v;
          hasValue3 = true;
          tryEmit();
        });
        sub4 = stream4.listen((v) {
          value4 = v;
          hasValue4 = true;
          tryEmit();
        });
      },
      onCancel: () {
        sub1.cancel();
        sub2.cancel();
        sub3.cancel();
        sub4.cancel();
      },
    );

    return controller.stream;
  }

  static Stream<R> combineLatest5<T1, T2, T3, T4, T5, R>(
    Stream<T1> stream1,
    Stream<T2> stream2,
    Stream<T3> stream3,
    Stream<T4> stream4,
    Stream<T5> stream5,
    R Function(T1, T2, T3, T4, T5) combiner,
  ) {
    late StreamController<R> controller;
    late StreamSubscription sub1, sub2, sub3, sub4, sub5;

    T1? value1;
    T2? value2;
    T3? value3;
    T4? value4;
    T5? value5;

    bool hasValue1 = false,
        hasValue2 = false,
        hasValue3 = false,
        hasValue4 = false,
        hasValue5 = false;

    void tryEmit() {
      if (hasValue1 && hasValue2 && hasValue3 && hasValue4 && hasValue5) {
        controller.add(combiner(value1!, value2!, value3!, value4!, value5!));
      }
    }

    controller = StreamController<R>(
      onListen: () {
        sub1 = stream1.listen((v) {
          value1 = v;
          hasValue1 = true;
          tryEmit();
        });
        sub2 = stream2.listen((v) {
          value2 = v;
          hasValue2 = true;
          tryEmit();
        });
        sub3 = stream3.listen((v) {
          value3 = v;
          hasValue3 = true;
          tryEmit();
        });
        sub4 = stream4.listen((v) {
          value4 = v;
          hasValue4 = true;
          tryEmit();
        });
        sub5 = stream5.listen((v) {
          value5 = v;
          hasValue5 = true;
          tryEmit();
        });
      },
      onCancel: () {
        sub1.cancel();
        sub2.cancel();
        sub3.cancel();
        sub4.cancel();
        sub5.cancel();
      },
    );

    return controller.stream;
  }
}

class QuickActionsWidget extends StatelessWidget {
  final String userRole;

  const QuickActionsWidget({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: Colors.tealAccent,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _buildQuickActions(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickActionButton(
        icon: Icons.add_circle,
        label: 'Nueva Cita',
        color: Colors.blue,
        onTap: () => _navigateToAddAppointment(context),
      ),
      _QuickActionButton(
        icon: Icons.pets,
        label: 'Nuevo Paciente',
        color: Colors.green,
        onTap: () => _navigateToAddPatient(context),
      ),
      _QuickActionButton(
        icon: Icons.person_add,
        label: 'Nuevo Cliente',
        color: Colors.orange,
        onTap: () => _navigateToAddClient(context),
      ),
    ];

    if (userRole == 'administrador') {
      actions.add(
        _QuickActionButton(
          icon: Icons.medical_services,
          label: 'Nuevo Doctor',
          color: Colors.purple,
          onTap: () => _navigateToAddDoctor(context),
        ),
      );
    }

    return actions;
  }

  void _navigateToAddAppointment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgregarCitaScreen()),
    );
  }

  void _navigateToAddPatient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgregarPacienteScreen()),
    );
  }

  void _navigateToAddClient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgregarClienteScreen()),
    );
  }

  void _navigateToAddDoctor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgregarDoctorScreen()),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: isMobile ? 16 : 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.tealAccent,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Actividad Reciente',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('citas')
                .orderBy('fecha', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.tealAccent),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  'No hay actividad reciente',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildActivityItem(
                    icon: Icons.calendar_today,
                    title: 'Cita programada',
                    subtitle: '${data['fecha']} - ${data['hora']}',
                    time: 'Hace 2 horas', // Placeholder
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.tealAccent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
