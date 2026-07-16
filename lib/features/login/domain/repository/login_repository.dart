import '../model/login_result.dart';

abstract class LoginRepository {
  Future<LoginResult> login(String email, String password);
}
