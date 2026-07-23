import 'package:flutter/material.dart';
import '../../../../core/local/token_manager.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';
import '../domain/trip_history_repository.dart';

class TripHistoryProvider extends ChangeNotifier with ViewStateMixin {
  final TripHistoryRepository _repository;
  final TokenManager _tokens;

  TripHistoryProvider(this._repository, this._tokens);

  List<Trip> trips = [];
  List<Trip> filteredTrips = [];
  int? selectedStatus;

  Future<void> loadHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userType = await _tokens.getUserType() ?? 1;
      trips = userType == 2
          ? await _repository.getDriverTrips()
          : await _repository.getClientTrips();
      if (userType == 2) {
        // Viajes expirados a los que propuso y nunca se le asignaron:
        // la API no los devuelve en /rides/history, se completan aquí.
        try {
          final expired = await _repository
              .getExpiredProposalTrips(trips.map((t) => t.id).toSet());
          trips = [...trips, ...expired];
        } catch (_) {}
      }
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
