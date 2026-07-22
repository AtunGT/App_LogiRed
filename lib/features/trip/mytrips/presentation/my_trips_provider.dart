import 'package:flutter/material.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';
import '../domain/my_trips_repository.dart';

class MyTripsProvider extends ChangeNotifier with ViewStateMixin {
  final MyTripsRepository _repository;

  MyTripsProvider(this._repository);

  List<Trip> trips = [];

  Future<void> loadTrips() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      trips = await _repository.getMyTrips();
    } catch (e) {
      error = 'Error al cargar tus viajes';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> cancelTrip(int tripId) async {
    try {
      await _repository.cancelTrip(tripId);
      await loadTrips();
    } catch (e) {
      error = 'Error al cancelar el viaje';
      notifyListeners();
    }
  }
}
