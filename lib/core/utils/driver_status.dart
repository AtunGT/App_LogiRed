/// Estado de validacion de un conductor, tal como llega en `driver_status`
/// dentro de `GET /users/me`.
///
/// El JWT no sirve para esto: su claim `approved` se queda en `false` tanto
/// para rechazados como para bloqueados, asi que el perfil es el unico origen
/// que distingue los cuatro casos.
class DriverStatus {
  const DriverStatus._();

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String blocked = 'blocked';

  /// Valor asumido cuando el backend no manda `driver_status`.
  ///
  /// Se asume aprobado a proposito. Mientras el campo no este desplegado en
  /// produccion, tratar la ausencia como `pending` dejaria a toda la flota
  /// fuera del mapa en cuanto se publique la app, aunque tengan sus documentos
  /// en regla. El gate real lo hace el backend; esta pantalla solo informa.
  static const String fallback = approved;

  static const Set<String> _known = {pending, approved, rejected, blocked};

  /// Normaliza el valor crudo del JSON.
  ///
  /// Un estado desconocido (uno nuevo que esta version de la app todavia no
  /// maneja) cae en [fallback] por la misma razon que la ausencia: es
  /// preferible dejar pasar y que la API rechace la operacion, a encerrar a un
  /// conductor legitimo en una pantalla sin salida.
  static String parse(Object? raw) {
    final v = raw?.toString().trim().toLowerCase();
    if (v == null || v.isEmpty) return fallback;
    return _known.contains(v) ? v : fallback;
  }

  /// Unico estado que da acceso al mapa y a recibir viajes.
  static bool canDrive(String? s) => s == approved;

  /// Solo el rechazado puede volver a postularse. El bloqueado no: unicamente
  /// administracion puede desbloquearlo desde el panel web.
  static bool canReapply(String? s) => s == rejected;

  static const Map<String, String> _labels = {
    pending: 'En revision',
    approved: 'Aprobado',
    rejected: 'Rechazado',
    blocked: 'Bloqueado',
  };

  static String label(String? s) => _labels[s] ?? '—';
}
