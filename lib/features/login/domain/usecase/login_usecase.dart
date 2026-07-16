import '../model/login_result.dart';
import '../repository/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;
  LoginUseCase(this.repository);

  Future<LoginResult> call(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return Future.value(LoginError(message: 'Completa todos los campos'));
    }
    return repository.login(email, password);
  }
}
