import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petsandhealth/screens/Citas/citas_screen.dart';
import 'package:petsandhealth/screens/Clientes/clientes_screen.dart';
import 'package:petsandhealth/screens/Doctores/doctores_screen.dart';
import 'package:petsandhealth/screens/Pacientes/pacientes_screen.dart';
import 'package:petsandhealth/profile_screen.dart';
import 'package:petsandhealth/usuarios_screen.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;
  final String userRole;

  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    if (!isWeb) return const SizedBox.shrink();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.teal.shade100],
                    ),
                  ),
                  child: const Icon(Icons.pets, color: Colors.teal, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pets & Health',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User Info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole.toUpperCase(),
                        style: TextStyle(
                          color: Colors.tealAccent.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/home',
                  isActive: currentRoute == '/home',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Citas',
                  route: '/citas',
                  isActive: currentRoute == '/citas',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.pets,
                  title: 'Pacientes',
                  route: '/pacientes',
                  isActive: currentRoute == '/pacientes',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.medical_services,
                  title: 'Doctores',
                  route: '/doctores',
                  isActive: currentRoute == '/doctores',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  title: 'Clientes',
                  route: '/clientes',
                  isActive: currentRoute == '/clientes',
                ),
                if (userRole == 'administrador')
                  _buildNavItem(
                    context,
                    icon: Icons.supervised_user_circle,
                    title: 'Usuarios',
                    route: '/usuarios',
                    isActive: currentRoute == '/usuarios',
                  ),

                const SizedBox(height: 24),

                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                ),

                _buildNavItem(
                  context,
                  icon: Icons.person,
                  title: 'Perfil',
                  route: '/profile',
                  isActive: currentRoute == '/profile',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings,
                  title: 'Configuración',
                  route: '/settings',
                  isActive: currentRoute == '/settings',
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  ),
                ),
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Cerrar Sesión'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navegación basada en rutas existentes
            if (route == '/home') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            } else {
              // Para otras rutas, mantener la navegación actual
              _navigateToScreen(context, route);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.teal.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: Colors.teal.withOpacity(0.5))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? Colors.tealAccent
                      : Colors.white.withOpacity(0.8),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String route) {
    switch (route) {
      case '/citas':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitasScreen()),
        );
        break;
      case '/pacientes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PacientesScreen()),
        );
        break;
      case '/doctores':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctoresScreen()),
        );
        break;
      case '/clientes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClientesScreen()),
        );
        break;
      case '/usuarios':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsuariosScreen()),
        );
        break;
      case '/profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }
}
