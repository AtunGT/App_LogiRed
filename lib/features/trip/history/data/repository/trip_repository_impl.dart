import 'package:dio/dio.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/model/models.dart';
import '../../../../../core/utils/ride_status.dart';
import '../../domain/trip_history_repository.dart';

class TripHistoryRepositoryImpl implements TripHistoryRepository {
  final ApiService _api;

  TripHistoryRepositoryImpl(this._api);

  @override
  Future<List<Trip>> getClientTrips() => _fetchHistory();

  @override
  Future<List<Trip>> getDriverTrips() => _fetchHistory();

  Future<List<Trip>> _fetchHistory() async {
    final response = await _api.getTripsHistory();
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list =
          (data['rides'] ?? data['data'] ?? data['trips'] ?? []) as List? ?? [];
    } else {
      list = [];
    }
    return list.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Trip>> getExpiredProposalTrips(Set<int> excludeRideIds) async {
    final res = await _api.getMyProposals();
    final list = (res.data['proposals'] ?? res.data) as List? ?? [];

    final seen = <int>{...excludeRideIds};
    final rideIds = <int>[];
    for (final e in list) {
      final p = e as Map<String, dynamic>;
      final idRide = (p['id_ride'] ?? p['idride'] ?? 0) as int;
      if (idRide != 0 && seen.add(idRide)) rideIds.add(idRide);
    }

    final trips = await Future.wait(rideIds.map(_expiredTripFor));
    return trips.whereType<Trip>().toList();
  }

  Future<Trip?> _expiredTripFor(int idRide) async {
    try {
      final r = await _api.getRideById(idRide);
      final rd = (r.data['ride'] ?? r.data) as Map<String, dynamic>;
      final trip = Trip.fromJson(rd);
      return trip.status == RideStatus.cancelled ? trip : null;
    } on DioException catch (e) {
      // La API respondió error: el conductor ya no puede consultar el viaje
      // (expiró sin asignarse). Entrada mínima con lo que se sabe.
      if (e.response != null) {
        return Trip(
          id: idRide,
          origin: 'Viaje #$idRide',
          destination: '',
          city: '',
          originLat: 0,
          originLng: 0,
          destinationLat: 0,
          destinationLng: 0,
          date: '',
          hour: '',
          approxWeight: 0,
          status: RideStatus.cancelled,
          clientId: 0,
          cancelReason: CancelReason.expired,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
