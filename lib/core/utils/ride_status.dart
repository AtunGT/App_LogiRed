class RideStatus {
  const RideStatus._();

  static const int assigned = 1;
  static const int onTheWay = 2;
  static const int inProcess = 3;
  static const int cancelled = 4;
  static const int completed = 5;
  static const int pending = 6;
  static const int atOrigin = 7;

  static bool isInCourse(int? s) =>
      s == onTheWay || s == inProcess || s == atOrigin;

  static bool isClosed(int? s) => s == completed || s == cancelled;

  static const Map<int, String> _labels = {
    assigned: 'Asignado',
    onTheWay: 'En camino',
    inProcess: 'En proceso',
    cancelled: 'Cancelado',
    completed: 'Completado',
    pending: 'Pendiente',
    atOrigin: 'En el origen',
  };

  static String label(int? s) => _labels[s] ?? '—';
}
