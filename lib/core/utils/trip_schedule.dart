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

  /// true cuando la fecha+hora programada ya quedó estrictamente en el pasado.
  /// Si no se puede parsear la fecha se considera NO vencido, para no cancelar
  /// por error un viaje con datos ilegibles.
  static bool isPast(String date, String hour) {
    final at = scheduledAt(date, hour);
    return at != null && DateTime.now().isAfter(at);
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
