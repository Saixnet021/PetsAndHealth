import 'package:flutter/material.dart';

class MobileBottomNav extends StatelessWidget {
  final String currentRoute;
  final String userRole;
  final Function(String) onNavigate;

  const MobileBottomNav({
    super.key,
    required this.currentRoute,
    required this.userRole,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    if (!isMobile) return const SizedBox.shrink();

    final items = _getNavigationItems();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F2027), Color(0xFF203A43)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items
                .map((item) => _buildNavItem(context, item))
                .toList(),
          ),
        ),
      ),
    );
  }

  List<BottomNavItem> _getNavigationItems() {
    final baseItems = [
      BottomNavItem(icon: Icons.dashboard, label: 'Inicio', route: '/home'),
      BottomNavItem(
        icon: Icons.calendar_today,
        label: 'Citas',
        route: '/citas',
      ),
      BottomNavItem(icon: Icons.pets, label: 'Pacientes', route: '/pacientes'),
      BottomNavItem(icon: Icons.people, label: 'Clientes', route: '/clientes'),
    ];

    // Agregar más opciones para administradores
    if (userRole == 'administrador') {
      baseItems.add(
        BottomNavItem(icon: Icons.more_horiz, label: 'Más', route: '/more'),
      );
    } else {
      baseItems.add(
        BottomNavItem(
          icon: Icons.medical_services,
          label: 'Doctores',
          route: '/doctores',
        ),
      );
    }

    return baseItems;
  }

  Widget _buildNavItem(BuildContext context, BottomNavItem item) {
    final isActive = currentRoute == item.route;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onNavigate(item.route),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.teal.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: isActive
                        ? Colors.tealAccent
                        : Colors.white.withOpacity(0.7),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.tealAccent
                        : Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final String route;

  BottomNavItem({required this.icon, required this.label, required this.route});
}

// Modal para "Más opciones" en administradores
class MoreOptionsModal extends StatelessWidget {
  final String userRole;
  final Function(String) onNavigate;

  const MoreOptionsModal({
    super.key,
    required this.userRole,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Más opciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Options
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildOption(
                  context,
                  icon: Icons.medical_services,
                  title: 'Doctores',
                  subtitle: 'Gestionar médicos veterinarios',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate('/doctores');
                  },
                ),
                const SizedBox(height: 16),
                _buildOption(
                  context,
                  icon: Icons.supervised_user_circle,
                  title: 'Usuarios',
                  subtitle: 'Administrar usuarios del sistema',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate('/usuarios');
                  },
                ),
                const SizedBox(height: 16),
                _buildOption(
                  context,
                  icon: Icons.person,
                  title: 'Perfil',
                  subtitle: 'Ver y editar perfil',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate('/profile');
                  },
                ),
                const SizedBox(height: 16),
                _buildOption(
                  context,
                  icon: Icons.settings,
                  title: 'Configuración',
                  subtitle: 'Ajustes de la aplicación',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate('/settings');
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.tealAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
