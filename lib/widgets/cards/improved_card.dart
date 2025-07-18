import 'package:flutter/material.dart';

class ImprovedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isHoverable;

  const ImprovedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
    this.isHoverable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return Container(
      margin: margin ?? EdgeInsets.all(isMobile ? 8 : 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: padding ?? EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withOpacity(0.15),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border:
                  border ??
                  Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              boxShadow:
                  boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final String clientName;
  final String age;
  final String? photoUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PatientCard({
    super.key,
    required this.patientData,
    required this.clientName,
    required this.age,
    this.photoUrl,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return ImprovedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con foto y nombre
          Row(
            children: [
              // Foto del paciente
              Container(
                width: isMobile ? 60 : 70,
                height: isMobile ? 60 : 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.teal.withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: photoUrl != null && photoUrl!.isNotEmpty
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              const SizedBox(width: 16),

              // Información básica
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientData['nombre'] ?? 'Sin nombre',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildInfoChip(
                      icon: Icons.category,
                      text: patientData['especie'] ?? 'N/A',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Información detallada
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.pets,
                text: patientData['raza'] ?? 'N/A',
                color: Colors.green,
              ),
              _buildInfoChip(icon: Icons.cake, text: age, color: Colors.orange),
            ],
          ),

          const SizedBox(height: 12),

          // Información del cliente
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.tealAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dueño: $clientName',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                label: 'Editar',
                color: Colors.orange,
                onPressed: onEdit,
              ),
              _buildActionButton(
                icon: Icons.delete,
                label: 'Eliminar',
                color: Colors.red,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.pets, color: Colors.tealAccent, size: 32),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointmentData;
  final Map<String, String> relatedData;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onStatusChange;

  const AppointmentCard({
    super.key,
    required this.appointmentData,
    required this.relatedData,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;
    final status = appointmentData['estado'] ?? 'Pendiente';
    final statusColor = _getStatusColor(status);

    return ImprovedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con fecha y estado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.tealAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${appointmentData['fecha']} - ${appointmentData['hora']}',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Información de la cita
          _buildInfoRow(
            icon: Icons.pets,
            label: 'Paciente',
            value: relatedData['paciente'] ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.person,
            label: 'Cliente',
            value: relatedData['cliente'] ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.medical_services,
            label: 'Doctor',
            value: relatedData['doctor'] ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.description,
            label: 'Motivo',
            value: appointmentData['motivo'] ?? 'N/A',
          ),

          const SizedBox(height: 16),

          // Acciones
          Row(
            children: [
              // Cambiar estado
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: status,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: Colors.black87,
                    style: const TextStyle(color: Colors.white),
                    items: ['Pendiente', 'Confirmada', 'Cancelada']
                        .map(
                          (estado) => DropdownMenuItem(
                            value: estado,
                            child: Text(estado),
                          ),
                        )
                        .toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null && onStatusChange != null) {
                        onStatusChange!(newStatus);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.orange,
                onPressed: onEdit,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete,
                color: Colors.red,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.tealAccent, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmada':
        return Colors.green;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
