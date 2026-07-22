import 'package:flutter/material.dart';
import '../../../../core/local/token_manager.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/utils/ride_status.dart';
import '../domain/home_repository.dart';

class HomeProvider extends ChangeNotifier with ViewStateMixin {
  final HomeRepository _repository;
  final TokenManager _tokens;

  HomeProvider(this._repository, this._tokens);

  int totalTrips = 0;
  int pendingTrips = 0;
  int acceptedTrips = 0;
  int completedTrips = 0;
  int cancelledTrips = 0;
  double totalWeightKg = 0;
  String topCity = '-';
  String lastTripDate = '-';

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userType = await _tokens.getUserType() ?? 1;
      final trips = userType == 2
          ? await _repository.getDriverTrips()
          : await _repository.getClientTrips();

      totalTrips = trips.length;
      pendingTrips = trips.where((t) => t.status == RideStatus.pending).length;
      acceptedTrips =
          trips.where((t) => t.status == RideStatus.assigned).length;
      completedTrips =
          trips.where((t) => t.status == RideStatus.completed).length;
      cancelledTrips =
          trips.where((t) => t.status == RideStatus.cancelled).length;
      totalWeightKg = trips.fold(0.0, (sum, t) => sum + t.approxWeight);

      final cityCounts = <String, int>{};
      for (final t in trips) {
        cityCounts[t.city] = (cityCounts[t.city] ?? 0) + 1;
      }
      if (cityCounts.isNotEmpty) {
        topCity =
            cityCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }

      if (trips.isNotEmpty) {
        trips.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? '') ?? 0);
        lastTripDate = trips.first.date;
      }
    } catch (e) {
      error = 'Error al cargar el inicio';
    }

    isLoading = false;
    notifyListeners();
  }
}
