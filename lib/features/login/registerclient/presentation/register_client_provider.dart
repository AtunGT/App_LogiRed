import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/state/view_state.dart';
import '../domain/model/client_data.dart';
import '../domain/repository/register_client_repository.dart';
import '../domain/usecase/register_client_usecase.dart';

class RegisterClientProvider extends ChangeNotifier with ViewStateMixin {
  final RegisterClientRepository _repo;
  late final RegisterClientUseCase _useCase = RegisterClientUseCase(_repo);

  RegisterClientProvider(this._repo);

  String name = '';
  String lastname = '';
  String email = '';
  String numberPhone = '';
  String birthdate = '';
  String password = '';
  String confirmPassword = '';
  String? imagePath;
  bool registerSuccess = false;
  bool acceptedTerms = false;
  bool acceptedPrivacy = false;

  void toggleTerms() {
    acceptedTerms = !acceptedTerms;
    notifyListeners();
  }

  void togglePrivacy() {
    acceptedPrivacy = !acceptedPrivacy;
    notifyListeners();
  }

  final Map<String, String?> fieldErrors = {
    'photo': null,
    'name': null,
    'lastname': null,
    'email': null,
    'phone': null,
    'birthdate': null,
    'password': null,
    'confirm': null,
  };

  static bool _validPassword(String p) =>
      p.length >= 8 &&
      p.contains(RegExp(r'[A-Z]')) &&
      p.contains(RegExp(r'[0-9]')) &&
      p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));

  static const _validDomains = {
    'gmail.com',
    'googlemail.com',
    'yahoo.com',
    'yahoo.com.mx',
    'yahoo.es',
    'outlook.com',
    'outlook.es',
    'hotmail.com',
    'hotmail.es',
    'hotmail.com.mx',
    'live.com',
    'live.com.mx',
    'icloud.com',
    'me.com',
    'msn.com',
    'aol.com',
    'protonmail.com',
    'proton.me',
    'mail.com',
    'zoho.com',
  };

  static bool _validEmail(String e) {
    final v = e.trim().toLowerCase();
    if (!RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(v)) {
      return false;
    }
    return _validDomains.contains(v.split('@').last);
  }

  void onNameChange(String v) {
    name = v;
    fieldErrors['name'] = null;
    notifyListeners();
  }

  void onLastnameChange(String v) {
    lastname = v;
    fieldErrors['lastname'] = null;
    notifyListeners();
  }

  void onEmailChange(String v) {
    email = v;
    fieldErrors['email'] = null;
    notifyListeners();
  }

  void onPhoneChange(String v) {
    numberPhone = v;
    fieldErrors['phone'] = null;
    notifyListeners();
  }

  void onBirthdateChange(String v) {
    birthdate = v;
    fieldErrors['birthdate'] = null;
    notifyListeners();
  }

  void onPasswordChange(String v) {
    password = v;
    fieldErrors['password'] = null;
    notifyListeners();
  }

  void onConfirmPasswordChange(String v) {
    confirmPassword = v;
    fieldErrors['confirm'] = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      error = 'Se necesita permiso de cámara para tomar la foto';
      notifyListeners();
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked != null) {
      imagePath = picked.path;
      fieldErrors['photo'] = null;
      error = null;
      notifyListeners();
    }
  }

  bool _validateFields() {
    bool ok = true;
    if (imagePath == null) {
      fieldErrors['photo'] = 'La foto de perfil es obligatoria';
      ok = false;
    }
    if (name.trim().isEmpty) {
      fieldErrors['name'] = 'Requerido';
      ok = false;
    }
    if (lastname.trim().isEmpty) {
      fieldErrors['lastname'] = 'Requerido';
      ok = false;
    }
    if (!_validEmail(email)) {
      fieldErrors['email'] =
          'Usa un correo de Gmail, Outlook, Hotmail, Yahoo u otro proveedor conocido';
      ok = false;
    }
    if (numberPhone.trim().length != 10) {
      fieldErrors['phone'] = '10 dígitos requeridos';
      ok = false;
    }
    if (birthdate.trim().isEmpty) {
      fieldErrors['birthdate'] = 'Requerido';
      ok = false;
    }
    if (!_validPassword(password)) {
      fieldErrors['password'] =
          'Mín. 8 caracteres, 1 mayúscula, 1 número y 1 carácter especial';
      ok = false;
    }
    if (confirmPassword != password) {
      fieldErrors['confirm'] = 'No coincide con la contraseña';
      ok = false;
    }
    if (!acceptedTerms || !acceptedPrivacy) {
      error =
          'Debes aceptar los términos y condiciones y la política de privacidad';
      ok = false;
    }
    notifyListeners();
    return ok;
  }

  Future<void> register() async {
    if (!_validateFields()) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _useCase(ClientData(
        name: name,
        lastname: lastname,
        email: email,
        numberPhone: numberPhone,
        birthdate: birthdate,
        password: password,
        imagePath: imagePath,
      ));
      registerSuccess = true;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      debugPrint('REGISTER ERROR: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
