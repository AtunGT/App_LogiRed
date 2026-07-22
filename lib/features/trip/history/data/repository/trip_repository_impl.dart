import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/model/models.dart';
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
}
