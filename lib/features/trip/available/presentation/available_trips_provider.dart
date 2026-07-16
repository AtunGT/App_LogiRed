import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/model/models.dart';
import '../data/repository/available_trips_repository_impl.dart';
import '../domain/available_trips_repository.dart';

class AvailableTripsProvider extends ChangeNotifier {
  final AvailableTripsRepository _repository = AvailableTripsRepositoryImpl();

  List<Trip> trips = [];
  final Set<int> _proposedIds = {};
  String city = '';
  String userInitial = 'C';
  bool isLoading = false;
  String? error;

  void excludeTrip(int tripId) {
    _proposedIds.add(tripId);
    trips = trips.where((t) => t.id != tripId).toList();
    notifyListeners();
  }

  Future<void> loadCityAndSearch() async {
    city = await sl.tokenManager.getCityWork() ?? '';
    final userId = await sl.tokenManager.getUserId() ?? 0;
    try {
      final response = await sl.apiService.getUserProfile(userId);
      final user = UserResponse.fromJson(response.data);
      userInitial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'C';
    } catch (_) {}
    await searchTrips();
  }

  Future<void> searchTrips() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      try {
        final res = await sl.apiService.getMyProposals();
        final list = (res.data['proposals'] ?? res.data) as List? ?? [];
        for (final e in list) {
          final m = e as Map<String, dynamic>;
          final idRide = m['id_ride'] ?? m['idride'];
          if (idRide is int) _proposedIds.add(idRide);
        }
      } catch (_) {}

      final all = await _repository.getAvailableTrips(city);
      trips = all.where((t) => !_proposedIds.contains(t.id)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        error = 'Sesión expirada. Vuelve a iniciar sesión';
      } else {
        error = 'Conéctate a internet e intenta de nuevo';
      }
    } catch (_) {
      error = 'Conéctate a internet e intenta de nuevo';
    }

    isLoading = false;
    notifyListeners();
  }
}
