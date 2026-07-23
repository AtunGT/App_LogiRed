import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/state/view_state.dart';
import '../domain/model/driver_data.dart';
import '../domain/repository/register_driver_repository.dart';
import '../domain/usecase/register_driver_usecase.dart';

class RegisterDriverProvider extends ChangeNotifier with ViewStateMixin {
  final RegisterDriverRepository _repo;
  late final RegisterDriverUseCase _useCase = RegisterDriverUseCase(_repo);
  final _picker = ImagePicker();

  RegisterDriverProvider(this._repo);

  int currentStep = 0;

  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String birthdate = '';
  String password = '';
  String confirmPassword = '';

  String? profileImagePath;

  String? docId;
  String? docLicense;
  String? docAddressProof;

  String brand = '';
  String vehicleModel = '';
  String year = '';
  String color = '';
  String plate = '';
  String maxCapacity = '';
  String? imgVehicleFront;
  String? imgVehicleBack;
  String? imgVehicleLeft;
  String? imgVehicleRight;
  String? imgCargoSpace;
  String? imgVehiclePlate;

  bool registerSuccess = false;
  String registeredEmail = '';
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

  int get vehiclePhotosCount => [
        imgVehicleFront,
        imgVehicleBack,
        imgVehicleLeft,
        imgVehicleRight,
        imgCargoSpace,
        imgVehiclePlate,
      ].where((p) => p != null).length;

  void onFirstNameChange(String v) {
    firstName = v;
    fieldErrors['name'] = null;
    notifyListeners();
  }

  void onLastNameChange(String v) {
    lastName = v;
    fieldErrors['lastname'] = null;
    notifyListeners();
  }

  void onEmailChange(String v) {
    email = v;
    fieldErrors['email'] = null;
    notifyListeners();
  }

  void onPhoneChange(String v) {
    phone = v;
    fieldErrors['phone'] = null;
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

  void onBrandChange(String v) {
    brand = v;
    notifyListeners();
  }

  void onVehicleModelChange(String v) {
    vehicleModel = v;
    notifyListeners();
  }

  void onYearChange(String v) {
    year = v;
    notifyListeners();
  }

  void onColorChange(String v) {
    color = v;
    notifyListeners();
  }

  void onPlateChange(String v) {
    plate = v.replaceAll('-', '');
    notifyListeners();
  }

  void onMaxCapacityChange(String v) {
    maxCapacity = v;
    notifyListeners();
  }

  bool validateStep1() {
    bool ok = true;
    if (profileImagePath == null) {
      fieldErrors['photo'] = 'La foto de perfil es obligatoria';
      ok = false;
    }
    if (firstName.trim().isEmpty) {
      fieldErrors['name'] = 'Requerido';
      ok = false;
    }
    if (lastName.trim().isEmpty) {
      fieldErrors['lastname'] = 'Requerido';
      ok = false;
    }
    if (!_validEmail(email)) {
      fieldErrors['email'] =
          'Usa un correo de Gmail, Outlook, Hotmail, Yahoo u otro proveedor conocido';
      ok = false;
    }
    if (phone.trim().length != 10) {
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
    if (ok) error = null;
    notifyListeners();
    return ok;
  }

  bool validateStep2() {
    if (docId == null || docLicense == null) {
      error = 'Adjunta los documentos obligatorios';
      notifyListeners();
      return false;
    }
    error = null;
    notifyListeners();
    return true;
  }

  bool validateStep3() {
    if (brand.isEmpty ||
        vehicleModel.isEmpty ||
        year.isEmpty ||
        color.isEmpty ||
        plate.isEmpty ||
        maxCapacity.isEmpty ||
        imgVehicleFront == null ||
        imgVehicleBack == null ||
        imgVehicleLeft == null ||
        imgVehicleRight == null ||
        imgCargoSpace == null ||
        imgVehiclePlate == null) {
      error = 'Completa todos los datos y fotos del vehículo';
      notifyListeners();
      return false;
    }
    if (!acceptedTerms || !acceptedPrivacy) {
      error =
          'Debes aceptar los términos y condiciones y la política de privacidad';
      notifyListeners();
      return false;
    }
    error = null;
    notifyListeners();
    return true;
  }

  void nextStep(BuildContext context) {
    if (currentStep == 0 && !validateStep1()) return;
    if (currentStep == 1 && !validateStep2()) return;
    if (currentStep == 2) {
      register();
      return;
    }
    currentStep++;
    notifyListeners();
  }

  void prevStep(BuildContext context) {
    if (currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    currentStep--;
    error = null;
    notifyListeners();
  }

  Future<void> _pickImage(
      ImageSource source, void Function(String path) setter) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (picked != null) {
      setter(picked.path);
      PaintingBinding.instance.imageCache.clear();
      notifyListeners();
    }
  }

  Future<void> pickProfilePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked != null) {
      profileImagePath = picked.path;
      fieldErrors['photo'] = null;
      notifyListeners();
    }
  }

  void onBirthdateChange(String v) {
    birthdate = v;
    fieldErrors['birthdate'] = null;
    notifyListeners();
  }

  Future<void> pickDocId(ImageSource source) =>
      _pickImage(source, (p) => docId = p);
  Future<void> pickDocLicense(ImageSource source) =>
      _pickImage(source, (p) => docLicense = p);
  Future<void> pickDocAddressProof(ImageSource source) =>
      _pickImage(source, (p) => docAddressProof = p);
  Future<void> pickImgVehicleFront(ImageSource source) =>
      _pickImage(source, (p) => imgVehicleFront = p);
  Future<void> pickImgVehicleBack(ImageSource source) =>
      _pickImage(source, (p) => imgVehicleBack = p);
  Future<void> pickImgVehicleLeft(ImageSource source) =>
      _pickImage(source, (p) => imgVehicleLeft = p);
  Future<void> pickImgVehicleRight(ImageSource source) =>
      _pickImage(source, (p) => imgVehicleRight = p);
  Future<void> pickImgCargoSpace(ImageSource source) =>
      _pickImage(source, (p) => imgCargoSpace = p);
  Future<void> pickImgVehiclePlate(ImageSource source) =>
      _pickImage(source, (p) => imgVehiclePlate = p);

  Future<void> register() async {
    if (!validateStep3()) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _useCase(DriverData(
        name: firstName.trim(),
        lastname: lastName.trim(),
        email: email,
        phone: phone,
        birthdate: birthdate,
        password: password,
        profileImagePath: profileImagePath,
        docIdFront: docId!,
        docIdBack: docId!,
        docLicense: docLicense!,
        docAddressProof: docAddressProof,
        brand: brand,
        vehicleModel: vehicleModel,
        year: year,
        color: color,
        plate: plate,
        maxCapacity: maxCapacity,
        imgVehicleFront: imgVehicleFront!,
        imgVehicleBack: imgVehicleBack!,
        imgVehicleLeft: imgVehicleLeft!,
        imgVehicleRight: imgVehicleRight!,
        imgCargoSpace: imgCargoSpace!,
        imgVehiclePlate: imgVehiclePlate!,
      ));
      registeredEmail = email;
      registerSuccess = true;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    }

    isLoading = false;
    notifyListeners();
  }
}
