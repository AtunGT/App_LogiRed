import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';

class RateDriverProvider extends ChangeNotifier {
  int _stars = 0;
  String _comment = '';
  final Set<String> _selectedTags = {};
  bool _isSending = false;
  bool _sent = false;
  String? _error;

  int get stars => _stars;
  String get comment => _comment;
  Set<String> get selectedTags => _selectedTags;
  bool get isSending => _isSending;
  bool get sent => _sent;
  String? get error => _error;

  static const List<String> tags = [
    'Puntual',
    'Buen trato',
    'Vehículo limpio',
    'Profesional'
  ];

  static const List<String> _labels = [
    '',
    'Malo',
    'Regular',
    'Bueno',
    'Muy bueno',
    'Excelente'
  ];
  String get starLabel => _stars > 0 ? _labels[_stars] : '';

  void setStars(int value) {
    _stars = value;
    notifyListeners();
  }

  void onCommentChange(String value) {
    _comment = value;
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  Future<void> send(int driverId) async {
    if (_stars == 0) {
      _error = 'Selecciona una calificación';
      notifyListeners();
      return;
    }
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final comment = [
        if (_comment.isNotEmpty) _comment,
        if (_selectedTags.isNotEmpty) _selectedTags.join(', '),
      ].join(' · ');

      // POST /reviews no liga la reseña al viaje: el pasajero sale del token
      // y el conductor va en `iduser` (así lo nombra el backend).
      await sl.apiService.createReview({
        'iduser': driverId,
        'rating': _stars,
        if (comment.isNotEmpty) 'review': comment,
      });
      _sent = true;
    } catch (e) {
      _error = 'No se pudo enviar la calificación';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
