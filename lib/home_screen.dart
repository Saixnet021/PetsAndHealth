import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:petsandhealth/screens/Citas/citas_screen.dart';
import 'package:petsandhealth/screens/Clientes/clientes_screen.dart';
import 'package:petsandhealth/screens/Doctores/doctores_screen.dart';
import 'package:petsandhealth/screens/Pacientes/pacientes_screen.dart';
import 'package:petsandhealth/profile_screen.dart';
import 'package:petsandhealth/usuarios_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petsandhealth/widgets/navigation/app_sidebar.dart';
import 'package:petsandhealth/widgets/navigation/mobile_bottom_nav.dart';
import 'package:petsandhealth/widgets/navigation/breadcrumbs.dart';
import 'package:petsandhealth/widgets/dashboard/dashboard_widgets.dart';
import 'package:petsandhealth/widgets/responsive/responsive_layout.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simular carga inicial
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;

    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
      bottomNavigationBar: MobileBottomNav(
        currentRoute: '/home',
        userRole: widget.role,
        onNavigate: _handleNavigation,
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Column(
            children: [
              // Breadcrumbs
              Breadcrumbs(
                items: BreadcrumbHelper.forHome(),
                showBackButton: false,
              ),

              // Dashboard Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _buildImprovedDashboard(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        AppSidebar(currentRoute: '/home', userRole: widget.role),

        // Main Content
        Expanded(
          child: Stack(
            children: [
              // Background
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
              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Header with user info
                    _buildDesktopHeader(),

                    // Breadcrumbs
                    Breadcrumbs(
                      items: BreadcrumbHelper.forHome(),
                      showBackButton: false,
                    ),

                    // Dashboard Content
                    Expanded(
                      child: _isLoading
                          ? _buildLoadingState()
                          : _buildImprovedDashboard(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Spacer(),

          // User Info
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Logout Button
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () => _logout(context),
              tooltip: 'Cerrar Sesión',
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(String route) {
    if (route == '/more') {
      _showMoreOptions();
      return;
    }

    switch (route) {
      case '/home':
        // Ya estamos en home
        break;
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

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MoreOptionsModal(
        userRole: widget.role,
        onNavigate: _handleNavigation,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.1,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImprovedDashboard() {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    '¡Bienvenido de vuelta!',
                    mobileFontSize: 24,
                    tabletFontSize: 28,
                    desktopFontSize: 32,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ResponsiveText(
                    'Panel de control - ${widget.role.toUpperCase()}',
                    mobileFontSize: 14,
                    tabletFontSize: 16,
                    desktopFontSize: 18,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),

            // Statistics Grid
            DashboardStatsGrid(userRole: widget.role),

            const SizedBox(height: 32),

            // Quick Actions and Recent Activity
            ResponsiveRow(
              children: [
                Expanded(child: QuickActionsWidget(userRole: widget.role)),
                if (ResponsiveBreakpoints.isDesktop(context)) ...[
                  const SizedBox(width: 24),
                  const Expanded(child: RecentActivityWidget()),
                ],
              ],
            ),

            if (!ResponsiveBreakpoints.isDesktop(context)) ...[
              const SizedBox(height: 24),
              const RecentActivityWidget(),
            ],

            const SizedBox(height: 32),

            // Module Navigation Grid
            _buildModuleGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid() {
    final dashboardItems = [
      DashboardItem(
        icon: Icons.calendar_today,
        title: 'Citas',
        color: const Color(0xFF3B82F6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitasScreen()),
        ),
      ),
      DashboardItem(
        icon: Icons.pets,
        title: 'Pacientes',
        color: const Color(0xFF10B981),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PacientesScreen()),
        ),
      ),
      DashboardItem(
        icon: Icons.medical_services,
        title: 'Doctores',
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctoresScreen()),
        ),
      ),
      DashboardItem(
        icon: Icons.people,
        title: 'Clientes',
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClientesScreen()),
        ),
      ),
      if (widget.role == 'administrador')
        DashboardItem(
          icon: Icons.supervised_user_circle,
          title: 'Usuarios',
          color: const Color(0xFFEF4444),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UsuariosScreen()),
          ),
        ),
    ];

    return ResponsiveGridView(
      children: dashboardItems
          .map(
            (item) => _buildDashboardTile(item, dashboardItems.indexOf(item)),
          )
          .toList(),
      childAspectRatio: 1.1,
      spacing: 20,
      runSpacing: 20,
    );
  }

  Widget _buildDashboard(bool isWeb) {
    final dashboardItems = [
      DashboardItem(
        icon: Icons.calendar_today,
        title: 'Citas',
        color: const Color(0xFF3B82F6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitasScreen()),
        ),
      ),
      DashboardItem(
        icon: Icons.pets,
        title: 'Pacientes',
        color: const Color(0xFF10B981),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PacientesScreen()),
        ),
      ),
      DashboardItem(
        icon: Icons.medical_services,
        title: 'Doctores',
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctoresScreen()),
        ),
      ),
      DashboardItem(
        icon: Icons.people,
        title: 'Clientes',
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClientesScreen()),
        ),
      ),
      if (widget.role == 'administrador')
        DashboardItem(
          icon: Icons.supervised_user_circle,
          title: 'Usuarios',
          color: const Color(0xFFEF4444),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UsuariosScreen()),
          ),
        ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF334155),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido de vuelta!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Panel de control - ${widget.role.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),

          // Dashboard Grid
          LayoutBuilder(
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
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                itemCount: dashboardItems.length,
                itemBuilder: (context, index) {
                  return _buildDashboardTile(dashboardItems[index], index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(DashboardItem item, int index) {
    return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: item.color,
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: item.onTap,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(item.icon, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 200 + (index * 100)),
          duration: 600.ms,
        )
        .slideY(begin: 0.3, end: 0)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
}

class DashboardItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  DashboardItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
