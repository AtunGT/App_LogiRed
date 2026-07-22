import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';

class TripDetailProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;

  TripDetailProvider(this._api);

  Trip? trip;

  Future<void> loadTrip(int tripId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _api.getRideById(tripId);
      final data = response.data['ride'] ?? response.data;
      trip = Trip.fromJson(data);
    } catch (e) {
      error = 'Error al cargar el viaje';
    }

    isLoading = false;
    notifyListeners();
  }
}
