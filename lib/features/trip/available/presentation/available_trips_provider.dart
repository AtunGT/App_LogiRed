import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/local/token_manager.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/utils/ride_status.dart';
import '../../../../core/utils/trip_schedule.dart';
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

  /// Viaje publicado, sin conductor y con su fecha/hora ya vencida.
  bool _isExpired(Trip t) =>
      t.status == RideStatus.pending &&
      t.driverId == null &&
      TripSchedule.isPast(t.date, t.hour);

  /// Cancela en la API (best-effort) los viajes vencidos. `cancel_reason` deja
  /// registrado que fue por expiración; el backend degrada e ignora el campo
  /// mientras no esté desplegado.
  Future<void> _cancelExpired(List<Trip> expired) async {
    await Future.wait(expired.map((t) async {
      try {
        await _api.updateRideStatus(t.id, {
          'status': RideStatus.cancelled,
          'cancel_reason': CancelReason.expired,
        });
      } catch (_) {}
    }));
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
      final live = all.where((t) => !_proposedIds.contains(t.id)).toList();

      // Viajes cuya fecha/hora ya pasó y siguen sin conductor: se cancelan
      // automáticamente (por expiración) y no se muestran. La cancelación real
      // en la API se dispara en segundo plano para no retrasar la lista.
      final expired = live.where(_isExpired).toList();
      if (expired.isNotEmpty) {
        final expiredIds = expired.map((t) => t.id).toSet();
        trips = live.where((t) => !expiredIds.contains(t.id)).toList();
        unawaited(_cancelExpired(expired));
      } else {
        trips = live;
      }
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
