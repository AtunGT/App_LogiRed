import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/local/token_manager.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';
import '../domain/available_trips_repository.dart';

class AvailableTripsProvider extends ChangeNotifier with ViewStateMixin {
  final AvailableTripsRepository _repository;
  final ApiService _api;
  final TokenManager _tokens;

  AvailableTripsProvider(this._repository, this._api, this._tokens);

  List<Trip> trips = [];
  final Set<int> _proposedIds = {};
  String city = '';
  String userInitial = 'C';

  void excludeTrip(int tripId) {
    _proposedIds.add(tripId);
    trips = trips.where((t) => t.id != tripId).toList();
    notifyListeners();
  }

  Future<void> loadCityAndSearch() async {
    city = await _tokens.getCityWork() ?? '';
    final userId = await _tokens.getUserId() ?? 0;
    try {
      final response = await _api.getUserProfile(userId);
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
        final res = await _api.getMyProposals();
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
