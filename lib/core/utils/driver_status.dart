class DriverStatus {
  const DriverStatus._();

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String blocked = 'blocked';

  static const String fallback = approved;

  static const Set<String> _known = {pending, approved, rejected, blocked};

  static String parse(Object? raw) {
    final v = raw?.toString().trim().toLowerCase();
    if (v == null || v.isEmpty) return fallback;
    return _known.contains(v) ? v : fallback;
  }

  static bool canDrive(String? s) => s == approved;

  static bool canReapply(String? s) => s == rejected;

  static const Map<String, String> _labels = {
    pending: 'En revision',
    approved: 'Aprobado',
    rejected: 'Rechazado',
    blocked: 'Bloqueado',
  };

  static String label(String? s) => _labels[s] ?? '—';
}
