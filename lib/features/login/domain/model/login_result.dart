abstract class LoginResult {}

class LoginSuccess extends LoginResult {
  final int userType;
  final String token;
  LoginSuccess({required this.userType, required this.token});
}

class LoginError extends LoginResult {
  final String message;
  LoginError({required this.message});
}
