import 'package:flutter/foundation.dart';

/// Estado formal de carga de un provider.
enum ViewStatus { initial, loading, success, error }

/// Estado de carga estándar de los providers.
///
/// Expone [status] como estado formal y mantiene [isLoading] y [error] con la
/// misma semántica que los antiguos campos sueltos (`bool isLoading` /
/// `String? error`), de modo que las pantallas y la lógica existente no
/// cambian de comportamiento.
///
/// Reglas de transición:
/// - `isLoading = true` pasa a [ViewStatus.loading]. No limpia [error]; los
///   providers lo limpian explícitamente con `error = null`, igual que antes.
/// - `isLoading = false` resuelve la carga: [ViewStatus.error] si quedó un
///   mensaje en [error], [ViewStatus.success] si no. Fuera de una carga no
///   cambia nada (p. ej. un return temprano).
/// - Asignar [error] durante una carga solo guarda el mensaje; el estado se
///   resuelve al terminar. Fuera de una carga (validaciones) pasa directo a
///   [ViewStatus.error], y limpiarlo con `null` vuelve a [ViewStatus.success].
mixin ViewStateMixin on ChangeNotifier {
  ViewStatus _status = ViewStatus.initial;
  String? _error;

  ViewStatus get status => _status;
  bool get isInitial => _status == ViewStatus.initial;
  bool get isSuccess => _status == ViewStatus.success;
  bool get hasError => _status == ViewStatus.error;

  bool get isLoading => _status == ViewStatus.loading;
  set isLoading(bool value) {
    if (value) {
      _status = ViewStatus.loading;
    } else if (_status == ViewStatus.loading) {
      _status = _error == null ? ViewStatus.success : ViewStatus.error;
    }
  }

  String? get error => _error;
  set error(String? value) {
    _error = value;
    if (_status == ViewStatus.loading) return;
    if (value != null) {
      _status = ViewStatus.error;
    } else if (_status == ViewStatus.error) {
      _status = ViewStatus.success;
    }
  }
}
