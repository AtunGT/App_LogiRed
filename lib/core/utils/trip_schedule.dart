class TripSchedule {
  static DateTime? scheduledAt(String date, String hour) {
    try {
      final datePart = date.split('T').first;
      final d = datePart.split('-');
      if (d.length < 3) return null;
      final year = int.parse(d[0]);
      final month = int.parse(d[1]);
      final day = int.parse(d[2]);

      int h = 0, min = 0;
      final timeRaw = hour.contains('T') ? hour.split('T').last : hour;
      final t = timeRaw.replaceAll('Z', '').split(':');
      if (t.length >= 2) {
        h = int.parse(t[0]);
        min = int.parse(t[1]);
      }
      return DateTime(year, month, day, h, min);
    } catch (_) {
      return null;
    }
  }

  static bool canStart(String date, String hour) {
    final at = scheduledAt(date, hour);
    if (at == null) return true;
    return !DateTime.now().isBefore(at);
  }

  static bool isPast(String date, String hour) {
    final at = scheduledAt(date, hour);
    return at != null && DateTime.now().isAfter(at);
  }

  /// Margen de gracia tras la hora programada antes de dar un viaje
  /// por expirado (debe coincidir con el job de expiración de la API).
  static const expirationGrace = Duration(minutes: 30);

  /// Un viaje sin conductor se considera expirado cuando ya pasó su
  /// hora programada más [expirationGrace].
  static bool isExpired(String date, String hour) {
    final at = scheduledAt(date, hour);
    return at != null && DateTime.now().isAfter(at.add(expirationGrace));
  }

  static const _months = [
    '',
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static String label(String date, String hour) {
    final at = scheduledAt(date, hour);
    if (at == null) return '';
    final hh = at.hour.toString().padLeft(2, '0');
    final mm = at.minute.toString().padLeft(2, '0');
    return '${at.day} ${_months[at.month]} · $hh:$mm';
  }
}
