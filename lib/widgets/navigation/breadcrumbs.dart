import 'package:flutter/material.dart';

class Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final bool showBackButton;

  const Breadcrumbs({
    super.key,
    required this.items,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      child: Row(
        children: [
          // Back button para móvil
          if (showBackButton && isMobile) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Breadcrumb items
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _buildBreadcrumbItems(context, isMobile)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(BuildContext context, bool isMobile) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      // Breadcrumb item
      widgets.add(_buildBreadcrumbItem(context, item, isLast, isMobile));

      // Separator
      if (!isLast) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: isMobile ? 16 : 18,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    BreadcrumbItem item,
    bool isLast,
    bool isMobile,
  ) {
    final textStyle = TextStyle(
      color: isLast ? Colors.white : Colors.white.withOpacity(0.7),
      fontSize: isMobile ? 14 : 16,
      fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
    );

    if (item.onTap != null && !isLast) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: item.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    color: Colors.white.withOpacity(0.7),
                    size: isMobile ? 16 : 18,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(item.title, style: textStyle),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              color: isLast ? Colors.tealAccent : Colors.white.withOpacity(0.7),
              size: isMobile ? 16 : 18,
            ),
            const SizedBox(width: 6),
          ],
          Text(item.title, style: textStyle),
        ],
      ),
    );
  }
}

class BreadcrumbItem {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;

  BreadcrumbItem({required this.title, this.icon, this.onTap});
}

// Helper class para generar breadcrumbs comunes
class BreadcrumbHelper {
  static List<BreadcrumbItem> forHome() {
    return [BreadcrumbItem(title: 'Dashboard', icon: Icons.dashboard)];
  }

  static List<BreadcrumbItem> forCitas({VoidCallback? onHomeTap}) {
    return [
      BreadcrumbItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        onTap: onHomeTap,
      ),
      BreadcrumbItem(title: 'Citas', icon: Icons.calendar_today),
    ];
  }

  static List<BreadcrumbItem> forPacientes({VoidCallback? onHomeTap}) {
    return [
      BreadcrumbItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        onTap: onHomeTap,
      ),
      BreadcrumbItem(title: 'Pacientes', icon: Icons.pets),
    ];
  }

  static List<BreadcrumbItem> forDoctores({VoidCallback? onHomeTap}) {
    return [
      BreadcrumbItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        onTap: onHomeTap,
      ),
      BreadcrumbItem(title: 'Doctores', icon: Icons.medical_services),
    ];
  }

  static List<BreadcrumbItem> forClientes({VoidCallback? onHomeTap}) {
    return [
      BreadcrumbItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        onTap: onHomeTap,
      ),
      BreadcrumbItem(title: 'Clientes', icon: Icons.people),
    ];
  }

  static List<BreadcrumbItem> forUsuarios({VoidCallback? onHomeTap}) {
    return [
      BreadcrumbItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        onTap: onHomeTap,
      ),
      BreadcrumbItem(title: 'Usuarios', icon: Icons.supervised_user_circle),
    ];
  }

  static List<BreadcrumbItem> forAgregar({
    required String section,
    required IconData sectionIcon,
    VoidCallback? onHomeTap,
    VoidCallback? onSectionTap,
  }) {
    return [
      BreadcrumbItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        onTap: onHomeTap,
      ),
      BreadcrumbItem(title: section, icon: sectionIcon, onTap: onSectionTap),
      BreadcrumbItem(title: 'Agregar', icon: Icons.add),
    ];
  }

  static List<BreadcrumbItem> forEditar({
    required String section,
    required IconData sectionIcon,
    required String itemName,
    VoidCallback? onHomeTap,
    VoidCallback? onSectionTap,
  }) {
    return [
      BreadcrumbItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        onTap: onHomeTap,
      ),
      BreadcrumbItem(title: section, icon: sectionIcon, onTap: onSectionTap),
      BreadcrumbItem(title: 'Editar: $itemName', icon: Icons.edit),
    ];
  }
}
