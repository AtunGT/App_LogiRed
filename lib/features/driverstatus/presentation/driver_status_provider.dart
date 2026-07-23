import 'package:flutter/material.dart';
import '../../../core/local/token_manager.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/model/models.dart';
import '../../../core/state/view_state.dart';
import '../../../core/utils/driver_status.dart';

class DriverStatusProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;
  final TokenManager _tokens;

  DriverStatusProvider(this._api, this._tokens);

  String driverStatus = DriverStatus.fallback;
  String? rejectReason;

  bool get isResolving => isInitial || (isLoading && !_resolvedOnce);
  bool _resolvedOnce = false;

  bool get canDrive => DriverStatus.canDrive(driverStatus);

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

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
      error = 'No pudimos verificar el estado de tu cuenta';
    }
  }

  Future<void> logout() async {
    await _tokens.clearData();
  }
}
