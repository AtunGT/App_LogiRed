import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_service.dart';
import '../../../core/state/view_state.dart';

/// Un campo de archivo de `POST /users/me/reapply`. La clave es la misma que
/// usa el alta en `RegisterDriverRepositoryImpl`, asi que el backend recibe el
/// documento con el nombre que ya espera.
class ReapplyField {
  final String apiKey;
  final String label;
  final String filename;

  const ReapplyField(this.apiKey, this.label, this.filename);
}

const kReapplyDocuments = [
  ReapplyField('document_identificacion_adelante',
      'Identificacion oficial (frente)', 'id_front.jpg'),
  ReapplyField('document_identificacion_atras',
      'Identificacion oficial (reverso)', 'id_back.jpg'),
  ReapplyField('document_licencia', 'Licencia de conducir', 'license.jpg'),
  ReapplyField('document_comprobante_domicilio', 'Comprobante de domicilio',
      'address_proof.jpg'),
];

const kReapplyVehiclePhotos = [
  ReapplyField('frontview_image', 'Vehiculo de frente', 'vehicle_front.jpg'),
  ReapplyField('backview_image', 'Vehiculo por detras', 'vehicle_back.jpg'),
  ReapplyField('leftview_image', 'Vehiculo lado izquierdo', 'vehicle_left.jpg'),
  ReapplyField('rightview_image', 'Vehiculo lado derecho', 'vehicle_right.jpg'),
  ReapplyField('space_image', 'Espacio de carga', 'cargo_space.jpg'),
  ReapplyField('plates_image', 'Placas', 'vehicle_plate.jpg'),
];

const kReapplyProfilePhoto =
    ReapplyField('image', 'Foto de perfil', 'profile.jpg');

/// Campos de texto opcionales del mismo endpoint.
const kReapplyTextFields = <String, String>{
  'name': 'Nombre',
  'lastname': 'Apellido',
  'car_registration': 'Matricula',
  'brand': 'Marca',
  'model': 'Modelo',
  'color': 'Color',
  'max_capacity': 'Capacidad maxima',
};

/// Reenvio parcial de documentos de un conductor rechazado.
///
/// El endpoint conserva lo que no se manda, asi que solo se envia lo que el
/// conductor toco. Enviar todo de nuevo lo obligaria a repetir fotos que ya
/// estaban bien.
class DriverReapplyProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;
  final _picker = ImagePicker();

  DriverReapplyProvider(this._api);

  final Map<String, String> _files = {};
  final Map<String, String> _texts = {};

  bool success = false;

  String? pathOf(String apiKey) => _files[apiKey];
  String textOf(String apiKey) => _texts[apiKey] ?? '';

  /// Cuantos cambios lleva preparados. Con cero, el envio no tiene sentido.
  int get changeCount =>
      _files.length + _texts.values.where((v) => v.trim().isNotEmpty).length;

  bool get hasChanges => changeCount > 0;

  Future<void> pick(ReapplyField field) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (picked == null) return;
    _files[field.apiKey] = picked.path;
    error = null;
    PaintingBinding.instance.imageCache.clear();
    notifyListeners();
  }

  void remove(ReapplyField field) {
    _files.remove(field.apiKey);
    notifyListeners();
  }

  void setText(String apiKey, String value) {
    _texts[apiKey] = value;
    error = null;
    notifyListeners();
  }

  Future<void> submit() async {
    if (!hasChanges) {
      error = 'Adjunta al menos un documento o dato corregido';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final map = <String, dynamic>{};
      for (final entry in _texts.entries) {
        final value = entry.value.trim();
        if (value.isNotEmpty) map[entry.key] = value;
      }
      for (final entry in _files.entries) {
        final field = _fieldFor(entry.key);
        map[entry.key] = await MultipartFile.fromFile(
          entry.value,
          filename: field?.filename ?? '${entry.key}.jpg',
        );
      }

      final res = await _api.reapplyDriver(FormData.fromMap(map));
      if (res.statusCode != 200 && res.statusCode != 201) {
        error = _message(res.data, res.statusCode);
      } else {
        success = true;
      }
    } on DioException catch (e) {
      debugPrint(
          'REAPPLY ERROR ${e.response?.statusCode}: ${e.response?.data}');
      error = _message(e.response?.data, e.response?.statusCode);
    } catch (e) {
      debugPrint('REAPPLY ERROR: $e');
      error = 'No pudimos enviar tus documentos. Intenta de nuevo';
    }

    isLoading = false;
    notifyListeners();
  }

  static ReapplyField? _fieldFor(String apiKey) {
    for (final f in [
      ...kReapplyDocuments,
      ...kReapplyVehiclePhotos,
      kReapplyProfilePhoto,
    ]) {
      if (f.apiKey == apiKey) return f;
    }
    return null;
  }

  static String _message(dynamic data, int? code) {
    final raw = data is Map ? data['message']?.toString() : null;
    if (raw != null && raw.isNotEmpty) return raw;
    if (code != null) return 'No pudimos enviar tus documentos [Error $code]';
    return 'No pudimos enviar tus documentos. Intenta de nuevo';
  }
}
