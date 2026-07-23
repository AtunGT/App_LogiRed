import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../core/local/token_manager.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/model/login_result.dart';
import '../../domain/repository/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final ApiService _api;
  final TokenManager _tokens;

  LoginRepositoryImpl(this._api, this._tokens);

  @override
  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await _api.login(
        LoginRequest(email: email, password: password).toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg =
            response.data['message']?.toString() ?? 'Credenciales incorrectas';
        return LoginError(message: msg);
      }

      final authHeader = response.headers.value('Authorization') ?? '';
      final token = authHeader.startsWith('Bearer ')
          ? authHeader.substring(7)
          : authHeader;

      if (token.isEmpty) {
        return LoginError(message: 'No se recibió token del servidor');
      }
      final decoded = JwtDecoder.decode(token);
      final userType = decoded['usertype'] ?? 1;
      final userId = decoded['iduser'] ?? 0;
      final cityWork = decoded['citywork'] ?? '';

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.reload();
      final freshUser = FirebaseAuth.instance.currentUser;

      if (freshUser?.emailVerified == false) {
        await FirebaseAuth.instance.signOut();
        return LoginError(
            message:
                'Debes verificar tu correo antes de iniciar sesión. Revisa tu bandeja de entrada.');
      }

      await _tokens.saveAuthData(
        token: token,
        userType: userType,
        userId: userId,
        cityWork: cityWork,
      );

      await NotificationService.registerDeviceToken();
      return LoginSuccess(userType: userType, token: token);
    } on DioException catch (e) {
      // Sin respuesta del servidor = problema de red real.
      if (e.response == null) {
        return LoginError(message: 'Conéctate a internet e intenta de nuevo');
      }
      final code = e.response!.statusCode;
      if (code == 401 || code == 400) {
        return LoginError(message: 'Correo o contraseña incorrectos');
      }
      return LoginError(
          message: 'El servidor no está disponible. Intenta más tarde');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        return LoginError(message: 'Conéctate a internet e intenta de nuevo');
      }
      if (e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS') {
        return LoginError(message: 'Correo o contraseña incorrectos');
      }
      return LoginError(message: 'Error de autenticación. Intenta de nuevo');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') ||
          msg.contains('socket') ||
          msg.contains('connection')) {
        return LoginError(message: 'Conéctate a internet e intenta de nuevo');
      }
      return LoginError(message: 'Ocurrió un error. Intenta de nuevo');
    }
  }

  @override
  Future<LoginResult> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(
        serverClientId:
            '985546482165-t8c3ij9kauh202eb97lfkioporjkh4bo.apps.googleusercontent.com',
      ).signIn();
      if (googleUser == null) return LoginError(message: 'Inicio cancelado');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken() ?? '';

      final response = await _api.loginWithGoogle(idToken);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg = response.data['message']?.toString() ??
            'Error al iniciar sesión con Google';
        return LoginError(message: msg);
      }

      final authHeader = response.headers.value('Authorization') ?? '';
      final token = authHeader.startsWith('Bearer ')
          ? authHeader.substring(7)
          : authHeader;

      if (token.isEmpty) {
        return LoginError(message: 'No se recibió token del servidor');
      }

      final decoded = JwtDecoder.decode(token);
      final userType = decoded['usertype'] ?? 1;
      final userId = decoded['iduser'] ?? 0;
      final cityWork = decoded['citywork'] ?? '';

      await _tokens.saveAuthData(
        token: token,
        userType: userType,
        userId: userId,
        cityWork: cityWork,
      );

      await NotificationService.registerDeviceToken();
      return LoginSuccess(userType: userType, token: token);
    } on DioException catch (e) {
      if (e.response == null) {
        return LoginError(message: 'Conéctate a internet e intenta de nuevo');
      }
      if (e.response!.statusCode == 404) {
        return LoginError(
            message:
                'Esta cuenta de Google no está registrada. Crea una cuenta primero');
      }
      return LoginError(
          message: 'El servidor no está disponible. Intenta más tarde');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        return LoginError(message: 'Conéctate a internet e intenta de nuevo');
      }
      return LoginError(message: 'Error de autenticación. Intenta de nuevo');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') ||
          msg.contains('socket') ||
          msg.contains('connection')) {
        return LoginError(message: 'Conéctate a internet e intenta de nuevo');
      }
      return LoginError(message: 'Ocurrió un error. Intenta de nuevo');
    }
  }
}
