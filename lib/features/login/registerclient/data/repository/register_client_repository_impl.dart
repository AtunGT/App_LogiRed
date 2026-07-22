import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_service.dart';
import '../../domain/model/client_data.dart';
import '../../domain/repository/register_client_repository.dart';

class RegisterClientRepositoryImpl implements RegisterClientRepository {
  final ApiService _api;

  RegisterClientRepositoryImpl(this._api);

  @override
  Future<void> register(ClientData data) async {
    final formData = FormData.fromMap({
      'user_type': '1',
      'name': data.name,
      'lastname': data.lastname,
      'email': data.email,
      'numberphone': data.numberPhone,
      'birthdate': data.birthdate,
      'password': data.password,
      if (data.imagePath != null)
        'image': await MultipartFile.fromFile(data.imagePath!,
            filename: 'profile.jpg'),
    });

    try {
      final response = await _api.createUser(formData);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg = _extractMessage(response.data);
        debugPrint('API ERROR ${response.statusCode}: ${response.data}');
        throw Exception(_translateApiError(msg, code: response.statusCode));
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = _extractMessage(e.response?.data);
      debugPrint('DIO ERROR $code: ${e.response?.data}');
      throw Exception(_translateApiError(msg, code: code));
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.email,
        password: data.password,
      );
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(_translateFirebaseError(e.code, e.message));
    } catch (e) {
      throw Exception('Error inesperado: ${e.runtimeType} - $e');
    }
  }

  String _extractMessage(dynamic data) {
    if (data == null) return '';
    if (data is Map) return data['message']?.toString() ?? data.toString();
    return data.toString();
  }

  String _translateApiError(String msg, {int? code}) {
    final lower = msg.toLowerCase();
    final suffix = code != null ? ' [Error $code]' : '';
    if (lower.contains('phone') ||
        lower.contains('telefono') ||
        lower.contains('número')) {
      return 'El número de teléfono ya está registrado';
    }
    if (lower.contains('email') || lower.contains('correo')) {
      return 'El correo electrónico ya está registrado';
    }
    if (msg.isNotEmpty) return '$msg$suffix';
    return 'Error al registrar$suffix. Intenta de nuevo';
  }

  String _translateFirebaseError(String code, [String? message]) {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres)';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red';
      case 'operation-not-allowed':
        return 'El registro con correo no está habilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo';
      default:
        return 'Firebase [$code]: ${message ?? 'sin detalle'}';
    }
  }
}
