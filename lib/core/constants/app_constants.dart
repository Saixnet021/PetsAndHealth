class AppConstants {
  // API URLs
  static const String dniApiUrl = 'https://backend-dni.vercel.app/dni';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String clientesCollection = 'clientes';
  static const String pacientesCollection = 'pacientes';
  static const String doctoresCollection = 'doctores';
  static const String citasCollection = 'citas';
  static const String historialesCollection = 'historiales_medicos';
  static const String facturasCollection = 'facturas';
  static const String notificacionesCollection = 'notificaciones';
  
  // User Roles
  static const String adminRole = 'administrador';
  static const String veterinarioRole = 'veterinario';
  static const String clienteRole = 'cliente';
  
  // App Settings
  static const String appName = 'Pets & Health';
  static const String appVersion = '2.0.0';
  
  // Validation
  static const int dniLength = 8;
  static const int phoneMinLength = 9;
  static const int passwordMinLength = 6;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Image Settings
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
