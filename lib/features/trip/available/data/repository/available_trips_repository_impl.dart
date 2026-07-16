import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/model/models.dart';
import '../../domain/available_trips_repository.dart';

class AvailableTripsRepositoryImpl implements AvailableTripsRepository {
  @override
  Future<List<Trip>> getAvailableTrips(String city) async {
    final response = await sl.apiService.getAvailableTrips();
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
  Future<void> acceptTrip(int tripId) async {
    await sl.apiService.acceptTrip(tripId);
  }
}
