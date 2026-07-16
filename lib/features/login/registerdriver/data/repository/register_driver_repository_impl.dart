import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/di/service_locator.dart';
import '../../domain/model/driver_data.dart';
import '../../domain/repository/register_driver_repository.dart';

class RegisterDriverRepositoryImpl implements RegisterDriverRepository {
  @override
  Future<void> register(DriverData data) async {
    final map = <String, dynamic>{
      'user_type': '2',
      'name': data.name,
      'lastname': data.lastname,
      'email': data.email,
      'numberphone': data.phone,
      'birthdate': data.birthdate,
      'password': data.password,
      'car_registration': data.plate,
      'brand': data.brand,
      'model': '${data.vehicleModel} ${data.year}'.trim(),
      'color': data.color,
      'max_capacity': data.maxCapacity,
      'document_identificacion_adelante': await MultipartFile.fromFile(
          data.docIdFront,
          filename: 'id_front.jpg'),
      'document_identificacion_atras':
          await MultipartFile.fromFile(data.docIdBack, filename: 'id_back.jpg'),
      'document_licencia': await MultipartFile.fromFile(data.docLicense,
          filename: 'license.jpg'),
      'frontview_image': await MultipartFile.fromFile(data.imgVehicleFront,
          filename: 'vehicle_front.jpg'),
      'backview_image': await MultipartFile.fromFile(data.imgVehicleFront,
          filename: 'vehicle_front2.jpg'),
      'leftview_image': await MultipartFile.fromFile(data.imgVehicleSide,
          filename: 'vehicle_side.jpg'),
      'rightview_image': await MultipartFile.fromFile(data.imgVehicleSide,
          filename: 'vehicle_side2.jpg'),
      'space_image': await MultipartFile.fromFile(data.imgCargoSpace,
          filename: 'cargo_space.jpg'),
      'plates_image': await MultipartFile.fromFile(data.imgVehiclePlate,
          filename: 'vehicle_plate.jpg'),
    };

    if (data.profileImagePath != null) {
      map['image'] = await MultipartFile.fromFile(data.profileImagePath!,
          filename: 'profile.jpg');
    }
    if (data.docAddressProof != null) {
      map['document_comprobante_domicilio'] = await MultipartFile.fromFile(
          data.docAddressProof!,
          filename: 'address_proof.jpg');
    }

    final formData = FormData.fromMap(map);

    try {
      final response = await sl.apiService.createUser(formData);
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
      throw Exception(_translateFirebaseError(e.code));
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

  String _translateFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres)';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo';
      default:
        return 'Error de autenticación. Intenta de nuevo';
    }
  }
}
