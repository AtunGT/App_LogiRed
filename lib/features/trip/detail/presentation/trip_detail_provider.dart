import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/model/models.dart';

class TripDetailProvider extends ChangeNotifier {
  Trip? trip;
  bool isLoading = false;
  String? error;

  Future<void> loadTrip(int tripId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await sl.apiService.getRideById(tripId);
      final data = response.data['ride'] ?? response.data;
      trip = Trip.fromJson(data);
    } catch (e) {
      error = 'Error al cargar el viaje';
    }

    isLoading = false;
    notifyListeners();
  }
}
