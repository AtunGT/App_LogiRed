import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/utils/ride_status.dart';
import '../../../../core/utils/trip_schedule.dart';
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
      final all = await _repository.getMyTrips();

      final expired = all.where(_isExpired).toList();
      if (expired.isNotEmpty) {
        final expiredIds = expired.map((t) => t.id).toSet();
        trips = all.where((t) => !expiredIds.contains(t.id)).toList();
        unawaited(_cancelExpired(expired));
      } else {
        trips = all;
      }
    } catch (e) {
      error = 'Error al cargar tus viajes';
    }

    isLoading = false;
    notifyListeners();
  }

  bool _isExpired(Trip t) =>
      t.status == RideStatus.pending &&
      t.driverId == null &&
      TripSchedule.isExpired(t.date, t.hour);

  Future<void> _cancelExpired(List<Trip> expired) async {
    await Future.wait(expired.map((t) async {
      try {
        await _repository.cancelTrip(t.id, reason: CancelReason.expired);
      } catch (_) {}
    }));
  }

  Future<void> cancelTrip(int tripId) async {
    try {
      await _repository.cancelTrip(tripId, reason: CancelReason.manual);
      await loadTrips();
    } catch (e) {
      error = 'Error al cancelar el viaje';
      notifyListeners();
    }
  }
}
