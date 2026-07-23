import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/state/view_state.dart';

class RateDriverProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;

  RateDriverProvider(this._api);

  int _stars = 0;
  String _comment = '';
  final Set<String> _selectedTags = {};
  bool _sent = false;

  int get stars => _stars;
  String get comment => _comment;
  Set<String> get selectedTags => _selectedTags;
  bool get isSending => isLoading;
  bool get sent => _sent;

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
      error = 'Selecciona una calificación';
      notifyListeners();
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final comment = [
        if (_comment.isNotEmpty) _comment,
        if (_selectedTags.isNotEmpty) _selectedTags.join(', '),
      ].join(' · ');

      await _api.createReview({
        'iduser': driverId,
        'rating': _stars,
        if (comment.isNotEmpty) 'review': comment,
      });
      _sent = true;
    } catch (e) {
      error = 'No se pudo enviar la calificación';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
