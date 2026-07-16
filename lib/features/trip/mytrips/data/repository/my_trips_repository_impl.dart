import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/model/models.dart';
import '../../domain/my_trips_repository.dart';

class MyTripsRepositoryImpl implements MyTripsRepository {
  @override
  Future<List<Trip>> getMyTrips() async {
    final response = await sl.apiService.getMyRequestedTrips();
    final list = response.data['rides'] as List? ?? [];
    return list.map((e) => Trip.fromJson(e)).toList();
  }

  @override
  Future<void> cancelTrip(int tripId) async {
    await sl.apiService.updateRideStatus(tripId, {'status': 4});
  }
}
