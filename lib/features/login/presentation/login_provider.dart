import 'package:flutter/material.dart';
import '../../../core/state/view_state.dart';
import '../domain/model/login_result.dart';
import '../domain/repository/login_repository.dart';
import '../domain/usecase/login_usecase.dart';

class LoginProvider extends ChangeNotifier with ViewStateMixin {
  final LoginRepository _repo;
  late final LoginUseCase _useCase = LoginUseCase(_repo);

  LoginProvider(this._repo);

  String email = '';
  String password = '';
  bool isGoogleLoading = false;
  LoginResult? result;

  void onEmailChange(String val) {
    email = val;
    error = null;
    notifyListeners();
  }

  void onPasswordChange(String val) {
    password = val;
    error = null;
    notifyListeners();
  }

  Future<void> login() async {
    isLoading = true;
    error = null;
    notifyListeners();

    result = await _useCase(email, password);

    if (result is LoginError) {
      error = (result as LoginError).message;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    isGoogleLoading = true;
    error = null;
    notifyListeners();

    result = await _repo.loginWithGoogle();

    if (result is LoginError) {
      error = (result as LoginError).message;
    }

    isGoogleLoading = false;
    notifyListeners();
  }
}
