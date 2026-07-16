import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/model/models.dart';
import '../data/repository/trip_repository_impl.dart';
import '../domain/trip_history_repository.dart';

class TripHistoryProvider extends ChangeNotifier {
  final TripHistoryRepository _repository = TripHistoryRepositoryImpl();

  List<Trip> trips = [];
  List<Trip> filteredTrips = [];
  int? selectedStatus;
  bool isLoading = false;
  String? error;

  Future<void> loadHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userType = await sl.tokenManager.getUserType() ?? 1;
      trips = userType == 2
          ? await _repository.getDriverTrips()
          : await _repository.getClientTrips();
      filteredTrips = trips;
    } catch (e) {
      error = 'Error al cargar el historial';
    }

    isLoading = false;
    notifyListeners();
  }

  void filterByStatus(int? status) {
    selectedStatus = status;
    filteredTrips = status == null
        ? trips
        : trips.where((t) => t.status == status).toList();
    notifyListeners();
  }
}
