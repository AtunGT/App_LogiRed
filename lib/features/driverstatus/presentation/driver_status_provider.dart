import 'package:flutter/material.dart';
import '../../../core/local/token_manager.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/model/models.dart';
import '../../../core/state/view_state.dart';
import '../../../core/utils/driver_status.dart';

/// Resuelve en que estado de validacion esta el conductor consultando
/// `GET /users/me`, que es el unico origen que distingue rechazado de
/// bloqueado (el JWT deja `approved` en false para ambos).
class DriverStatusProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;
  final TokenManager _tokens;

  DriverStatusProvider(this._api, this._tokens);

  /// No se llama `status` para no chocar con el `status` de [ViewStateMixin],
  /// que representa el estado de la carga, no el del conductor.
  String driverStatus = DriverStatus.fallback;
  String? rejectReason;

  /// True mientras no se haya resuelto ninguna lectura, ni de red ni de cache.
  /// El gate lo usa para mostrar el spinner solo la primera vez.
  bool get isResolving => isInitial || (isLoading && !_resolvedOnce);
  bool _resolvedOnce = false;

  bool get canDrive => DriverStatus.canDrive(driverStatus);

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    // La cache se aplica primero para que un arranque sin red no devuelva al
    // mapa a alguien que ya estaba bloqueado.
    final cached = await _tokens.getDriverStatus();
    if (cached != null) {
      driverStatus = DriverStatus.parse(cached);
      rejectReason = await _tokens.getRejectReason();
      _resolvedOnce = true;
      notifyListeners();
    }

    await _fetch();

    isLoading = false;
    _resolvedOnce = true;
    notifyListeners();
  }

  /// Relectura silenciosa: no toca el spinner ni borra lo que ya se muestra.
  /// La dispara el push de cambio de estado y el "pull to refresh".
  Future<void> refresh() async {
    await _fetch();
    notifyListeners();
  }

  Future<void> _fetch() async {
    try {
      final res = await _api.getMe();
      final user = UserResponse.fromJson(res.data);
      driverStatus = user.driverStatus;
      rejectReason = user.rejectReason;
      await _tokens.saveDriverStatus(driverStatus, rejectReason);
      error = null;
    } catch (_) {
      // Se conserva el ultimo estado conocido a proposito: un fallo de red no
      // debe ni desbloquear ni bloquear a nadie.
      error = 'No pudimos verificar el estado de tu cuenta';
    }
  }

  Future<void> logout() async {
    await _tokens.clearData();
  }
}
