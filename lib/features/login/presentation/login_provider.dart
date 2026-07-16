import 'package:flutter/material.dart';
import '../data/repository/login_repository_impl.dart';
import '../domain/model/login_result.dart';
import '../domain/usecase/login_usecase.dart';

class LoginProvider extends ChangeNotifier {
  final _repo = LoginRepositoryImpl();
  late final _useCase = LoginUseCase(_repo);

  String email = '';
  String password = '';
  bool isLoading = false;
  bool isGoogleLoading = false;
  String? error;
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
