import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/model/models.dart';
import '../../domain/accepted_trips_repository.dart';

class AcceptedTripsRepositoryImpl implements AcceptedTripsRepository {
  @override
  Future<List<Trip>> getAcceptedTrips() async {
    final response = await sl.apiService.getMyAcceptedTrips();
    final list = response.data['rides'] as List? ?? [];
    return list.map((e) => Trip.fromJson(e)).toList();
  }
}
