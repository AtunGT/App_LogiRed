import 'package:flutter/material.dart';
import '../../../core/local/token_manager.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/model/models.dart';
import '../../../core/state/view_state.dart';

class AccountProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;
  final TokenManager _tokens;

  AccountProvider(this._api, this._tokens);

  UserResponse? user;

  String get displayName =>
      user != null ? '${user!.name} ${user!.lastname}'.trim() : '';
  String get email => user?.email ?? '';
  String get initial =>
      user != null && user!.name.isNotEmpty ? user!.name[0].toUpperCase() : '?';

  Future<void> loadUser() async {
    isLoading = true;
    error = null;
    notifyListeners();

    await _fetch();

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _fetch();
    notifyListeners();
  }

  Future<void> _fetch() async {
    try {
      final res = await _api.getMe();
      user = UserResponse.fromJson(res.data);
      error = null;
    } catch (_) {
      error = 'Error al cargar el perfil';
    }
  }

  Future<void> logout() async {
    await _tokens.clearData();
  }
}
