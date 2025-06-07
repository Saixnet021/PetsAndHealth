class Cita {
  final String id;
  final String fecha;
  final String hora;
  final String motivo;
  final String clienteId;
  final String veterinarioId;
  final String mascota;

  Cita({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.motivo,
    required this.clienteId,
    required this.veterinarioId,
    required this.mascota,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
      'clienteId': clienteId,
      'veterinarioId': veterinarioId,
      'mascota': mascota,
    };
  }

  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id'] ?? '',
      fecha: map['fecha'] ?? '',
      hora: map['hora'] ?? '',
      motivo: map['motivo'] ?? '',
      clienteId: map['clienteId'] ?? '',
      veterinarioId: map['veterinarioId'] ?? '',
      mascota: map['mascota'] ?? '',
    );
  }
}
