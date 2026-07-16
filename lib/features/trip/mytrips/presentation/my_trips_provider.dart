import 'package:flutter/material.dart';
import '../../../../core/network/model/models.dart';
import '../data/repository/my_trips_repository_impl.dart';
import '../domain/my_trips_repository.dart';

class MyTripsProvider extends ChangeNotifier {
  final MyTripsRepository _repository = MyTripsRepositoryImpl();

  List<Trip> trips = [];
  bool isLoading = false;
  String? error;

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
