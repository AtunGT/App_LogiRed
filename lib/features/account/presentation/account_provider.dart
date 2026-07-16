import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/model/models.dart';

class AccountProvider extends ChangeNotifier {
  UserResponse? user;
  bool isLoading = false;
  String? error;

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
      final res = await sl.apiService.getMe();
      user = UserResponse.fromJson(res.data);
      error = null;
    } catch (_) {
      error = 'Error al cargar el perfil';
    }
  }

  Future<void> logout() async {
    await sl.tokenManager.clearData();
  }
}
